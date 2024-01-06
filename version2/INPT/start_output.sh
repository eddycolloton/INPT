#!/bin/bash

## Want this script to work in 2 different scenarios: 
### 1: going directly from start_input.sh
### 2: resuming processing data that is partially complete, where variables can be sourced from the 'varfile'


script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
parent_dir="$(dirname "$script_dir")"


if [[ -z "${varfilePath}" ]] ; then
	source "${script_dir}"/input_functions/makelog.sh
	MakeLog
	source "${script_dir}"/output_functions/findvarfile.sh
	findVarfile
	if [[ -z "${sourcefile}" ]] ; then
		echo -e "No varfile found!"
	else
		logNewLine -e "varfile found! Artwork File is here: ${ArtFile}\n Staging directory is here: ${SDir}" "$MAGENTA"
	fi
	if [[ -z "${techdir}" ]] ; then
    	source "${script_dir}"/input_functions/find/findreportdir.sh
    	FindTechDir
	else
    	echo "Technical Info and Specs: $techdir"
	fi
	searchArtFile
fi

source "${script_dir}"/input_functions/inputs.sh
if test -f "${parent_dir}"/output_template.csv; then
# Read the CSV file
    while IFS=, read -r key value || [ -n "$key" ]
    do
        # Replace variable names with descriptions
        case $key in
            "Move all files to staging directory") key="Run_Copyit" ;;
			"Select files to move to staging directory") key="Run_UserSelectFiles" ;;
			"Run all tools") key="Run_meta" ;;
            "Run tree on volume") key="Run_tree" ;;
            "Run siegfried on files in staging directory") key="Run_sf" ;;
            "Run MediaInfo on video files in staging directory") key="Run_mediainfo" ;;
            "Run Exiftool on media files in staging directory") key="Run_exif" ;;
            "Create framdemd5 output for video files in staging directory") key="Run_framemd5" ;;
            "Create QCTools reports for video files in staging directory") key="Run_QCTools" ;;
        esac
        # Remove quotes and special characters from the key and value
        key=$(remove_special_chars "$key" | tr -d '"')
        value=$(remove_special_chars "$value" | tr -d '"')
        # Assign the value to a variable named after the key
        declare "$key=$value"
        # Print debug information
        # echo "Key: $key, Value: $value"
    done < "${parent_dir}"/output_template.csv
    logNewLine "output csv found at "${parent_dir}"/output_template.csv" "$CYAN"
else
    logNewLine "No output csv found" "$RED"
fi

if [[ $Run_Copyit = "0" ]] ; then
	logNewLine "From Output CSV - Not all files from ${Volume} will be moved to ${SDir}" "$WHITE"
elif [[ $Run_Copyit = "1" ]] ; then
	logNewLine "From Output CSV - All files from ${Volume} will be moved to ${SDir}" "$WHITE"
else
	if [[ -z $(find "${techdir}" -iname "*_manifest.md5") ]]; then
		if [[ -z $Run_UserSelectFiles ]] ; then
			source "${script_dir}"/output_functions/move/selectfiles.sh
			UserSelectFiles
		elif [[ $Run_UserSelectFiles = "1" ]] ; then
			UserSelectFiles
		elif [[ $Run_UserSelectFiles = "0" ]] ; then
			Run_Copyit=0 && Run_MultiCopy=0
		fi
	else
		cowsay "Checksum manifest found in Artwork File! Checksums from the following files were found in ${techdir}:"
		sleep 1
		mainfest_search=$(find "${techdir}" -type f -name "*_manifest.md5")
		# Use a while loop to read each line from the find command output
		echo "${mainfest_search}" | while read -r manifest; do
		# Read from the current file and process its content
			while IFS='  ' read -r md5 filename; do
			# Print the result for each line
				echo "$filename"
			done < "$manifest"
		done
		echo -e "\n"
		unset IFS
		sleep 1
		if [[ -z $Run_UserSelectFiles ]] ; then
			source "${script_dir}"/output_functions/move/selectfiles.sh
			UserSelectFiles
		elif [[ $Run_UserSelectFiles = "1" ]] ; then
			source "${script_dir}"/output_functions/move/selectfiles.sh
			UserSelectFiles
		elif [[ $Run_UserSelectFiles = "0" ]] ; then
			Run_Copyit=0 && Run_MultiCopy=0
		fi
	fi
fi

source "${script_dir}"/output_functions/tools/selecttools.sh
SelectTools
source "${script_dir}"/output_functions/move/runmovefiles.sh
RunMoveFiles
source "${script_dir}"/output_functions/tools/runtools.sh
RunTools

cp "${configLogPath}" "${techdir}"/"${ArtistLastName}"_"${accession}"_"${logName}"

figlet OUTPUT