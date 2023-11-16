#!/bin/bash

#I'm trying to start breaking up the processes in the script, so this just the metadata tools that are run on the files
#It requires inputs gathered from the make_dirs_config.sh though, so it's not really a stand a lone script. make_dirs has to be run first.

#User prompts will call the functions from the config file
source `dirname "$0"`/HMSG_auto.config    #this sets the path for the config file, which should be nested next to the script 

#if statement that checks for the variables assigned in the make_dirs script, and if they're not there, redirect to that script?
if [ -z "${ArtFile+x}" ]; 
	then echo "The path to the Artwork File is not set! Run make_dirs.sh to assign an Artwork File?"
	select No_ArtFile_option in "yes" "no" 
	do
		case $No_ArtFile_option in
			yes) echo "Running make_dirs..." && source make_dirs.sh
			break;;
			no) echo "Quitting now..." && exit 1 ;; 
			esac
done; 
else echo "Artwork File is set to '$ArtFile'"; fi

if [ -z "${SDir+x}" ]; 
	then echo "The path to the Staging Directory is not set! Run make_dirs.sh to assign SDir?"
	select No_ArtFile_option in "yes" "no" 
	do
		case $No_ArtFile_option in
			yes) echo "Running make_dirs..." && source make_dirs.sh
			break;;
			no) echo "Quitting now..." && exit 1 ;; 
			esac
done;
else echo "Staging Directory is set to '$SDir'"; fi

#Prompts user to tranfer files to Staging Driectory
#The following select loops set vairable to either "1" or "0". This allows the script to store the user's selection without running the function till the end. 
#At the end fo the script there are if statements that will run the different functions based on the stored answers from the user  
cowsay -s "Copy all files from the volume to the staging directory?"
select Run_Copyit in "yes" "no, only certain directories" "no, specific files" "none"
do
	case $Run_Copyit in
		yes) Run_Copyit=1 && Run_MultiCopy=0
			break;;
		"no, only certain directories") MultiSelect=1 && DeleteList && MultiSelection 
			#Runs DeleteList just in case an exisiting list is already in the ArtFile, because the MultiSelection function will create a new one.
			break;;
		"no, specific files") IndvFiles=1 && DeleteList && SelectFiles
			break;;
		none) Run_Copyit=0 && Run_MultiCopy=0
			break;;
	esac
done  

if [[ "$MultiSelect" -eq "1" ]];
	#this worked
	then 
	echo -e "\n*************************************************\n
Copy $DirsList to:\n ${SDir}?"
	select Run_MultiCopy in "yes" "no"
		do
		case $Run_MultiCopy in
			yes) Run_MultiCopy=1
			break;;
			no) Run_MultiCopy=0
			break;;
		esac
	done
fi  

if [[ "$IndvFiles" -eq "1" ]];
	then 
	echo -e "\n*************************************************\n
Copy $FileList to:\n ${SDir}?"
	select Run_FileCopy in "yes" "no"
		do
		case $Run_FileCopy in
			yes) Run_FileCopy=1
			break;;
			no) Run_FileCopy=0
			break;;
		esac
	done
fi  

#Prompts user to run metadata tools
echo -e "\n*************************************************\n
If you select "yes," this will be the final prompt and applications will run after this response!\n
Otherwise, you will be asked about each tool individually.
\n*************************************************\n"
sleep 1

meta_option_again=yes
while [ "$meta_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
echo -e "Run metadata tools (tree, siegfried, MediaInfo, Exiftool, framemd5, and qctools) on files copied to $SDir (Choose a number 1-2)"
select Meta_option in "yes" "no"
do
	case $Meta_option in
		yes) Run_meta=1 && meta_option_again=no
			break;;
		no) Run_meta=0 && meta_option_again=no
break;;
	esac
done

tree_option_again=yes
while [ "$tree_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
if [[ "$Run_meta" -eq "0"  ]]; then 
echo -e "\n*************************************************\n
Run tree on $Volume (Choose a number 1-2)"
select Tree_option in "yes" "no" "go back a step"
do
	case $Tree_option in
		yes) Run_tree=1 && tree_option_again=no
			#RunTree
			#Runs tree function defined at the top of the doc. 
			break;;
		no) Run_tree=0 && tree_option_again=no
			break;;
		"go back a step") unset Meta_option Run_meta Tree_option && meta_option_again=yes
			break;;
	esac
done
fi  

if [ "$meta_option_again" = yes ]
then echo -e "\n\n!! Going back a step !! \n"
fi
done


sf_option_again=yes
while [ "$sf_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
if [[ "$Run_meta" -eq "0"  ]]; then
#Prompts user to run siegfried file format id
echo -e "\n*************************************************\n
Run siegfried on $SDir (Choose a number 1-2)"
select SF_option in "yes" "no" "go back a step"
do
	case $SF_option in
		yes) Run_sf=1 && sf_option_again=no
		#RunSF 
			#Runs siegfried function defined at the top of the doc. 
			break;;
		no) Run_sf=0 && sf_option_again=no
			break;;
		"go back a step") unset Tree_option Run_tree SF_option && tree_option_again=yes
			break;;
	esac
