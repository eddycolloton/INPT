#!/bin/bash

source `dirname "$0"`/HMSG_auto.config    #this sets the path for the config file, which should be nested next to the script 

figlet Automation!

function findVarfile {
#This function will search the user input, which should be the artwork file (a directory), to find a varfile created by the make_dirs.sh script. When successful, this will re-assignt he variables assigned in the make_dirs.sh script.
	sourcefile=$(find "${1}" -type f \( -iname "*.varfile" \))
  #Searches user input for a file with a .varfile extension
	echo -e "\nthe varfile is "${sourcefile}"\n\n" 
	source "${sourcefile}"
	echo -e "the artist's first name is "${ArtistFirstName}"\n"
	echo -e "the artist last name is "${ArtistLastName}"\n"
  #These echo statements are in here (temporarily?) to confirm that sourcing the varfile has successfully re-assigned the variables $ArtistFirstName and $ArtistLastName
}

function searchArtFile {
#This function searches the artwork file for sidecars created by the make_meta.sh script. 
	if [[ -z $(find "${techdir}" -iname "*_manifest.md5") ]]; then 
  #if no file with "mainfest.md5" is in the technical info and specs directory, then
		echo -e "No md5 manifest found"
		md5_report=0
	else
		echo -e "md5 manifest found"
		md5_report=1
    #assigns a value to the $md5_report variable depending ont he results of the find command in the if statement above
	fi
	if [[ -f "${techdir}/${accession}_tree_output.txt" ]]; then
		echo -e "No tree text file found"
		tree_report=0
	else
		echo -e "tree text file found"
		tree_report=1
	fi	
	if [[ -f "${techdir}/${accession}_disktype_output.txt" ]]; then
		echo -e "No disktype report found"
		dt_report=0
	else
		echo -e "disktype report found"
		dt_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*_sf.txt") ]] ; then 
		echo -e "No siegfried report found"
		sf_report=0
	else
		echo -e "siegfried report found"
		sf_report=1
	fi	
	if [[ -z $(find "${techdir}" -iname "*_mediainfo.txt") ]]; then 
		echo -e "No MediaInfo report found"
		mi_report=0
	else
		echo -e "MediaInfo report found"
		mi_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*_exif.txt") ]]; then
		echo -e "No exiftool report found"
		exif_report=0
	else
		echo -e "exiftool report found"
		exif_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*_framemd5.txt") ]]; then
		echo -e "No framemd5 text file found"
		fmd5_report=0
	else
		echo -e "framemd5 text file found"
		fmd5_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*.qctools*") ]]; then
		echo -e "No qctools report found"
		qct_report=0
	else
		echo -e "qctools report found"
		qct_report=1
	fi
}

echo -e "type or drag and drop the path of the artwork file\n"
#Asks for the user input which will be passed to the findVarfile function defined at the beginning of the script
read -e ArtFileInput
		#Asks for user input and assigns it to variable
ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
		#Strips a trailing space from the input. 
		#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
		#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable

findVarfile "${ArtFile%/}"

if [[ -z "${SDir}" ]]; then
	echo -e "\nNo Staging Directory variable found, varfile may not have sourced correctly\n\n"
else
	echo -e "\nStaging Directory variable found, varfile sourced correctly\n\n"
fi

logName=`date '+%Y-%m-%d-%H.%M.%S'`_"$ArtistLastName"_"$accession"  #the log will be named after the Date (YYYY-MM-DD)
logName+='.log'
logPath="${techdir}/${logName}"
logCreate "${logPath}"
echo -e "The log has been created using the file name $logPath \n \n"
#The log commands are from loglog: https://github.com/amiaopensource/loglog/blob/main/bash_logging.config
sleep 1

searchArtFile

#searchSDir
#Worth checking SDir for metadata? 

cowsay "move files?"
IFS=$'\n'; select move_option in "yes" "no" ; do
	if [[ $move_option = yes ]]
	then
		source move_files.sh 
	fi
break
done ;

cowsay "Run metadata tools on files in ${SDir}?"
IFS=$'\n'; select mkmeta_option in "yes" "no" ; do
	if [[ $mkmeta_option = yes ]]
	then
		source meta_files.sh 
	fi
break
done ;


