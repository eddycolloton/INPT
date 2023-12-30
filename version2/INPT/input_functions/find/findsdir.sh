#!/bin/bash

#This function finds the Staging Directory file path
function FindTBMADroBoPath {
	if [[ -z "${TBMADroBoPath}" ]]; then
		if [[ -d /Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork ]]; then
			TBMADroBoPath=/Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork
			echo "found TBMA DroBo at $TBMADroBoPath"
			export TBMADroBoPath="${TBMADroBoPath}"
		else
			cowsay -W 30 "Please input the path to the "Time Based Media Artwork" directory on the TBMA DroBo. Feel free to drag and drop the directory into terminal:"
			read -e TBMADroBoPathInput
			#Asks for user input and assigns it to variable
			TBMADroBoPath="$(echo -e "${TBMADroBoPathInput}" | sed -e 's/[[:space:]]*$//')"
			#Strips a trailing space from the input. 
			#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
			#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
			echo "The path to the Staging Directories is: $TBMADroBoPath"
			export TBMADroBoPath="${TBMADroBoPath}"
		fi
	fi
}

#This function makes the staging directory if one does not exist
function MakeStagingDirectory {
	if [ -z "${accession+x}" ]; then
		while [[ -z "$SDir_Accession" ]] ; do 
		echo "Enter Accession Number in '####-###' format" && read SDir_Accession
		done;
	else SDir_Accession=`echo "$accession" | sed 's/\./-/g'` ;
	#The sed command replaces the period in the accession variable with a dash. Found it here: https://stackoverflow.com/questions/6123915/search-and-replace-with-sed-when-dots-and-underscores-are-present 
	fi
	mkdir -pv "${TBMADroBoPath%/}"/"$SDir_Accession"_"$ArtistLastName"
	SDir="${TBMADroBoPath%/}"/"$SDir_Accession"_"$ArtistLastName"
	echo -e "The Staging Directory is $SDir \n"
	export SDir="${SDir}"
}

function FindSDir {
	### Could assume directory with artist's last name in TBMA Artwork folder is the SDir with the FindSDir variable conditional, but this doesn't work when multiple artworks by the same artist are in the TBMA Artwork folder on the DroBo
	#FindSDir=$(find "${TBMADroBoPath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*")
	#if [[ -z "${FindSDir}" ]]; then
		#echo -e "\n*************************************************\n The Staging Driectory was not found!\n"
		cowsay "Enter a number to set the path to the Staging Directory on the TBMA DroBo:"
		#Prompts for either identifying the staging directory or creating one using the function defined earlier. Defines that path as "$SDir"
		IFS=$'\n'; select SDir_option in $(find "${TBMADroBoPath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Staging Directory" ; do
		if [[ $SDir_option = "Input path" ]]
  		then while [[ -z "$SDir" ]] ; do 
			echo "Input path to Staging Directory:"
			read -e SDirInput 
			#Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
			SDir="$(echo -e "${SDirInput}" | sed -e 's/[[:space:]]*$//')"
			#Strips a trailing space from the input. 
			#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
			#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
			export SDir="${SDir}"
			#Confirms that the SDir variable is defined
			logNewLine "Path to the staging directory manually input: ${SDir}" "$CYAN" 
			sleep 1
			done
		elif [[ $SDir_option = "Create Staging Directory" ]]
  		then MakeStagingDirectory
		logNewLine "Path to the staging directory: ${SDir}" "$MAGENTA" 
		#Runs MakeStagingDirectory function defined in make_meta.config
		else
			SDir=$SDir_option
			#assigns variable to the users selection from the select menu
			export SDir="${SDir}"
			logNewLine "Path to the staging directory: ${SDir}" "$MAGENTA" 
			sleep 1
		fi
		break			
		done;
	#else
	#	SDir="${FindSDir}"
	#	export SDir="${SDir}"
	#fi
}


# FindTBMADroBoPath
## Moving functions call to start_input script

#if [[ -z "${SDir}" ]];
#then
	#FindSDir
#fi

