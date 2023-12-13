#!/bin/bash

set -a

#This function determines if the list_of_dirs.txt file exists, and if it does, it deletes it.
function DeleteList {
test -f $(find "$techdir" -type f \( -iname "*_list_of_dirs.txt" -o -iname "*_list_of_files.txt" \)) && 
find "$techdir" -type f \( -iname "*_list_of_dirs.txt" -o -iname "*_list_of_files.txt" \) -print0 |
	while IFS= read -r -d '' l;
		do rm "$l"
	done
}

#This function finds the file path to the copyit.py script
function FindcopyitPath {
	if [[ -f copyit.py ]]; then
		copyitPath=`dirname "$0"`
		echo "found copyit.py at $copyitPath"
	else
		cowsay -W 30 "Please input the path to the "copyit.py" script in the IFIscripts-master directory. Feel free to drag and drop the directory into terminal:"
		read -e copyitPathInput
		#Asks for user input and assigns it to variable
		copyitPath="$(echo -e "${copyitPathInput}" | sed -e 's/[[:space:]]*$//')"
		#Strips a trailing space from the input. 
		#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
		#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
		echo "The path to the IFI scripts are: $copyitPath"
	fi
}

#This function runs the python script copyit.py from the IFIscripts directory
function CopyitVolumeStaging {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** copyit.py started ******** \n -------------------> copyit.py will be run on all contents of the volume" >> "${configLogPath}" &&
	#print timestamp and command to log
	echo -e "******** copyit.py started ******** \n copyit.py will be run on all contents of the volume" &&
	#prints statement to log
	python3 "${copyitPath%/}"/copyit.py "$Volume" "$SDir" &&
	for t in "`find "$SDir" -name "*_manifest.md5"`" ; do cp "$t" "$techdir" && echo -e "\n***** md5 checksum manifest ***** \n" >> "${reportdir}/${accession}_appendix.txt" && cat "$t" >> "${reportdir}/${accession}_appendix.txt"
	done
	if [[ -n $(find "${SDir}" -name "*_manifest.md5") ]]; then 
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** copyit.py completed ******** \n\n\t\tcopyit.py Results:\n\t\tall files copied to the $SDir" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
	else 
		echo -e "\n\n\t\tcopyit.py Results:\n\t\t\n xxxxxxxx No manfiest file found in $SDir xxxxxxxx" >> "${configLogPath}"
	fi
}

