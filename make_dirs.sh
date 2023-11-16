#!/bin/bash

source `dirname "$0"`/HMSG_auto.config    #this sets the path for the config file, which should be nested next to the script 

figlet Automation!

FindArtworkFilePath

InputArtistsName () {
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
IFS=$'\n'; select artdir in $(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Artwork File" "Re-enter artist's name" ; do
#lists options for select command - the IFS statment stops it from escaping when it hits spaces in directory names
  	if [[ $artdir = "Input path" ]]
  		then while [[ -z "$ArtFile" ]] ; do 
		echo "Input path to Artwork File:"
		read -e ArtFileInput
		#Asks for user input and assigns it to variable
		ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
		#Strips a trailing space from the input. 
		#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
		#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
		FindAccessionNumber
		#searches the Artwork File for the accession number, and assigns it to the $accession variable
		sleep 1
  		done
  	elif [[ $artdir = "Create Artwork File" ]]
  		then MakeArtworkFile 
  	elif [[ $artdir = "Re-enter artist's name" ]]
  		then echo "Let's try again"
  		unset ArtistFirstName ArtistLastName 
  		return 1
	else
		ArtFile=$artdir
		#assigns variable to the users selection from the select menu
		echo -e "\n*************************************************\n\nThe Artwork File is $ArtFile\n"
		FindAccessionNumber
		#searches the Artwork File for the accession number, and assigns it to the $accession variable
		sleep 1
	fi
break			
done;
}

until InputArtistsName ; do : ; done
# Got this from here: https://stackoverflow.com/questions/45088696/bash-scripting-can-you-make-a-function-call-itself

FindTBMADroBoPath

InputSDir () {
cowsay "Enter a number to set the path to the Staging Directory on the TBMA DroBo:"
#Prompts for either identifying the staging directory or creating one using the function defined earlier. Defines that path as "$SDir"
IFS=$'\n'; select SDir_option in $(find "${TBMADroBoPath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Staging Directory" "Go back a step" ; do
	if [[ $SDir_option = "Input path" ]]
  		then while [[ -z "$SDir" ]] ; do 
		echo "Input path to Staging Directory:"
		read -e SDirInput 
		#Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
		SDir="$(echo -e "${SDirInput}" | sed -e 's/[[:space:]]*$//')"
		#Strips a trailing space from the input. 
		#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
		#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
		echo -e "\n*************************************************\n\n
Staging Driectory is $SDir \n\n*************************************************\n"
#Confirms that the SDir variable is defined 
		sleep 1
		done
	elif [[ $SDir_option = "Create Staging Directory" ]]
  		then MakeStagingDirectory
		#Runs MakeStagingDirectory function defined in make_meta.config
	elif [[ $SDir_option = "Go back a step" ]]
		then 
			unset ArtistFirstName ArtistLastName ArtFile accession_dir accession title
			InputArtistsName && InputSDir
	else
		SDir=$SDir_option
		#assigns variable to the users selection from the select menu
		echo -e "\n*************************************************\n\nthe Staging Directory is $SDir \n\n*************************************************\n"
	sleep 1
	fi
break			
done;
}

InputSDir


InputVolume () {
#Prompts user input for path to hard drive (or other carrier), defines that path as "$Volume"
cowsay -p -W 31 "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)"
read -e VolumeInput
Volume="$(echo -e "${VolumeInput}" | sed -e 's/[[:space:]]*$//')"
#If the volume name is dragged and dropped into terminal, the trail whitespace can eventually be interpreted as a "\" which breaks the CLI tools called in make_meta.sh. To prevent this, the sed command above is used.
#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
while [[ -z "$Volume" ]] ; do 
	echo -e "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)" && read -e Volume 
done
echo "The volume path is $Volume"
IFS=$'\n'; select volume_check in "continue" "Re-enter volume path" "Go back a step" ; do
#lists options for select command - the IFS statment stops it from escaping when it hits spaces in directory names
  	if [[ $volume_check = "continue" ]]
  		then echo "moving on..."
  	elif [[ $volume_check = "Re-enter volume path" ]]
  		then echo "Let's try again"
  		unset VolumeInput Volume
  		return 1
  	elif [[ $volume_check = "Go back a step" ]]
  		then
  		unset VolumeInput Volume SDirInput SDir SDir_option 
  		InputSDir && InputVolume
  		return 1
	fi
break			
done;
}

until InputVolume ; do : ; done

FindConditionDir
#searches the ArtFile for the Condition Report, and assigns it to the $reportdir variable
sleep 2

FindTechDir
#searches the ArtFile for the Technical Info_Specs directory, and assigns it to the $techdir variable
sleep 2

logName=`date '+%Y-%m-%d-%H.%M.%S'`_"$ArtistLastName"_"$accession"  #the log will be named after the Date (YYYY-MM-DD)
logName+='.log'
logPath="${techdir}/${logName}"
logCreate "${logPath}"
echo -e "The log has been created using the file name $logPath \n \n"
#The log commands are from loglog: https://github.com/amiaopensource/loglog/blob/main/bash_logging.config
sleep 1

logNewLine "make_dirs.sh complete:
----------------------->The artist name is $ArtistFirstName $ArtistLastName
----------------------->The title of the work is $title
----------------------->The accession number is $accession
----------------------->The artwork folder is $ArtFile
----------------------->The staging directory is $SDir
----------------------->The volume path is $Volume"

varfileName=`date '+%Y-%m-%d-%H.%M.%S'`_"$ArtistLastName"_"$accession"  #the file that stores the variables will be named after the the date, artists last name, and the accession number
varfileName+='.varfile'
varfilePath="${techdir}/${varfileName}"
touch "${varfilePath}"
echo 'ArtistFirstName="'"$ArtistFirstName"'"' >> "${varfilePath}"
echo 'ArtistLastName="'"$ArtistLastName"'"' >> "${varfilePath}"
echo 'title="'"$title"'"' >> "${varfilePath}"
echo 'accession="'"$accession"'"' >> "${varfilePath}"
echo 'ArtFile="'"$ArtFile"'"' >> "${varfilePath}"
echo 'SDir="'"$SDir"'"' >> "${varfilePath}"
echo 'Volume="'"$Volume"'"' >> "${varfilePath}"
echo 'techdir="'"$techdir"'"' >> "${varfilePath}"
echo 'sidecardir="'"$sidecardir"'"' >> "${varfilePath}"
echo 'reportdir="'"$reportdir"'"' >> "${varfilePath}"

echo -e "The varfile has been created using the file name $varfilePath \n \n"

source make_meta.sh
