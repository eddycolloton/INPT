#!/bin/bash

set -a

# Function to remove BOM and non-printable characters
function remove_special_chars {
    local str=$1
    local accented_chars='éèêëàáâäãåæçèéêëìíîïðñòóôõöùúûüýÿ'
    str=$(printf '%s' "$str" | LC_ALL=C sed -E "s/[^[:print:]\n\r\t$accented_chars]//g")
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    str="${str//[\"]}"
    echo "${str//[\']}"
}

function InputArtistsName {
    echo -e "\n*************************************************\nInput artist's first name"
    read -e ArtistFirstName
    #Asks for user input and assigns it to variable
    echo -e "\n*************************************************\nInput artist's last name"
    read -e ArtistLastName
    #Asks for user input and assigns it to variable
	logNewLine "Artist name manually input: ${ArtistFirstName} ${ArtistLastName}" "$CYAN"
}

function ConfirmArtistsName {
	while [[ "$name_again" = yes ]] ; do
		InputArtistsName
		cowsay "Just checking for typos - Is the Artist's Name entered correctly?"
		IFS=$'\n'; select name_option in "Yes" "No, go back a step" ; do
			if [[ $name_option = "Yes" ]] ; then
				name_again=no
			elif [[ $name_option = "No, go back a step" ]] ; then
				unset ArtistFirstName ArtistLastName
			fi
		break           
		done;

		if [[ "$name_again" = yes ]]; then
			echo -e "Let's try again"
		fi
    done
}

