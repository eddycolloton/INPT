#!/bin/bash

function SelectTools {
	#Prompts user to run metadata tools
	echo -e "\n*************************************************\n
If you select "yes," this will be the final prompt and applications will run after this response!\n
Otherwise, you will be asked about each tool individually.
\n*************************************************\n"
	sleep 1
	echo -e "Run metadata tools (tree, siegfried, MediaInfo, Exiftool, framemd5, and qctools) on files copied to $SDir (Choose a number 1-2)"
	select Meta_option in "yes" "no"
	do
		case $Meta_option in
			yes) Run_meta=1
				break;;
			no) Run_meta=0
	break;;
		esac
	done

	if [[ "$Run_meta" -eq "0"  ]]; 
		then echo -e "\n*************************************************\n
	Run tree on $Volume (Choose a number 1-2)"
	select Tree_option in "yes" "no"
	do
		case $Tree_option in
			yes) Run_tree=1
	#RunTree
				#Runs tree function defined at the top of the doc. 
				break;;
			no) Run_tree=0
	break;;
		esac
	done
	fi  


	if [[ "$Run_meta" -eq "0"  ]]; then
	#Prompts user to run siegfried file format id
	echo -e "\n*************************************************\n
	Run siegfried on $SDir (Choose a number 1-2)"
	select SF_option in "yes" "no"
	do
		case $SF_option in
			yes) Run_sf=1
			#RunSF 
				#Runs siegfried function defined at the top of the doc. 
				break;;
			no) Run_sf=0
	break;;
		esac
	done  
	fi


	if [[ "$Run_meta" -eq "0"  ]]; then
	#Prompts user to run mediainfo 
	echo -e "\n*************************************************\n
	Run MediaInfo on video files in $SDir (Choose a number 1-2)"
	select MI_option in "yes" "no"
	do
		case $MI_option in
			yes) Run_mediainfo=1
	#RunMI
				#Runs mediainfo function defined at the top of the doc. 
				break;;
			no) Run_mediainfo=0
	break;;
		esac
	done
	fi


	if [[ "$Run_meta" -eq "0"  ]]; then
	#Prompts user to run exiftool
	echo -e "\n*************************************************\n
	Run Exiftool on image files in $SDir (Choose a number 1-2)"
	select Exif_option in "yes" "no"
	do
		case $Exif_option in
			yes) Run_exif=1
	#RunMI
				#Runs mediainfo function defined at the top of the doc. 
				break;;
			no) Run_exif=0
	break;;
		esac
	done    
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
	#Prompts user to make framemd5 text files for videos
	echo -e "\n*************************************************\n
	Create framemd5 text files for each of the video files in $SDir (Choose a number 1-2)"
	select Fmd5_option in "yes" "no"
	do
		case $Fmd5_option in
			yes) Run_framemd5=1
	#Make_Framemd5
				#Runs ffmpeg to create 
				break;;
			no) Run_framemd5=0
	break;;
		esac
	done  
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
	#Prompts user to make QCTools reports for ech video file in the staging directory
	echo -e "
	\n*************************************************\n
	This will be the final prompt and applications will run after this response!\n
	Create QCTools reports for each of the video files in $SDir (Choose a number 1-2)
	\n*************************************************\n"
	select QCT_option in "yes" "no"
	do
		case $QCT_option in
			yes) Run_QCTools=1
			#Make_QCT
				#Runs QCTools function defined at the top of the doc. 
				break;;
			no) Run_QCTools=0
	break;;
		esac
	done
	fi
}
