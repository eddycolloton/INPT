#!/bin/bash

#This function runs tree on the Volume sends the output to three text files 
function RunTree {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** tree started ******** \n " >> "${configLogPath}" &&
	#print timestamp and command to log
	echo -e " ******** tree started ******** \n tree running on $Volume \n" &&
	#prints statement to terminal
	tree "$Volume" > "$SDir"/"$accession"_tree_output.txt &&
	echo -e "\n***** tree output ***** \n" >> "${reportdir}/${accession}_appendix.txt" &&
	cat "${SDir}/${accession}_tree_output.txt" >> "${reportdir}/${accession}_appendix.txt" &&
	cp "${SDir}/${accession}_tree_output.txt" "$sidecardir"
	if [[ -f "${SDir}/${accession}_tree_output.txt" ]]; then
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** tree completed ******** \n\n\t\ttree Results:\n\t\tcopied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
		echo -e "\n ******** tree complete ******** \n"
		#prints statement to terminal
	else
		echo -e "\n\n\t\ttree Results:\n\t\txxxxxxxx tree output not found in $SDir xxxxxxxx" >> "${configLogPath}"
		echo -e "\n ******** tree output not found in $SDir ******** \n"
		#prints statement to terminal
	fi
}
 
#This function will create siegfried sidecar files for all files in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunSF {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** siegfried started ******** \n siegfried will be run on $SDir" >> "${configLogPath}" &&
	#prints timestamp to log
	echo -e " ******** siegfried started ******** \n siegfried will be run on $SDir \n" &&
	#prints statement to terminal
	find "$SDir" -type f \( -iname "*.*" ! -iname "*.md5" ! -iname "*_output.txt" ! -iname "*.DS_Store" ! -iname "*_manifest.txt" ! -iname "*_sf.txt" ! -iname "*_exif.txt" ! -iname "*_mediainfo.txt" ! -iname "*_qctools.mkv" ! -iname "*_framemd5.txt" ! -iname "*.log" \) -print0 | 
	while IFS= read -r -d '' i; do
		sf "$i" > "${i%.*}_sf."txt 
		echo -e "\t$(date "+%Y-%m-%d - %H.%M.%S") sf run on ${i}" >> "${configLogPath}"
	#runs sf on all files in the staging directory except files that were made earlier in this workflow (md5 manifest, disktype, tree, and DS_Stores) 
	#The "for" loop was not working with this command. I found the IFS solution online, but honestly don't totally understand how it works.
	done && 
	find "$SDir" -type f \( -iname "*_sf.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do 
		cp "$t" "$sidecardir"
		echo -e "\n***** siegfried output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
		cat "$t" >> "${reportdir}/${accession}_appendix.txt"
	done 
	if [[ -n $(find "${SDir}" -name "*_sf.txt") ]] ; then 
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** siegfried completed ******** \n\n\t\tsf Results:\n\t\tcopied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
		echo -e "\n ******** sf complete ******** \n"
		#prints statement to terminal
	else 
		echo -e "\n\n\t\tsf Results:\n\t\txxxxxxxx No siegfried files found in $SDir xxxxxxxx" >> "${configLogPath}"
		echo -e "\n ******** sf output not found in $SDir ******** \n"
		#prints statement to terminal
	fi
}

#This function will create MediaInfo sidecar files for all files with .mp4, .mov and .mkv file extensions in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunMI {
	SECONDS=0 &&
echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** MediaInfo started ******** \nMediaInfo will be run on audio and video files in $SDir" >> "${configLogPath}" &&
	#print timestamp and command to log
	echo -e " ******** MediaInfo started ******** \n MediaInfo will be run on audio and video files in $SDir \n" &&
	#prints statement to terminal
	find "$SDir" -type f \( -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.VOB -o -iname \*.avi -o -iname \*.mpg -o -iname \*.wav -o -iname \*.mp3 \) -print0 |  
	while IFS= read -r -d '' i;
		do  
			mediainfo -f "$i" > "${i%.*}_mediainfo".txt
			#echo -e "\n***** mediainfo -f output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			#mediainfo -f "$i" >> "${reportdir}/${accession}_appendix.txt"
			#I have been running mediainfo twice, which is too costly for large files. I have added the echo and cat commands to the next while loop to simply cat the sidecars into the appendix. I'm leaving the old code here while I test further. 
			echo -e "\t$(date "+%Y-%m-%d - %H.%M.%S") mediainfo run on ${i}" >> "${configLogPath}"
	done &&
	find "$SDir" -type f \( -iname "*_mediainfo.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$sidecardir"
		echo -e "\n***** mediainfo -f output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
		cat "$t" >>  "${reportdir}/${accession}_appendix.txt"
	done
	if [[ -n $(find "${SDir}" -name "*_mediainfo.txt") ]]; then 
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** MediaInfo completed ******** \n\n\t\tMediaInfo Results:\n\t\tcopied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
		echo -e "\n ******** MediaInfo complete ******** \n"
		#prints statement to terminal
	else 
		echo -e "\n\n\t\tMediaInfo Results:\n\t\txxxxxxxx No MediaInfo files found in $SDir xxxxxxxx" >> "${configLogPath}"
		echo -e "\n ******** MediaInfo output not found in $SDir ******** \n"
		#prints statement to terminal
	fi
}

