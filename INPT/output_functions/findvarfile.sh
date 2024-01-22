#!/bin/bash

function findVarfile {
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

	sourcefile=$(find "${ArtFile%/}" -type f \( -iname "*.varfile" \))
	#Searches user input for a file with a .varfile extension
	if [[ -z $sourcefile ]]; then
		echo -e "No varfile found!"
	else
		echo -e "\nthe varfile is "${sourcefile}"\n\n" 
		sleep 1
		source "${sourcefile}"
		echo -e "the artist's first name is "${ArtistFirstName}"\n"
		echo -e "the artist last name is "${ArtistLastName}"\n"
		sleep 1
		#These echo statements are in here (temporarily?) to confirm that sourcing the varfile has successfully re-assigned the variables $ArtistFirstName and $ArtistLastName
	fi

	set +a
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

function remove_special_chars {
    local str=$1
    str=$(printf '%s' "$str" | LC_ALL=C tr -dc '[:print:]\n')
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    echo "$str"
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
