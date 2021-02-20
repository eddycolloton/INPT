#!/bin/bash

source HMSG_auto/HMSG_auto.config

figlet Automation!

#Prompts for either identifying the Artwork File or creating one using the function defined earlier. Defines that path as "$ArtFile"
cowsay -W 30 "Does the Artwork File exist? (Choose a number 1-3)"
select ArtFile_option in "yes" "no" "quit"
do
	case $ArtFile_option in
		yes) echo -e "\n*************************************************\n
Input path to Artwork File! \nNavigate to the Artwork Files on the T:/ drive in Finder. 
Next, find the Artwork File, and click through to the directory named: \n'Accession Number_Artwork Title' 
(it is often inside a directory named 'time-based media')
'Drag and drop' the 'Accession Number_Artwork Title' directory into terminal"
			while [[ -z "$ArtFile" ]] ; do 
			read -e ArtFile
#Asks for user input, allows for tab completion of path. might be ok with either a "/" or no "/"?? 
#Assigns user input to the ArtFile variable
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
Input path to Staging Directory on TBMA Drobo
It should be named 'Accession-Number_Artist's Last Name'"
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

#Going straight into disktype seemed weird, decided to add a prompt here...
cowsay -b "Move on to metadata creation? Next step is to identify the device path to run disktype"
select MoveOn_option in "yes" "quit"
do
	case $MoveOn_option in
		yes) echo "Generating diskutil list..." && source make_meta.sh
			break;;
		quit) exit 1 ;;
	esac
done
