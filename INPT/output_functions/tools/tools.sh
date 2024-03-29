#!/bin/bash
 
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
		logNewLine "===================> ${tool_name} started! ${tool_name} will be run on ${input}" "$Bright_Yellow"
		#prints statement to terminal
		if [[ "$command" == "tree" ]]; then
			$command "${input}" > "${SDir}"/"${accession}_${suffix}".txt
			echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			cat "${SDir}"/"${accession}_${suffix}.txt" >> "${reportdir}/${accession}_appendix.txt"  
			cp "${SDir}"/"${accession}_${suffix}.txt" "$sidecardir"
		else
			find "${input}" -type f  \( "${extension_list[@]}" \) ! -iname "*qctools*" -print0 | 
			while IFS= read -r -d '' i; do
				filename=$(basename "${i}")
				# conditional statements below account for different command structures of different tools
				if [[ "$command" == "ffmpeg -hide_banner -nostdin -i" ]]; then
					ffmpeg -hide_banner -nostdin -i "$i" -f framemd5 -an  "${i%.*}_${suffix}".txt
					logNewLine "${tool_name} run on ${filename}" "$YELLOW"
				elif [[ "$command" == "qcli -i" ]]; then
					qcli -i "$i"
					logNewLine "${tool_name} run on ${filename}" "$YELLOW"
				else
					"${command}" "$i" > "${i%.*}_${suffix}."txt 
					logNewLine "${tool_name} run on ${filename}" "$YELLOW"
				fi
			done
			# Search for side car files and, if found, move contents of sidecars to additional outputs (appendix and sidecars directory of the artwork file)
			find "${SDir}" -type f \( -iname "*${suffix}*" \) -print0 |
			while IFS= read -r -d '' t; do 
				cp "$t" "$sidecardir"
				if [[ "$suffix" != "framemd5" && "$suffix" != "qctools" ]] ; then
					echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
					cat "$t" >> "${reportdir}/${accession}_appendix.txt"
				fi
			done
		fi
		# because the input for tree will be the $volume, need to reassign the input variable to work with the find command below, which will ensure find is searching where tree output is sent
		if [[ "$command" == "tree" ]]; then
			input="${SDir}"
		fi
		# Search sidecars if recent output is found, log timing and outputs, otherwise report no output and offer to run tool again 
		if [[ -n $(find "${input}" -name "*${suffix}*" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
		# the -newermt option along with the date command finds files modified within the last 10 seconds. The $(date -v-10S) command generates a timestamp representing the time 10 seconds ago, and the -newermt option filters files modified after that timestamp.
			duration=$SECONDS
			logNewLine "===================> ${tool_name} complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
			if [[ "$suffix" != "framemd5" && "$suffix" != "qctools" ]] ; then
				logNewLine "${tool_name} output written to ${accession}_appendix.txt and saved as a sidecar file" "$YELLOW"
			fi
			tool_again=no
		else 
			logNewLine "No ${tool_name} files found in "${input}"" "$Bright_Red"
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
			logNewLine "Re-running ${tool_name} on "${input}"" "$Bright_Red"
		fi

	done
}

function RunTree {
	RunToolOnDir "Tree" "$Volume" "tree" "tree_output" "n/a"
}

# This function will create siegfried sidecar files for all files in the staging directory, the copy output to Technical Info_Specs directory in the artwork file and appendix in artwork file
function RunSF {
	sf_extensions="-iname *.* ! -iname *.md5 ! -iname *_output.txt ! -iname *.DS_Store ! -iname *_manifest.txt ! -iname *_sf.txt ! -iname *_exif.txt ! -iname *_mediainfo.txt ! -iname *qctools* ! -iname *_framemd5.txt ! -iname *.log"
	RunToolOnDir "siegfried" "${SDir}" "sf" "sf" "${sf_extensions}"
}

# This function will create MediaInfo sidecar files for all video abd audio files (based on file extensions) in the staging directory, the copy output to the Technical Info_Specs directory in the artwork file and appendix in the artwork file
function RunMI {
	mi_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg -o -iname *.wav -o -iname *.mp3"
	RunToolOnDir "MediaInfo" "${SDir}" "mediainfo" "mediainfo" "${mi_extensions}"
}

# This function will create Exiftool sidecar files for all video, audio, and still image files (based on file extensions) in the staging directory, the copy output to the Technical Info_Specs directory in the artwork file and appendix in the artwork file
function RunExif {
	exif_extensions="-iname *.jpg -o -iname *.jpeg -o -iname *.png -o -iname *.tiff -o -iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg -o -iname *.wav -o -iname *.mp3"
	RunToolOnDir "ExifTool" "${SDir}" "exiftool" "exif" "${exif_extensions}"
}

# This function will create md5 checksums per frame saved to sidecar files for all video and audio files (based on file extensions) in the staging directory, the copy output to the Technical Info_Specs directory in the artwork file
# I'm having issues passing the command to the function for some reason, so the command is currently 'hard coded'. Changing the command here will not change how the command is run, it must be changed directly from RunToolOnDir
function Make_Framemd5 {
	fmd5_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.avi -o -iname *.VOB -o -iname *.mpg -o -iname *.wav -o -iname *.flac -o -iname *.mp3 -o -iname *.aac -o -iname *.wma -o -iname *.m4a"
	RunToolOnDir "Frame MD5" "${SDir}" "ffmpeg -hide_banner -nostdin -i" "framemd5" "${fmd5_extensions}"
}

# This function will a QCTools report for all video and audio files (based on file extensions) in the staging directory, the copy output to the Technical Info_Specs directory in the artwork file
# I'm having issues passing the command to the function for some reason, so the command is currently 'hard coded'. Changing the command here will not change how the command is run, it must be changed directly from RunToolOnDir
function Make_QCT {
	qct_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg"
    RunToolOnDir "QCTools" "${SDir}" "qcli -i" "qctools" "${qct_extensions}"
}