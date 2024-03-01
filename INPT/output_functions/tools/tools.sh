#!/bin/bash

# fixes for tools: Test newermt option, doesn't seem to be working
# exclude qctools outputs and other INPT generated files from media only tools

# change "find $SDir" command to only apply to files selected in the select files step? 

#This function runs tree on the Volume sends the output to three text files 
function RunTree {
	tree_again=yes
	while [[ "$tree_again" = yes ]]
	do
	SECONDS=0  
	logNewLine "tree started! tree running on $Volume" "$Bright_Yellow"
	tree "$Volume" > "$SDir"/"$accession"_tree_output.txt
	echo -e "\n***** tree output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
	cat "${SDir}/${accession}_tree_output.txt" >> "${reportdir}/${accession}_appendix.txt"  
	cp "${SDir}/${accession}_tree_output.txt" "$sidecardir"
	if [[ -n $(find "${SDir}" -name "${accession}_tree_output.txt" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]]; then
	# the -newermt option along with the date command finds files modified within the last 10 seconds.
		duration=$SECONDS
		logNewLine "===================> tree complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
		logNewLine "tree output written to ${accession}_appendix.txt, and saved as sidecar file ${accession}_tree_output.txt." "$YELLOW"
		tree_again=no
	else
		logNewLine "tree output not found in ${SDir}" "$Bright_Red"
		echo -e "\n Run tree again? (Choose a number 1-2)"
		select treeAgain_option in "yes" "no"
		do
			case $treeAgain_option in
				yes) tree_again=yes
				# set again variable to enable loop
				break;;
				no) tree_again=no
				break;;
				esac
		done
	fi

	if [[ "$tree_again" = yes ]]; then
		logNewLine "re-running tree on ${Volume}" "$CYAN" 
	fi
	
	done
}
 