done  
fi

if [ "$tree_option_again" = yes ]
then echo -e "\n\n!! Going back a step !! \n"
fi
done

mi_option_again=yes
while [ "$mi_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
if [[ "$Run_meta" -eq "0"  ]]; then
#Prompts user to run mediainfo 
echo -e "\n*************************************************\n
Run MediaInfo on video files in $SDir (Choose a number 1-2)"
select MI_option in "yes" "no" "go back a step"
do
	case $MI_option in
		yes) Run_mediainfo=1 && mi_option_again=no
			#RunMI
			#Runs mediainfo function defined at the top of the doc. 
			break;;
		no) Run_mediainfo=0  && mi_option_again=no
			break;;
		"go back a step") unset SF_option Run_sf MI_option && sf_option_again=yes
			break;;
	esac
done
fi

if [ "$sf_option_again" = yes ]
then echo -e "\n\n!! Going back a step !! \n"
fi
done

exif_option_again=yes
while [ "$exif_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
if [[ "$Run_meta" -eq "0"  ]]; then
#Prompts user to run exiftool
echo -e "\n*************************************************\n
Run Exiftool on image files in $SDir (Choose a number 1-2)"
select Exif_option in "yes" "no" "go back a step"
do
	case $Exif_option in
		yes) Run_exif=1 && exif_option_again=no
			break;;
		no) Run_exif=0 && exif_option_again=no
			break;;
		"go back a step") unset MI_option Run_mediainfo Exif_option && mi_option_again=yes
			break;;
	esac
done    
fi

if [ "$mi_option_again" = yes ]
then echo -e "\n\n!! Going back a step !! \n"
fi
done

Fmd5_option_again=yes
while [ "$Fmd5_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
if [[ "$Run_meta" -eq "0" ]]; then
#Prompts user to make framemd5 text files for videos
echo -e "\n*************************************************\n
Create framemd5 text files for each of the video files in $SDir (Choose a number 1-2)"
select Fmd5_option in "yes" "no" "go back a step"
do
	case $Fmd5_option in
		yes) Run_framemd5=1 && Fmd5_option_again=no
#			Make_Framemd5
			#Runs ffmpeg to create 
			break;;
		no) Run_framemd5=0 && Fmd5_option_again=no
			break;;
		"go back a step") unset Exif_option Run_exif Fmd5_option && exif_option_again=yes
			break;;
	esac
done  
fi

if [ "$exif_option_again" = yes ]
then echo -e "\n\n!! Going back a step !! \n"
fi
done

QCT_option_again=yes
while [ "$QCT_option_again" = yes ]
# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
do
if [[ "$Run_meta" -eq "0" ]]; then
#Prompts user to make QCTools reports for ech video file in the staging directory
echo -e "
\n*************************************************\n
This will be the final prompt and applications will run after this response!\n
Create QCTools reports for each of the video files in $SDir (Choose a number 1-2)
\n*************************************************\n"
select QCT_option in "yes" "no" "go back a step"
do
	case $QCT_option in
		yes) Run_QCTools=1
		#Make_QCT
			#Runs QCTools function defined at the top of the doc. 
			break;;
		no) Run_QCTools=0
			break;;
		"go back a step") unset Fmd5_option Run_framemd5 QCT_option && Fmd5_option_again=yes
			break;;
	esac
done
fi

if [ "$Fmd5_option_again" = yes ]
then echo -e "\n\n!! Going back a step !! \n"
fi
done

#The following if statements will check the variable assignements from above to run the desired functions.
#Next step is to change these functions in to bash scripts I think

if [[ "$Run_Copyit" = "1" ]] 
then FindcopyitPath && CopyitVolumeStaging
fi

if [[ "$Run_FileCopy" = "1" ]]
then RunIndvMD5 && CopyFiles && DeleteList
fi

if [[ "$Run_MultiCopy" = "1" ]] 
then FindcopyitPath && CopyitSelected && DeleteList
fi

if [[ "$Run_meta" = "1" ]] 
then RunTree; RunSF; RunMI; RunExif; Make_Framemd5; Make_QCT 
fi

if [[ "$Run_tree" = "1" ]]
then RunTree
fi

if [[ "$Run_sf" = "1" ]]
	then RunSF
fi

if [[ "$Run_mediainfo" = "1" ]]
then RunMI
fi

if [[ "$Run_exif" = "1" ]]
then RunExif
fi

if [[ "$Run_framemd5" = "1" ]]
	then Make_Framemd5
fi

if [[ "$Run_QCTools" = "1" ]]
	then Make_QCT
fi

figlet Fin. 
