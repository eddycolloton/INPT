#!/bin/bash

source HMSG_auto/HMSG_auto.config

figlet Automation!

echo -e "\n*************************************************\n
Input artist's first name"
	read -e ArtistFirstName
	#Asks for user input and assigns it to variable
echo -e "\n*************************************************\n
Input artist's last name"
	read -e ArtistLastName
	#Asks for user input and assigns it to variable
	echo -e "\n Artist name is $ArtistFirstName $ArtistLastName"
cowsay -W 30 "Enter a number to set the path to the Artwork File on the T:\ drive:"
#prompt for select command
IFS=$'\n'; select artdir in $(find /path/to/artworkfiles/ -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Artwork File" ; do
#lists options for select command - the IFS statment stops it from escaping when it hits spaces in directory names
  	if [[ $artdir = "Input path" ]]
  	then while [[ -z "$ArtFile" ]] ; do 
		read -e ArtFile
		#Asks for user input and assigns it to variable
		FindAccessionNumber
		#searches the Artwork File for the accession number, and assigns it to the $accession variable
  		done
  	elif [[ $artdir = "Create Artwork File" ]]
  	then MakeArtworkFile 
	else
		ArtFile=$artdir
		#assigns variable to the users selection from the select menu
		#NEED TO CHANGE! THIS ASSIGNS ART FILE TO PARENT DIRECTORY, SHOULD BE "title_accession" DIR!
		echo -e "\n*************************************************\n\nThe Artwork File is $ArtFile\n"
		FindAccessionNumber
		#searches the Artwork File for the accession number, and assigns it to the $accession variable
	fi
break			
done;

cowsay "Enter a number to set the path to the Staging Directory on the TBMA DroBo:"
#Prompts for either identifying the staging directory or creating one using the function defined earlier. Defines that path as "$SDir"
IFS=$'\n'; select SDir_option in $(find /Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork/ -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Staging Directory" ; do
	if [[ $SDir_option = "Input path" ]]
  	then while [[ -z "$SDir" ]] ; do 
		read -e SDir 
		#Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
		echo -e "\n*************************************************\n\n
Staging Driectory is $SDir \n\n*************************************************\n"
#Confirms that the SDir variable is defined 
		done
	elif [[ $SDir_option = "Create Staging Directory" ]]
  	then MakeStagingDirectory
	#Runs MakeStagingDirectory function defined in make_meta.config
	else
		SDir=$SDir_option
		#assigns variable to the users selection from the select menu
		echo -e "\n*************************************************\n\nthe Staging Directory is $SDir \n\n*************************************************\n"
	fi
break			
done;

echo -e "Show diskutil list? \n"
select dlist in "Yes, show diskutil list" "No, I already know the device path"
	do
		case $dlist in
			"Yes, show diskutil list") 
				 echo "Generating list..."
				 diskutil list
			break;;
			"No, I already know the device path") echo "Moving on..."
			break;;
		esac
	done

#Prompts user input for path to hard drive (or other carrier), defines that path as "$Device"
#diskutil list
while [[ -z "$Device" ]] ; do
	cowsay -p -W 31 "Input the path to the device - Should be '/dev/disk#' " 
	read -e Device
done
echo -e "The device path is $Device \n"

#Prompts user input for path to hard drive (or other carrier), defines that path as "$Volume"
cowsay -p -W 31 "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)"
read -e Volume
while [[ -z "$Volume" ]] ; do 
	echo -e "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)" && read -e Volume 
done
echo "The volume path is $Volume"

source make_meta.sh
