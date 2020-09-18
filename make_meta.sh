#!/bin/bash

#User prompts will call the functions from the config file
source make_meta.config

#Title card
figlet Automation!

#Prompts for either identifying the Artwork File or creating one using the function defined earlier. Defines that path as "$ArtFile"
cowsay -W 30 "Does the Artwork File exist? (Choose a number 1-3)"
select ArtFile_option in "yes" "no" "quit"
do
	case $ArtFile_option in
		yes) echo -e "\n*************************************************\n
Input path to Artwork File. \nThe directory name should be: \n'Accession Number_Artwork Title' "
		#Asks for user input, allows for tab completion of path
			read -e ArtFile 
			##Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
			#Assigns user input to the ArtFile variable
			while [[ -z "$ArtFile" ]] ; do 
					echo -e "\n*************************************************\n
Input path to Artwork File. \nThe directory name should be: \n'Accession Number_Artwork Title' " &&
read -e ArtFile
				done
			echo -e "\n*************************************************\n
The Artwork File is $ArtFile"
			break;;
		no) MakeArtworkFile 
			break;;
		quit) exit 1 ;;
	esac
done

#Prompts for either identifying the staging directory or creating one using the function defined earlier. Defines that path as "$SDir"
cowsay "Does the Staging Directory exist? (Choose a number 1-3)"
select SDir_option in "yes" "no" "quit"
do
	case $SDir_option in
		yes) echo -e "\n*************************************************\n
Input path to Staging Directory"
		#Asks for user input, allows for tab completion of path
			read -e SDir 
			#Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
			#Confirms that the SDir variable is defined 
			echo -e "\n*************************************************\n
Staging Driectory is $SDir"
			break;;
		no) MakeStagingDirectory
			break;;
		quit) exit 1 ;;
	esac
done

#Prompts user input for path to hard drive (or other carrier), defines that path as "$Volume"
cowsay -p -W 31 "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)"
read -e Volume
while [[ -z "$Volume" ]] ; do 
	echo -e "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)" && read -e Volume 
done
echo "The volume path is $Volume"

#Uses the function defined at the top to copy media from the (now defined) variable Volume to the (now defined) variable Staging Directory
cowsay -s "Copy all files from the volume to the staging directory?"
select Copy_option in "yes" "no" "quit"
do
	case $Copy_option in
		yes) CopyitVolumeStaging
			break;;
		no) break;;
		quit) exit 1 ;;
		esac
	done

#Going straight into disktype seemed weird, decided to add a prompt here...
cowsay -b "Move on to metadata creation? Next step is to identify the device path to run disktype"
select MoveOn_option in "yes" "quit"
do
	case $MoveOn_option in
		yes) echo "Generating diskutil list..."
			break;;
		quit) exit 1 ;;
	esac
done

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
echo -e "\n*************************************************\n
Run disktype on $Device (Choose a number 1-2)"
select Disktype_option in "yes" "no"
do
	case $Disktype_option in
		yes) disktype
			#Should run disktype on device path and then pipe output to tee, copy output to Staging Directory, Tech Specs dir in ArtFile and appendix in ArtFile
			break;;
		no) break;;
	esac
done  

#Prompts user to run tree
echo -e "\n*************************************************\n
Run tree on $Volume (Choose a number 1-2)"
select Tree_option in "yes" "no"
do
	case $Tree_option in
		yes) RunTree
			#Runs tree function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done  

#Prompts user to run siegfried file format id
echo -e "\n*************************************************\n
Run siegfried on $SDir (Choose a number 1-2)"
select SF_option in "yes" "no"
do
	case $SF_option in
		yes) RunSF
			#Runs siegfried function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done  

#Prompts user to run mediainfo 
echo -e "\n*************************************************\n
Run MediaInfo on video files in $SDir (Choose a number 1-2)"
select MI_option in "yes" "no"
do
	case $MI_option in
		yes) RunMI
			#Runs mediainfo function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done  

#Prompts user to make framemd5 text files for videos
echo -e "\n*************************************************\n
Create framemd5 text files for each of the video files in $SDir (Choose a number 1-2)"
select Fmd5_option in "yes" "no"
do
	case $Fmd5_option in
		yes) Make_Framemd5
			#Runs ffmpeg to create 
			break;;
		no) break;;
	esac
done  

#Prompts user to make QCTools reports for ech video file in the staging directory
echo -e "\n*************************************************\n
Create QCTools reports for each of the video files in $SDir (Choose a number 1-2)"
select QCT_option in "yes" "no"
do
	case $QCT_option in
		yes) Make_QCT
			#Runs QCTools function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done

figlet Fin.  