#This function will create Exiftool sidecar files for all files with .jpg, .jpeg, .png and .tiff file extensions in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunExif {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** Exiftool started ******** \nExiftool will be run on files in $SDir" >> "${configLogPath}" &&
	#print timestamp and command to log
	echo -e "******** Exiftool started ******** \n Exiftool will be run on files in $SDir \n" &&
	#prints statement to terminal
	find "$SDir" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.tiff \) -print0 |  
	while IFS= read -r -d '' i;
		do  
			exiftool "$i" > "${i%.*}_exif".txt
			#echo -e "\n***** Exiftool output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			#exiftool "$i" >> "${reportdir}/${accession}_appendix.txt" 
			#I've moved these two commands to the next while loop, just as I have with mediainfo, see comment in RunMI function
			echo -e "\t$(date "+%Y-%m-%d - %H.%M.%S") exiftool run on ${i}" >> "${configLogPath}"
	done &&
	find "$SDir" -type f \( -iname "*_exif.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do 
			cp "$t" "$sidecardir"
			echo -e "\n***** Exiftool output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			cat "$t" >> "${reportdir}/${accession}_appendix.txt"
	done
	if [[ -n $(find "${SDir}" -name "*_exif.txt") ]]; then
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** Exiftool completed ******** \n\n\t\tExiftool Results:\n\t\treports copied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
		echo -e "\n ******** Exiftool complete ******** \n"
		#prints statement to terminal
	else
		echo -e "\n\n\t\tExiftool Results:\n\t\txxxxxxxx No exiftool files found in $SDir xxxxxxxx" >> "${configLogPath}"
		echo -e "\n ******** Exiftool output not found in $SDir ******** \n"
		#prints statement to terminal
	fi 
}

#This function will make a text file containing md5 checksums of each frame of any video files in the Staging Directory. The output will be saved as a side car file in the Staging Directory and the Tech Specs dir in the ArtFile
function Make_Framemd5 {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** framemd5 started ******** \nframemd5 will be run on video files in $SDir" >> "${configLogPath}" &&
	#print timestamp and command to log
	echo -e " ******** framemd5 started ******** \n framemd5 will be run on video files in $SDir" &&
	#prints statement to terminal
	find "$SDir" -type f \( -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.avi -o -iname \*.VOB -o -iname \*.mpg -o -iname \*.wav -o -iname \*.flac -o -iname \*.mp3 -o -iname \*.aac -o -iname \*.wma -o -iname \*.m4a \) -print0 |  
	while IFS= read -r -d '' i;
		do   
			ffmpeg -nostdin -i "$i" -f framemd5 -an  "${i%.*}_framemd5".txt 
			echo -e "\t$(date "+%Y-%m-%d - %H.%M.%S") framemd5 run on ${i}" >> "${configLogPath}" 
	done && 
	find "$SDir" -type f \( -iname "*_framemd5.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$sidecardir"
	done
	if [[ -n $(find "${SDir}" -name "*_framemd5.txt") ]]; then
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** framemd5 completed ******** \n\n\t\tFramemd5 Results:\n\t\treports copied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
		echo -e "\n ******** Framemd5 complete ******** \n"
		#prints statement to terminal
	else
		echo -e "\n\n\t\tFramemd5 Results:\n\t\txxxxxxxx No framemd5 files found in $SDir xxxxxxxx" >> "${configLogPath}"
		echo -e "\n ******** Framemd5 output not found in $SDir ******** \n"
		#prints statement to terminal
	fi
}

#This function will make a QCTools report for video files with the .mp4, .mov and .mkv extensions and save the reports as sidecar files in the Staging Directory and the Tech Specs dir in the ArtFile
function Make_QCT {
	SECONDS=0 &&
	echo -e "\n$(date "+%Y-%m-%d - %H.%M.%S") ******** QCTools started ******** \nQCTools run on video files in $SDir" >> "${configLogPath}" &&
	#print timestamp and command to log
	echo -e "******** QCTools started ******** \n QCTools run on video files in $SDir" &&
	#prints statement to terminal
	find "$SDir" -type f \( -iname \*.mov -o -iname \*.mkv -o -iname \*.mp4 -o -iname \*.VOB -o -iname \*.avi -o -iname \*.mpg \) -print0 |  
	while IFS= read -r -d '' i;
		do qcli -i "$i"
		echo -e "\t$(date "+%Y-%m-%d - %H.%M.%S") qctools run on ${i}" >> "${configLogPath}"
	done && 
	find "$SDir" -type f \( -iname "*.qctools.xml.gz" -o -iname "*.qctools.mkv" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$sidecardir"
	done
	if [[ -n $(find "${SDir}" -name "*.qctools*") ]]; then
		echo -e "$(date "+%Y-%m-%d - %H.%M.%S") ******** QCTools completed ******** \n\n\t\tQCTools Results:\n\t\treports copied to ${SDir} and \n\t\t${reportdir}/${accession}_appendix.txt" >> "${configLogPath}" &&
		#prints timestamp once the command has exited
		duration=$SECONDS
		echo -e "\t\t===================> Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s" >> "${configLogPath}"
		echo -e "\n ******** QCTools complete ******** \n"
		#prints statement to terminal
	else
		echo -e "\n\n\t\tQCTools Results:\n\t\txxxxxxxx No QCTools reports found in $SDir xxxxxxxx" >> "${configLogPath}"
		echo -e "\n ******** QCTools output not found in $SDir ******** \n"
		#prints statement to terminal
	fi 
}