function CopyitSelected {
SECONDS=0 &&
echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** copyit.py started ******** \n\tcopyit.py will be run on selected directories of the volume" >> "${configLogPath}" &&
#print timestamp and command to log
echo -e "******** copyit.py started ******** \n copyit.py will be run on selected directories of the volume" &&
#prints statement to terminal
declare -a SelectedDirs
#creates an empty array
#For whatever reason, the array isn't a golabl variable, so it has to be created again. 
let i=0
while IFS=$'\n' read -r line_data; do
    #stipulates a line break as a field seperator, then assigns the variable "line_data" to each field read
    SelectedDirs[i]="${line_data}"
    #states that each line will be an element in the arary
    ((++i))
    #adds each new line to the array
done < "${techdir}/${accession}_list_of_dirs.txt"
#populates the array with contents of the text file, with each new line assigned as its own element 
#got this from https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
for eachdir in "${SelectedDirs[@]}"; do 
#for each element in the array, do
    python3 "${copyitPath%/}"/copyit.py "$eachdir" "$SDir"
    #add echo statement to log here?
done &&
#run the IFI copyit script and send each selected directory to the staging directory
#On 03/02/2021 I had all kinds of problems with python3 after an xcode update. I ran brew unlink python@3.9, brew unlink python@3.8, and brew link python@3.8. Then I ran echo 'export PATH="/usr/local/opt/python@3.8/bin:$PATH"' >> ~/.zshrc. This last step seemed to make it work, but I have to run pip3 with "sudo" now. Solution fond here: https://github.com/Homebrew/homebrew-core/issues/62911#issuecomment-733866503
find "$SDir" -type f \( -iname "*_manifest.md5" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$techdir" && echo -e "\n***** md5 checksum manifest ***** \n" >> "${reportdir}/${accession}_appendix.txt" && cat "$t" >> "${reportdir}/${accession}_appendix.txt"
	done
if [[ -n $(find "${SDir}" -name "*_manifest.md5") ]]; then 
	echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** copyit.py completed ******** \n\n\t\tcopyit.py Results:\n\t\tselect directories copied to the $SDir" >> "${configLogPath}" &&
	#prints timestamp once the command has exited
	duration=$SECONDS
	echo "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}" 
else 
	echo -e "\n\n\t\tcopyit.py Results:\n\t\txxxxxxxx No manfiest file found in $SDir xxxxxxxx" >> "${configLogPath}"
fi
}

#This function will create an md5 checksum manifest for the files on the Volume if the "no, specific files" option from the "Run_Copyit" select loop is chosen 
function RunIndvMD5 {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** generating md5 checksums on selected files ******** \nmd5deep will be run on ${Volume}" >> "${configLogPath}" &&
	echo -e " ******** generating md5 checksums on selected files ******** \n md5deep will be run on ${Volume}" &&
	#prints statement to terminal
	declare -a SelectedFiles
	#creates an empty array
	#For whatever reason, the array isn't a golabl variable, so it has to be created again. 
	let i=0
	while IFS=$'\n' read -r line_files; do
    #stipulates a line break as a field seperator, then assigns the variable "line_data" to each field read
    	SelectedFiles[i]="${line_files}"
    	#states that each line will be an element in the arary
    	((++i))
    	#adds each new line to the array
	done < "${techdir}/${accession}_list_of_files.txt"
	#populates the array with contents of the text file, with each new line assigned as its own element 
	#got this from https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
	for eachfile in "${SelectedFiles[@]}"; do 
	#for each element in the array, do
    	md5deep -b -e "$eachfile" >> "${SDir}/${accession}_Volume_manifest.txt"
    	#runs md5deep on each element in the array, and prints it to a manifest text file
	#maybe run echo statement to print to log?
	done
	echo -e "\n***** md5 manifest from ${Volume} ***** \n" >> "${reportdir}/${accession}_appendix.txt" &&
	cat "${SDir}/${accession}_Volume_manifest.txt" >> "${reportdir}/${accession}_appendix.txt" &&
	cp "${SDir}/${accession}_Volume_manifest.txt" "$techdir"
	if [[ -f "${SDir}/${accession}_Volume_manifest.txt" ]]; then
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** md5 checksum manifest from ${Volume} completed ******** \n\n\t\tmd5deep Results:\n\t\tcopied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
	else
		echo -e "\n\t\tmd5deep Results:\n\t\txxxxxxxx md5 manifest of ${Volume} output not found in $SDir xxxxxxxx" >> "${configLogPath}"
	fi
}

function CopyFiles {
SECONDS=0 &&
echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** copying files started ******** \n\tcopying individual files from the volume" >> "${configLogPath}" &&
#print timestamp and command to log
echo -e "******** copying files started ******** \n copying individual files from the volume"  &&
#print statement to terminal
declare -a SelectedFiles
#creates an empty array
#For whatever reason, the array isn't a golabl variable, so it has to be created again. 
let i=0
while IFS=$'\n' read -r line_files; do
    #stipulates a line break as a field seperator, then assigns the variable "line_data" to each field read
    SelectedFiles[i]="${line_files}"
    #states that each line will be an element in the arary
    ((++i))
    #adds each new line to the array
done < "${techdir}/${accession}_list_of_files.txt"
#populates the array with contents of the text file, with each new line assigned as its own element 
#got this from https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
echo -e "\n\tlist of files copied below:" >> "${configLogPath}"
#prints the above statement to the log
for eachfile in "${SelectedFiles[@]}"; do 
#for each element in the array, do
    rsync -aihW --progress --log-file="${techdir}/${accession}_$(basename $eachfile)_rsynclog.txt" "$eachfile" "$SDir"
    #runs rsync with the archive mode, itemized changes (prints to log), human readable, and whole file flags
    #prints a seperate log file for each of the individual files to the  techdir
    echo -e "\t${eachfile}" >> "${configLogPath}" 
    #prints the name of each file to the log
    md5deep -b -e "${SDir}/$(basename $eachfile)" >> "${SDir}/${accession}_SDir_manifest.txt"
done &&
echo -e "\n***** md5 manifest from ${SDir} ***** \n" >> "${reportdir}/${accession}_appendix.txt" &&
cat "${SDir}/${accession}_SDir_manifest.txt" >> "${reportdir}/${accession}_appendix.txt" &&
if [[ -f "${SDir}/${accession}_SDir_manifest.txt" ]]; then
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** file copying and md5 checksum manifest from ${SDir} completed ******** \n\n\t\trsync Results:\n\t\tmanifest copied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt \n rsync logs in ${techdir}" >> "${configLogPath}" &&
	#prints timestamp once the command has exited
	duration=$SECONDS
	echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
else
	echo -e "\n\n\t\trsync Results:\n\t\txxxxxxxx md5 manifest of ${SDir} output not found in $SDir xxxxxxxx" >> "${configLogPath}"
fi
Md5comp=$(diff "${SDir}/${accession}_Volume_manifest.txt" "${SDir}/${accession}_SDir_manifest.txt")
#Sets the variable Md5comp to be the output of the diff command run on the two md5 manifests created if select individual files is chosen by the user
if [ "$Md5comp" != "" ]
#if the variable is empty then, (taken from https://stackoverflow.com/questions/3611846/bash-using-the-result-of-a-diff-in-a-if-statement)
then
	echo "The ${Volume} md5 manifest and the ${SDir} md5 manifest do not match!"
	echo -e "\n xxxxxxxx No manfiest file found in $SDir xxxxxxxx" >> "${configLogPath}"
	diff -y "${SDir}/${accession}_Volume_manifest.txt" "${SDir}/${accession}_SDir_manifest.txt" > "${techdir}/${accession}_$(date "+%Y-%m-%d - %H.%M.%S")_md5_collision.txt"
else
	echo -e "Files moved to ${SDir} and the \nchecksums match!"
	echo -e "All checksums match!" >> "${reportdir}/${accession}_appendix.txt"
	echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** checksum manifests match ******** \n" >> "${configLogPath}" &&
	#prints timestamp once the command has exited
	duration=$SECONDS
	echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}" 
fi
}

set +a