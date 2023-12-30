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
	logNewLine -e "varfile found! Artwork File is here: ${ArtFile}\n Staging directory is here: ${SDir}" "$MAGENTA"
	if [[ -z "${techdir}" ]] ; then
    	source "${script_dir}"/input_functions/find/findreportdir.sh
    	FindTechDir
	else
    	echo "Technical Info and Specs: $techdir"
	fi
	searchArtFile
fi

if [[ -z $(find "${techdir}" -iname "*_manifest.md5") ]]; then
	source "${script_dir}"/output_functions/move/selectfiles.sh
	UserSelectFiles
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
	source "${script_dir}"/output_functions/move/selectfiles.sh
	UserSelectFiles
fi

source "${script_dir}"/output_functions/tools/selecttools.sh
SelectTools
source "${script_dir}"/output_functions/move/runmovefiles.sh
RunMoveFiles
source "${script_dir}"/output_functions/tools/runtools.sh
RunTools

cp "${configLogPath}" "${techdir}"/"${ArtistLastName}"_"${accession}"_"${logName}"

figlet OUTPUT