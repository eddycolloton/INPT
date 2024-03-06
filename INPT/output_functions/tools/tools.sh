#!/bin/bash

ArrayCheck () {
    if [[ "$(declare -p var 2>/dev/null)" =~ "declare -a" ]]; then
        echo "Variable contains an array."
    elif [[ -d "${var}" ]]; then
        echo "Variable contains a directory."
    else
        echo "Variable does not contain a directory or an array."
    fi
}
 
RunToolOnDir () {
	local tool_name="$1"
	local input="$2"
	local command="$3"
	local suffix="$4"
	local extension_list_string="$5"

	IFS=' ' read -r -a extension_list <<< "${extension_list_string}"

	tool_again=yes
	while [[ "$tool_again" = yes ]] ; do
		SECONDS=0  
		logNewLine  "$tool_name started! $tool_name will be run on $input" "$Bright_Yellow"
		#prints statement to terminal
		if [[ "$command" == "tree" ]]; then
			$command "${input}" > ${SDir}/"${accession}_${suffix}".txt
			echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			cat ${SDir}/"${accession}_${suffix}.txt" >> "${reportdir}/${accession}_appendix.txt"  
			cp ${SDir}/"${accession}_${suffix}.txt" "$sidecardir"
		else
			find "${input}" -type f  \( "${extension_list[@]}" \) ! -iname "*qctools*" -print0 | 
			while IFS= read -r -d '' i; do
				# conditional statements below account for different command structures of different tools
				if [[ "$command" == "ffmpeg -hide_banner -nostdin -i" ]]; then
					ffmpeg -hide_banner -nostdin -i "$i" -f framemd5 -an  "${i%.*}_${suffix}".txt
					logNewLine  "${tool_name} run on $(basename ${i})" "$YELLOW"
				elif [[ "$command" == "qcli -i" ]]; then
					qcli -i "$i"
					logNewLine  "${tool_name} run on $(basename ${i})" "$YELLOW"
				else
					$command "$i" > "${i%.*}_${suffix}."txt 
					logNewLine  "${tool_name} run on $(basename ${i})" "$YELLOW"
				fi
			done
			# Search for side car files and, if found, move contents of sidecars to additional outputs (appendix and sidecars directory of the artwork file)
			find "$input" -type f \( -iname "*_${suffix}.txt" \) -print0 |
			while IFS= read -r -d '' t; do 
				cp "$t" "$sidecardir"
				if [[ "$suffix" != "framemd5" ]] ; then
					echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
					cat "$t" >> "${reportdir}/${accession}_appendix.txt"
				fi
			done
		fi
		# because the input for tree will be the $volume, need to reassign the input variable to work with the find command below, which will ensure find is searching where tree output is sent
		if [[ "$command" == "tree" ]]; then
			input="$SDir"
		fi
		# Search sidecars if recent output is found, log timing and outputs, otherwise report no output and offer to run tool again 
		if [[ -n $(find "${input}" -name "*${suffix}*" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
		# the -newermt option along with the date command finds files modified within the last 10 seconds. The $(date -v-10S) command generates a timestamp representing the time 10 seconds ago, and the -newermt option filters files modified after that timestamp.
			duration=$SECONDS
			logNewLine  "${tool_name} complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
			if [[ "$tool_name" != "FrameMD5" ]] ; then
				logNewLine  "${tool_name} output written to ${accession}_appendix.txt and saved as a sidecar file" "$YELLOW"
			fi
			tool_again=no
		else 
			logNewLine  "No ${tool_name} files found in $input" "$Bright_Red"
			echo -e "\n Run ${tool_name} again? (Choose a number 1-2)"
			select tool_again_option in "yes" "no"
			do
				case $tool_again_option in
					yes) tool_again=yes
					# set again variable to enable loop
					break;;
					no) tool_again=no
					break;;
					esac
			done
		fi

		# if the user selects to run the tool again the "while [[ "$tool_again" = yes ]] ; do" will loop through again
		if [[ "$tool_again" = yes ]]; then
			logNewLine  "Re-running ${tool_name} on $input" "$Bright_Red"
		fi

	done
}

#This function runs tree on the Volume sends the output to three text files 
RunToolOnFile () {
    local file="$1"
    local tool_name="$2"
    local command="${3}"
    local suffix="$4"
            
    tool_again=yes
	SECONDS=0 
    while [[ "$tool_again" = yes ]] ; do
        if [[ ${command} == "ffmpeg -hide_banner -nostdin -i" ]]; then
            ${command} ${file} -f framemd5 -an  ${file%.*}_${suffix}.txt
            logNewLine  "${tool_name} run on $(basename ${file})" "$YELLOW"
        elif [[ ${command} == "qcli -i" ]]; then
            ${command} "$file"
            logNewLine  "${tool_name} run on $(basename ${file})" "$YELLOW"
        else
            "${command}" "$file" > "${file%.*}_${suffix}."txt 
            logNewLine  "${tool_name} run on $(basename ${file})" "$YELLOW"
        fi   
        find "${SDir}" -type f \( -iname "*_${suffix}.txt" \) -print0 |
        while IFS= read -r -d '' t; 
            do 
            cp "$t" "$sidecardir"
			if [[ "$suffix" != "framemd5" ]] ; then
            	echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
            	cat "$t" >> "${reportdir}/${accession}_appendix.txt"
			fi
        done
        if [[ -n $(find "${SDir}" -name "*${suffix}*" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
        # the -newermt option along with the date command finds files modified within the last 10 seconds. The $(date -v-10S) command generates a timestamp representing the time 10 seconds ago, and the -newermt option filters files modified after that timestamp.
            duration=$SECONDS
            logNewLine  "${tool_name} run on ${file}! Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
            if [[ "$suffix" != "framemd5" ]] ; then
				logNewLine  "${tool_name} output written to ${accession}_appendix.txt and saved as a sidecar file" "$YELLOW"
            fi
			tool_again=no
        else 
            logNewLine "No ${tool_name} files found in $SDir" "$Bright_Red"
            echo -e "\n Run ${tool_name} again? (Choose a number 1-2)"
            select tool_again_option in "yes" "no"
            do
                case $tool_again_option in
                    yes) tool_again=yes
                    # set again variable to enable loop
                    break;;
                    no) tool_again=no
                    break;;
                    esac
            done
        fi

    if [[ "$tool_again" = yes ]]; then
        logNewLine  "Re-running ${tool_name} on $file" "$Bright_Red"
    fi

    done

    unset tool_again
}

# Prompt to determine if tools should be run on all files in the staging directory or only on selected files
SelectedFilesForInput () {
    local List="${1}"

	echo -e "\nRun tools on all files in: \n$SDir \n\nOr run tools on these selected files only: \n$List\n"
	select ArrayInputOption in "All Files" "Selected Files Only"
	do
	case $ArrayInputOption in
		"All Files") ArrayInput="no"
			break;;
		"Selected Files Only") ArrayInput="yes"
			break;;
	esac
	done
    export ArrayInput="${ArrayInput}"
}