#This function finds the Artwork file path
function FindArtworkFilesPath {
	if [[ -z "${ArtFilePath}" ]]; then
		if [[ -d /Volumes/hmsg/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/hmsg/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES 
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		elif [[ -d /Volumes/SHARED/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/SHARED/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		elif [[ -d /Volumes/shared/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		elif [[ -d /Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		else
			cowsay -W 30 "Please input the path to the ARTWORK FILES directory from the T:\ drive. Feel free to drag and drop the directory into terminal:"
			read -e ArtFilePath
			logNewLine "The path to the Artwork Files is: $ArtFilePath" "$Bright_Magenta"
		fi
		export ArtFilePath="${ArtFilePath}"
	fi
}

ConfirmInput () {
    local var="$1"
    local var_again="$2"
	select options in "yes" "no, go back a step"; do
		case $options in
			yes)
				select_again=no
                eval "$var_again=\$select_again"
				break;;
			"no, go back a step")
				select_again=yes
                eval "$var_again=$select_again"
                unset var
				break;;
		esac
	done
}

function ConfirmTitle {
	while [[ "$title_again" = yes ]] ; do
		echo -e "\n*************************************************\nInput the artwork's title" && read title
        # prompts user for artwork title and reads input
		cowsay "Just checking for typos - Is the artwork title entered correctly?"
		logNewLine "The title manually input: ${title}" "$CYAN"
		ConfirmInput title title_again
		if [[ "$title_again" = yes ]] ;
			then echo -e "Let's try again"
		fi
	export title="${title}"
	done
}

function CheckAccession {
    while [[ "$accession_again" = yes ]] ; do
        echo -e "\n*************************************************\nInput accession number" && read accession
        #prompts user for accession number and reads input
		cowsay "Just checking for typos - Is the accession number entered correctly?"
        logNewLine "The accession number manually input: ${accession}" "$CYAN"
        ConfirmInput accession accession_again
        if [[ "$accession_again" = yes ]] ;
            then echo -e "Let's try again"
        fi
    done
    export accession="${accession}"
}

#This function makes the nested directores of a Time-based Media Artwork File
function MakeArtworkFile {
	while [[ -z "$accession" ]] ; do
		if [[ "$typo_check" == true ]] ; then
			accession_again=yes
			CheckAccession
		else
			echo -e "\n*************************************************\nEnter Accession Number in '####.###' format" && read accession
        	#prompts user for accession number and reads input
			logNewLine "The accession number manually input: ${accession}" "$CYAN"
		fi
		export accession="${accession}"
	done
	while [[ -z "$title" ]] ; do
    	if [[ "$typo_check" == true ]] ; then
			ConfirmTitle
			title_again=yes
		else
			echo -e "\n*************************************************\nInput the artwork's title" && read title
        	# prompts user for artwork title and reads input
			logNewLine "The title manually input: ${title}" "$CYAN"
		fi
		export title="${title}"
	done
	mkdir -p "${ArtFilePath%/}"/"$ArtistLastName"", ""$ArtistFirstName"/"time-based media"/"$accession""_""$title"/{"Acquisition and Registration","Artist Interaction","Cataloging","Conservation"/{"Condition_Tmt Reports","DAMS","Equipment Reports"},"Iteration Reports_Exhibition Info"/"Equipment Reports","Photo-Video Documentation","Research"/"Correspondence","Technical Info_Specs"/{"Past installations_Pics","Sidecars"},"Trash"}
	#creates Artwork File directories
	#I've removed the path to the HMSG shared drive below for security reasons
	ArtFile="${ArtFilePath%/}"/"$ArtistLastName"", ""$ArtistFirstName"/
	#assigns the ArtFile variable to the artwork file just created 
	#I've removed the path to the HMSG shared drive below for security reasons
	logNewLine "The artwork file has been created: ${ArtFile}" "$YELLOW"
	export ArtFile="${ArtFile}"
} 

ParseAccession () {
    local parsed_accession="$1"
    local found_dir="$2"
    local count="$3"
    dir_name=$(basename "$found_dir")
    parsed_accession=$(echo "$dir_name" | awk -F'[ _]' '{print $1}')
    #sed command cuts everything before and after ##.# in the titledir variable name. I got the sed command from https://unix.stackexchange.com/questions/243207/how-can-i-delete-everything-until-a-pattern-and-everything-after-another-pattern/243236
    if [[  $(echo -n "$parsed_accession" | wc -c) =~ $count ]]; then
        logNewLine "The accession number is ${parsed_accession} found in the artwork folder ${found_dir}" "$MAGENTA"
        export accession="${parsed_accession}"
    else
        CheckAccession 
    fi
}

#this function searches the artwork folder for the accession number, if there is one, it retrieves it, if there isn't it requests one from the user
function FindAccessionNumber {
IFS=$'\n'
title_dir_results=$(find "${ArtFile}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \) -print0 | xargs -0 -L 1  | wc -l | xargs)
#uses find command to identify directories that have numbers in the name AND a . OR a -, then prints them. The first xargs command creates line breaks between the results
#I don't know how xargs works, I got that bit from https://stackoverflow.com/questions/20165321/operating-on-multiple-results-from-find-command-in-bash
#wc -l counts the lines from the output of the find command, this should give the number of directories found that have an accession number in them
#The final xargs removes white space from the output of wc so that theoutput can be evalutated by the "if" statement below
if [[ "$title_dir_results" > 1 ]]; then
	logNewLine "More than one directory containing an accession number found." "$MAGENTA"
    #If the variable title_dir_results stores more than one result
	#This is to determine if there is more than one dir in the ArtFile that has an accession number (typically means there are two artworks by the same artist)
	echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
    if [[ "$typo_check" == true ]] ; then
		accession_again=yes
		CheckAccession
	else
		echo -e "\n*************************************************\nInput accession number" && read accession
        #prompts user for accession number and reads input
		logNewLine "The accession number manually input: ${accession}" "$CYAN"
	fi
	accession_dir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname "*${accession}*")
	#defines the accession_dir variable as a directory stored inside the ArtFile that has the accession number in it's name
	#This is to define a more specific variable, if there is more than one artwork in the ArtFile
	if [[ -z "${accession_dir}" ]]; then
	#if the accession_dir variable is empty
	#This var will typically be empty if the find command did not return a result
		while [[ -z "$title" ]] ; do
            if [[ "$typo_check" == true ]] ; then
				ConfirmTitle
				title_again=yes
			else
				echo -e "\n*************************************************\nInput the artwork's title" && read title
        		# prompts user for artwork title and reads input
				logNewLine "The title manually input: ${title}" "$CYAN"
			fi
		done
		accession_dir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname "*${title}*")
        #defines the accession_dir variable as a directory stored inside the ArtFile that has the title in it's name
		#This is to define a more specific variable, if there is more than one artwork in the ArtFile, or the directory is named in a way that is unexpected (i.e. with no accession number or accession number written ##-##)
		if [[ -z "${accession_dir}" ]]; then
		#if the accession_dir variable is empty
			echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure.\nCannot find the parent directory from the title or accession number directory.\nChoose the directory that will store the Technical Info_Specs directory and the Condition_Tmt Reports directory.\nSee directories listed below:\n"
			sleep 1
			tree "$ArtFile"
			sleep 2
			cowsay "Select a directory, or choose to quit:"
			#prompt for select command
			IFS=$'\n'; select parentdir_option in "$ArtFile" "Enter path to parent directory" "Quit" ; do
			#lists options for select command. The IFS statment stops it from escaping when it hits spaces in directory names
			case $parentdir_option in 
				"$ArtFile") accession_dir="$ArtFile"
				#if ArtFile is selected, it is assigned the variable $accession_dir
					logNewLine "The Artwork File is $accession_dir" "$MAGENTA"
				break;;
				"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
					read -e parentdir_input &&
					#reads user input and assigns it to the variable $reportdir_parent
					accession_dir="$(echo -e "${parentdir_input}" | sed -e 's/[[:space:]]*$//')"
					#Strips a trailing space from the input. 
					#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
					#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
					logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
				break;;
				"Quit") echo "Quitting now..." && exit 1
				#ends the script, exits
			esac	
		    done;
		    unset IFS
		else 
            logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
		fi
	else 
        logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
	fi
fi

if [[ -z "${accession}" ]]; then
#if the accession variable is not assigned, and there are numbers in the titledir name 
	titledir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \))
	#looks in the ArtFile for a directory with numbers in the name, if it finds one, AND it has a period OR a dash in the directory name, it assigns that to the titledir variable
	if [[ -z "$titledir" ]]; then 
	#if the $titledir variable is empty, then
        echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
    	if [[ "$typo_check" == true ]] ; then
			accession_again=yes
			CheckAccession
		else
			echo -e "\n*************************************************\nInput accession number" && read accession
        	# prompts user for accession number and reads input
			logNewLine "The accession number manually input: ${accession}" "$CYAN"
		fi
	fi
	acount=$(echo "$titledir" | grep -oE '[0-9]')
	#this grep command prints every digit it finds in titledir on a new line, and assigns that output to the variable "acount"
	if [[ $(echo "$acount" | wc -l) =~ 3 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 3, then
	    ParseAccession accession "${titledir}" "4"
	elif [[ $(echo "$acount" | wc -l) =~ 4 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 4, then
        ParseAccession accession "${titledir}" "5"
	elif [[ $(echo "$acount" | wc -l) =~ 7 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 7, then
        ParseAccession accession "${titledir}" "8"
	else 
		echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
    	if [[ "$typo_check" == true ]] ; then
			accession_again=yes
			CheckAccession
		else
			echo -e "\n*************************************************\nInput accession number" && read accession
        	# prompts user for accession number and reads input
			logNewLine "The accession number manually input: ${accession}" "$CYAN"
		fi
	fi
fi
unset IFS
}

function InputArtfile {
	echo "Input path to Artwork File:"
	read -e ArtFileInput
	#Asks for user input and assigns it to variable
	ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
	#Strips a trailing space from the input. 
	#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
	#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
}

function ConfrimArtfile {
	while [[ "$artfile_again" = yes ]] ; do
		InputArtfile
		cowsay "Just checking for typos - Is the path to the artwork file entered correctly?"
		logNewLine "The artwork file manually input is ${ArtFile}" "$CYAN"
		IFS=$'\n'; select artfile_option in "Yes" "No, go back a step" ; do
			if [[ $artfile_option = "Yes" ]] ; then
				artfile_again=no
			elif [[ $artfile_option = "No, go back a step" ]] ; then 
				unset ArtFile
			fi
		break           
		done;

		if [[ "$artfile_again" = yes ]] ; then
			echo -e "Let's try again"
		fi
	done
}

function FindArtworkFile {
FindArtFile="$(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*")"
#searches artwork files directory for Artists Last Name
if [[ -z "${FindArtFile}" ]]; then
#if the find command returns nothing then  
		echo -e "\n*************************************************\n The Artwork File was not found!\n"
		cowsay -W 30 "Enter a number to set the path to the Artwork File on the T:\ drive:"
		#prompt for select command
		IFS=$'\n'; select artdir in $(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Artwork File" ; do
		#lists options for select command - the IFS statment stops it from escaping when it hits spaces in directory names
  		if [[ $artdir = "Input path" ]]
  		then while [[ -z "$ArtFile" ]] ; do 
			if [[ "$typo_check" == true ]] ; then
				artfile_again=yes
				ConfrimArtfile
			else
				InputArtfile
			fi
			if [[ -z "${accession}" ]];
			then
				FindAccessionNumber
				#searches the Artwork File for the accession number, and assigns it to the $accession variable
				sleep 1
			fi
  		done
  		elif [[ $artdir = "Create Artwork File" ]]
  		then MakeArtworkFile 
		else
			ArtFile=$artdir
			#assigns variable to the users selection from the select menu
			logNewLine "The artwork file is ${ArtFile}" "$Bright_Magenta"
			export ArtFile="${ArtFile}"
			if [[ -z "${accession}" ]];
			then
				FindAccessionNumber
				#searches the Artwork File for the accession number, and assigns it to the $accession variable
				sleep 1
			fi
		fi
		break			
		done;
elif [[ $(echo "${FindArtFile}" | wc -l) > 1 ]]; 
	then
		#FindArtFile_Lines=$(echo "${FindArtFile}" | wc -l)
		FindArtFile=(${FindArtFile[@]})
		for i in ${FindArtFile[@]}; do
			if [[ -z "${accession}" ]]; then
				FindAccessionNumber
			fi
			accession_dir=$(find "${i%/}" -maxdepth 1 -type d -iname "*$accession*")
			if [[ ! -z "${accession_dir}" ]];
			then
				"${i%/}"=$ArtFile
				if [[ -z "${accession}" ]]; then
				FindAccessionNumber
				fi
				logNewLine "The artwork file is ${ArtFile}" "$Bright_Magenta"
				export ArtFile="${ArtFile}"
			fi
		done
else
	ArtFile="${FindArtFile}"
	#assigns variable to the results of the find command "find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*""
	logNewLine "The artwork file is ${ArtFile}" "$Bright_Magenta"
	export ArtFile="${ArtFile}"
	if [[ -z "${accession}" ]]; then
		FindAccessionNumber
		#searches the Artwork File for the accession number, and assigns it to the $accession variable
		sleep 1
	fi
fi
}

function findCSV {
	set -a

	#This function will search the user input, which should be the artwork file (a directory), to find a varfile created by the make_dirs.sh script. When successful, this will re-assignt he variables assigned in the make_dirs.sh script.
	echo -e "type or drag and drop the path of the artwork file\n"
	#Asks for the user input which will be passed to the findVarfile function defined at the beginning of the script
	read -e ArtFileInput
	#Asks for user input and assigns it to variable
	ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
	#Strips a trailing space from the input. 
	#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
	#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
	export ArtFile="${ArtFile}"

	sourcefile=$(find "${ArtFile%/}" -type f \( -iname "*.csv" \))
	#Searches user input for a file with a .varfile extension
	if [[ -z $sourcefile ]]; then
		echo -e "No CSV found!"
	else
		echo -e "\nthe CSV is "${sourcefile}"\n\n" 
	fi

	set +a
}

function searchArtFile {
#This function searches the artwork file for sidecars created by the make_meta.sh script. 
	set -a
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
	sleep 1
	set +a
}


set +a