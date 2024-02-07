#!/bin/bash

# defines directory of script and parent directory
script_dir=$(realpath $(dirname $0))
# script_dir assignment command is a bit complicated, see start_input for explanation of command
parent_dir="$(dirname "$script_dir")"

## Check to see if $fullInput_csv is assigned. It will be assigned if start_input has just run.
# If start_input didn't just run, then this is a new process. Start log, search for input csv.   
if [[ -z ${fullInput_csv} ]] ; then
	source "${script_dir}"/input_functions/makelog.sh
	MakeLog
	if [[ "$#" -lt 1 ]]; then
		# If command line arguments are less than 1, then:
    	logNewLine "No input/output CSV files provided!" "$RED"
		findCSV
		if [[ -n "${foundCSV}" ]] ; then
			# if an input file has been identified then read inputs and assign them to variables
			ReadCSV "${foundCSV}"
		fi
	else
		for arg in "$@"; do
			if [[ $arg == -* ]]; then
				if [[ "$arg" == "-t" ]] || [[ "$arg" == "--typos" ]]; then
					typo_check=true
				fi
				# Can add more if statements here for other flags
			else
				input_file_path=$arg
				# Assign the first argument to a variable
				if [[ ! -f "$input_file_path" ]]; then
				# if $input_file_path is not a file then,
					logNewLine "The provided file ${input_file_path} does not exist." "$RED"
				fi
				ReadCSV "${input_file_path}"
			fi
		done
	fi
fi

if [[ -z ${fullInput_csv} && -n ${input_csv} ]] ; then
# After checking the first line, if an input file has been identified then read inputs and assign them to variables
    logNewLine "Reading variables from input csv: ${input_csv}" "$CYAN"
    source "${script_dir}"/input_functions/find/findartfile.sh
    # remove_special_chars function is stored in findartfile.sh
    if test -f "${input_csv}"; then
    # test that input_csv is a file
        while IFS=, read -r key value || [ -n "$key" ]
        do
            # Replace variable names with descriptions
            case $key in
                "Artist's First Name") key="ArtistFirstName" ;;
                "Artist's Last Name") key="ArtistLastName" ;;
                "Artwork Title") key="title" ;;
                "Accession Number") key="accession" ;;
                "Path to Artwork File on T: Drive") key="ArtFile" ;;
                "Staging Directory on DroBo") key="SDir" ;;
                "Path to hard drive") key="Volume" ;;
                "Path to Technical Info_Specs directory") key="techdir" ;;
                "Path to Technical Info_Specs/Sidecars directory") key="sidecardir" ;;
                "Path to Condition_Tmt Reports directory") key="reportdir" ;;
                "Path Artwork Files parent directory") key="ArtFilePath" ;;
                "Path to the Time-based Media Artworks directory on the TBMA DroBo") key="TBMADroBoPath" ;;
            esac
            # Remove quotes and special characters from the key and value
            key=$(remove_special_chars "$key")
            value=$(remove_special_chars "$value")
            # Assign the value to a variable named after the key
            declare "$key=$value"
            # Print debug information but uncommenting line below:
            # echo "Key: $key, Value: $value"
        done < "${input_csv}"
        logNewLine "Successfully read variables from ${input_csv}" "$CYAN"
    else
        logNewLine "Unable to read variables from ${input_csv}" "$RED"
        unset input_csv
    fi
fi 

# if an output file has been identified then read selected options and assign them to variables
if [[ -n "${output_csv}" ]]; then
	logNewLine "Reading variables from output csv: ${output_csv}" "$CYAN"
	source "${script_dir}"/input_functions/find/findartfile.sh
    # remove_special_chars function is stored in findartfile.sh
	if test -f "${output_csv}"; then
	# test that input_csv is a file
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
		done < "${output_csv}"
		logNewLine "successfully read variables from ${output_csv}" "$CYAN"
	else
		logNewLine logNewLine "Unable to read variables from ${output_csv}" "$RED"
        unset output_csv
	fi
fi

if [[ -n "${output_csv}" && $Run_Copyit = "0" ]] ; then
	logNewLine "From Output CSV - Not all files from ${Volume} will be moved to ${SDir}" "$WHITE"
elif [[ -n "${output_csv}" && $Run_Copyit = "1" ]] ; then
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

MoveOldLogs
cp "${configLogPath}" "${techdir}"/"${ArtistLastName}"_"${accession}"_"${logName}"

figlet OUTPUT