#This function will create siegfried sidecar files for all files in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunSF {
	sf_again=yes
	while [[ "$sf_again" = yes ]]
	do
	SECONDS=0  
	logNewLine "sf started! siegfried will be run on $SDir" "$Bright_Yellow"
	#prints statement to terminal
	find "$SDir" -type f \( -iname "*.*" ! -iname "*.md5" ! -iname "*_output.txt" ! -iname "*.DS_Store" ! -iname "*_manifest.txt" ! -iname "*_sf.txt" ! -iname "*_exif.txt" ! -iname "*_mediainfo.txt" ! -iname "*qctools*" ! -iname "*_framemd5.txt" ! -iname "*.log" \) -print0 | 
	while IFS= read -r -d '' i; do
		sf "$i" > "${i%.*}_sf."txt 
		logNewLine "sf run on $(basename ${i})" "$YELLOW"
	#runs sf on all files in the staging directory except files that were made earlier in this workflow (md5 manifest, disktype, tree, and DS_Stores) 
	#The "for" loop was not working with this command. I found the IFS solution online, but honestly don't totally understand how it works.
	done   
	find "$SDir" -type f \( -iname "*_sf.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do 
		cp "$t" "$sidecardir"
		echo -e "\n***** siegfried output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
		cat "$t" >> "${reportdir}/${accession}_appendix.txt"
	done 
	if [[ -n $(find "${SDir}" -name "*_sf.txt" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
	# the -newermt option along with the date command finds files modified within the last 10 seconds. The $(date -v-10S) command generates a timestamp representing the time 10 seconds ago, and the -newermt option filters files modified after that timestamp.
		duration=$SECONDS
		logNewLine "===================> siegfried complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
		logNewLine "siegfried output written to ${accession}_appendix.txt and saved as a sidecar file" "$YELLOW"
		sf_again=no
	else 
		logNewLine "No siegfried files found in $SDir" "$Bright_Red"
		echo -e "\n Run siegfried again? (Choose a number 1-2)"
		select sfAgain_option in "yes" "no"
		do
			case $sfAgain_option in
				yes) sf_again=yes
				# set again variable to enable loop
				break;;
				no) sf_again=no
				break;;
				esac
		done
	fi

	if [[ "$sf_again" = yes ]]; then
		logNewLine "Re-running siegfried on $SDir" "$CYAN"
	fi

	done
}

#This function will create MediaInfo sidecar files for all files with .mp4, .mov and .mkv file extensions in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunMI {
	mi_again=yes
	while [[ "$mi_again" = yes ]]
	do
	SECONDS=0  
	logNewLine "MediaInfo started! MediaInfo will be run on audio and video files in $SDir" "$Bright_Yellow"
	find "$SDir" -type f \( -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.VOB -o -iname \*.avi -o -iname \*.mpg -o -iname \*.wav -o -iname \*.mp3  \) ! -iname "*qctools*" -print0 |  
	while IFS= read -r -d '' i;
		do  
			mediainfo -f "$i" > "${i%.*}_mediainfo".txt
			logNewLine "mediainfo run on $(basename ${i})" "$YELLOW"
	done  
	find "$SDir" -type f \( -iname "*_mediainfo.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$sidecardir"
		echo -e "\n***** mediainfo -f output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
		cat "$t" >>  "${reportdir}/${accession}_appendix.txt"
	done
	if [[ -n $(find "${SDir}" -name "*_mediainfo.txt" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
	# the -newermt option along with the date command finds files modified within the last 10 seconds.
		duration=$SECONDS
		logNewLine "===================> MediaInfo completed! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
		logNewLine "MediaInfo output written to ${accession}_appendix.txt and saved as a sidecar file" "$YELLOW"
		mi_again=no
	else 
		logNewLine "No MediaInfo files found in $SDir" "$Bright_Red"
		echo -e "\n Run MediaInfo again? (Choose a number 1-2)"
		select miAgain_option in "yes" "no"
		do
			case $miAgain_option in
				yes) mi_again=yes
				# set again variable to enable loop
				break;;
				no) mi_again=no
				break;;
				esac
		done
	fi

	if [[ "$mi_again" = yes ]]; then
		logNewLine "Re-running MediaInfo again" "$CYAN"
	fi

	done
}

#This function will create Exiftool sidecar files for all files with .jpg, .jpeg, .png and .tiff file extensions in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunExif {
	exif_again=yes
	while [[ "$exif_again" = yes ]]
	# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
	do
	SECONDS=0  
	logNewLine "Exiftool started! Exiftool will be run on files in $SDir" "$Bright_Yellow"
	find "$SDir" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.tiff -o -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.VOB -o -iname \*.avi -o -iname \*.mpg -o -iname \*.wav -o -iname \*.mp3  \) ! -iname "*qctools*" -print0 |  
	while IFS= read -r -d '' i;
		do  
			exiftool "$i" > "${i%.*}_exif".txt
			logNewLine "exiftool run on $(basename ${i})" "$YELLOW"
		done  
	find "$SDir" -type f \( -iname "*_exif.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do 
			cp "$t" "$sidecardir"
			echo -e "\n***** Exiftool output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			cat "$t" >> "${reportdir}/${accession}_appendix.txt"
	done
	if [[ -n $(find "${SDir}" -name "*_exif.txt" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
	# the -newermt option along with the date command finds files modified within the last 10 seconds.
		duration=$SECONDS
		logNewLine "===================> Exiftool complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
		logNewLine "Exiftool output written to ${accession}_appendix.txt and saved as a sidecar file" "$YELLOW"
		exif_again=no
	else
		logNewLine "No exiftool files found in $SDir" "$Bright_Red"
		echo -e "\n Run Exiftool again? (Choose a number 1-2)"
		select exifAgain_option in "yes" "no"
		do
			case $exifAgain_option in
				yes) exif_again=yes
				# set again variable to enable loop
				break;;
				no) exif_again=no
				break;;
				esac
		done
	fi

	if [[ "$exif_again" = yes ]]; then
		logNewLine "Re-running Exiftool again" "$CYAN"
	fi

	done
}

#This function will make a text file containing md5 checksums of each frame of any video files in the Staging Directory. The output will be saved as a side car file in the Staging Directory and the Tech Specs dir in the ArtFile
function Make_Framemd5 {
	framemd5_again=yes
	while [[ "$framemd5_again" = yes ]]
	# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
	do
	SECONDS=0 
	logNewLine "framemd5 started! framemd5 will be run on video files in $SDir" "$Bright_Yellow" 
	find "$SDir" -type f \( -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.avi -o -iname \*.VOB -o -iname \*.mpg -o -iname \*.wav -o -iname \*.flac -o -iname \*.mp3 -o -iname \*.aac -o -iname \*.wma -o -iname \*.m4a  \) ! -iname "*qctools*" -print0 |  
	while IFS= read -r -d '' i;
		do   
			logNewLine "framemd5 running on $(basename ${i})" "$YELLOW" 
			ffmpeg -hide_banner -nostdin -i "$i" -f framemd5 -an  "${i%.*}_framemd5".txt 
	done 
	find "$SDir" -type f \( -iname "*_framemd5.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$sidecardir"
	done
	if [[ -n $(find "${SDir}" -name "*_framemd5.txt" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
	# the -newermt option along with the date command finds files modified within the last 10 seconds.
		duration=$SECONDS
		logNewLine "===================> framemd5 complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
		logNewLine "framemd5 output copied to $(basename ${SDir})" "$YELLOW"
		framemd5_again=no
	else
		logNewLine "No framemd5 files found in $SDir" "$Bright_Red"
		echo -e "\n Run Framemd5 again? (Choose a number 1-2)"
		select framemd5Again_option in "yes" "no"
		do
			case $framemd5Again_option in
				yes) framemd5_again=yes
				# set again variable to enable loop
				break;;
				no) framemd5_again=no
				break;;
				esac
		done
	fi

	if [[ "$framemd5_again" = yes ]]; then
		logNewLine "Running Framemd5 again" "$CYAN"
	fi

	done
}

#This function will make a QCTools report for video files with the .mp4, .mov and .mkv extensions and save the reports as sidecar files in the Staging Directory and the Tech Specs dir in the ArtFile
function Make_QCT {
	qct_again=yes
	while [[ "$qct_again" = yes ]]
	# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
	do
	SECONDS=0  
	logNewLine "QCTools started! QCTools run on video files in $SDir" "$Bright_Yellow"
	find "$SDir" -type f \( -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.VOB -o -iname \*.avi -o -iname \*.mpg  \) ! -iname "*qctools*" -print0 |  
	while IFS= read -r -d '' i;
		do qcli -i "$i"
		logNewLine "qctools run on $(basename ${i})" "$YELLOW"
	done   
	find "$SDir" -type f \( -iname "*.qctools.xml.gz" -o -iname "*.qctools.mkv" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$sidecardir"
	done
	if [[ -n $(find "${SDir}" -name "*.qctools*" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
	# the -newermt option along with the date command finds files modified within the last 10 seconds.
		duration=$SECONDS
		logNewLine "===================> QCTools complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" "$Bright_Yellow"
		logNewLine "QCTools output copied to $(basename $SDir)" "$YELLOW"
		#prints statement to terminal
		qct_again=no
	else
		logNewLine "No QCTools reports found in $SDir" "$Bright_Red"
		echo -e "\n Run QCTools again? (Choose a number 1-2)"
		select qctAgain_option in "yes" "no"
		do
			case $qctAgain_option in
				yes) qct_again=yes
				# set again variable to enable loop
				break;;
				no) qct_again=no
				break;;
				esac
		done
	fi

	if [[ "$qct_again" = yes ]]; then
		logNewLine "Re-running QCTools again" "$CYAN"
	fi

	done
}