# Arrays created from the SelectFiles function store 'source paths', paths from the $Volume. 
# The files have since been moved to the $SDir, so this function changes the paths to the elements of the array to $SDir paths 
# This will potentially break on selected directories with subdirectories.
# Explore using a find command to match file names with those in $SDir
FixSelectedArrayPaths() {
    local input_string="$1"

    IFS=' ' read -r -a input_array <<< "$input_string"

    tool_array=()
    for input in "${input_array[@]}"; do
        local basename=$(basename "$input")
        tool_array+=("$SDir/$basename")
    done

    #logNewLine "Selected files in the staging directory have the following paths: ${tool_array[@]}" "$YELLOW"

}

# RunTool determines if the metadata tool will be run on $SDir, $FileList array or $DirsList array
# For either array option, this function loops through the individual files or directories in the array, and filters tools by file extension list.
function RunTool {
    local tool_name="$1"
    local command="$2"
    local suffix="$3"
	local extensions="$4"
    
    #local tool_array=()


    if [[ $ArrayInput == "yes" && -n $FileList ]] ; then
    # Iterate over each file in the array
        logNewLine "${tool_name} will be run on selected files" "$Bright_Yellow"
        FixSelectedArrayPaths "${FileList}"
        for file in "${tool_array[@]}"; do
            if find ${SDir} -type f \( $extensions \) -print0 | grep -q "$(basename "$file")"; then
                RunToolOnFile "${file}" "${tool_name}" "${command}" "${suffix}" 
            fi
        done
        unset transformed_array
    elif [[ $ArrayInput == "yes" && -n $DirsList ]] ; then
        FixSelectedArrayPaths $DirsList tool_array
        for dir in "${tool_array[@]}"; do
            echo "searching $dir for files"
            RunToolOnDir  "${tool_name}" "${dir}" "${command}" "${suffix}" "${extensions}"
        done
        unset transformed_array
    else
        RunToolOnDir "${tool_name}" "${SDir}" "${command}" "${suffix}" "${extensions}"
    fi
}

# Tree is different from the other tools, as it is run on the $Volume and is not run on files with (or without) specific file extensions 
# So, tree uses the RunToolOnDir function instead of RunTool. 
function RunTree {
	RunToolOnDir "Tree" "$Volume" "tree" "tree_output" "n/a"
}

#This function will create siegfried sidecar files for all files in the selected input, then copies output to the Sidecars directory in the ArtFile and appendix in ArtFile
function RunSF {
	sf_extensions=" ! -iname *.md5 ! -iname *_output.txt ! -iname *.DS_Store ! -iname *_manifest.txt ! -iname *_sf.txt ! -iname *_exif.txt ! -iname *_mediainfo.txt ! -iname *qctools* ! -iname *_framemd5.txt ! -iname *.log"
	RunTool "siegfried" "sf" "sf" "${sf_extensions}"
}

#This function will create mediainfo sidecar files for all video and audio files in the selected input, then copies output to the Sidecars directory in the ArtFile and appendix in ArtFile
RunMI () {
    mi_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg -o -iname *.wav -o -iname *.mp3"
    RunTool "MediaInfo" "mediainfo -f" "mediainfo" "${mi_extensions}"
} 

#This function will create Exiftool sidecar files for all files with .jpg, .jpeg, .png and .tiff file extensions in the selected input, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
RunExif () {
	exif_extensions="-iname *.jpg -o -iname *.jpeg -o -iname *.png -o -iname *.tiff -o -iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg -o -iname *.wav -o -iname *.mp3"
	RunTool "ExifTool" "exiftool" "exif" "${exif_extensions}"
}

#This function will create framemd5 sidecar files for all video and audio files in the selected input, then copies output to the Sidecars directory in the ArtFile, but does not write to the appendix in ArtFile
Make_Framemd5 () {
	fmd5_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.avi -o -iname *.VOB -o -iname *.mpg -o -iname *.wav -o -iname *.flac -o -iname *.mp3 -o -iname *.aac -o -iname *.wma -o -iname *.m4a"
	RunTool "FrameMD5" "ffmpeg -hide_banner -nostdin -i" "framemd5" "${fmd5_extensions}"
}

#This function will create QCTools report sidecar files for all video and audio files in the selected input, then copies output to the Sidecars directory in the ArtFile
Make_QCT () {
	qct_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg"
    RunTool "QCTools" "qcli -i" "qctools" "${qct_extensions}"
}