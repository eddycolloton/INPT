#!/bin/bash

#I'm trying to start breaking up the processes in the script, so this just the metadata tools that are run on the files
#It requires inputs gathered from the make_dirs_config.sh though, so it's not really a stand a lone script. make_dirs has to be run first.
#I should start this script with an if statement that checks for the variables assigned in the make_dirs script, and if they're not there, redirect to that script...

#User prompts will call the functions from the config file
source make_meta.config

#Title card
figlet Automation!

#Prompts user input for path to hard drive (or other carrier), defines that path as "$Device"
diskutil list
echo -e "\n*************************************************\n
Input the path to the device - Should be '/dev/disk#' "
read -e Device
while [[ -z "$Device" ]] ; do
	echo -e "\n*************************************************\n
Input the path to the device - Should be '/dev/disk#' " && read -e Device
done
echo "The device path is $Device"

#Prompts user that disktype is being run? Not sure about this...
#Prompts user that disktype is being run? Not sure about this...
echo -e "\n*************************************************\n
Run disktype on $Device (Choose a number 1-2)"
select Disktype_option in "yes" "no"
do
	case $Disktype_option in
		yes) Run_disktype=1
			#disktype
			#Should run disktype on device path and then pipe output to tee, copy output to Staging Directory, Tech Specs dir in ArtFile and appendix in ArtFile
			break;;
		no) Run_disktype=0
break;;
	esac
done  

#Prompts user to run tree
echo -e "\n*************************************************\n
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

#Prompts user to make QCTools reports for ech video file in the staging directory
echo -e "\n*************************************************\n
Create QCTools reports for each of the video files in $SDir (Choose a number 1-2)"
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

#The following if statements will check the variable assignements from above to run the desired functions.
#Next step is to change these functions in to bash scripts I think

if [ $Run_disktype = 1 ] 
then disktype
fi

if [ $Run_tree = 1 ]
then RunTree
fi

if [ $Run_sf = 1 ]
	then RunSF
fi

if [ $Run_mediainfo = 1 ]
then RunMI
fi

if [ $Run_framemd5 = 1 ]
	then Make_Framemd5
fi

if [ $Run_QCTools = 1 ]
	then Make_QCT
fi

figlet Fin.  
