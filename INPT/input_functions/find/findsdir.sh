#!/bin/bash

# This function finds the Staging Directory file path
function FindTBMADroBoPath {
	if [[ -z "${TBMADroBoPath}" ]]; then
		if [[ -d /Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork ]]; then
			TBMADroBoPath=/Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork
			echo "found TBMA DroBo at $TBMADroBoPath"
			export TBMADroBoPath="${TBMADroBoPath}"
		else
			ConfirmInput TBMADroBoPath "Please input the path to the "Time Based Media Artwork" directory on the TBMA DroBo. Feel free to drag and drop the directory into terminal:"
			export TBMADroBoPath="${TBMADroBoPath}"
		fi
	fi
}

# This function makes the staging directory if one does not exist
function MakeStagingDirectory {
	if [ -z "${accession+x}" ]; then
		ConfirmInput accession "For new acquisitions, enter accession number in '####.###' format"
	fi
	SDir_Accession=`echo "$accession" | sed 's/\./-/g'` ;
	# The sed command replaces the period in the accession variable with a dash. Found it here: https://stackoverflow.com/questions/6123915/search-and-replace-with-sed-when-dots-and-underscores-are-present 
	mkdir -pv "${TBMADroBoPath%/}"/"$SDir_Accession"_"$ArtistLastName"
	SDir="${TBMADroBoPath%/}"/"$SDir_Accession"_"$ArtistLastName"
	logNewLine "Path to the staging directory: ${SDir}" "$MAGENTA" 
	export SDir="${SDir}"
}

function FindSDir {
	cowsay "Enter a number to set the path to the Staging Directory on the TBMA DroBo:"
	# Prompts for either identifying the staging directory or creating one using the function defined earlier. Defines that path as "$SDir"
	IFS=$'\n'; select SDir_option in $(find "${TBMADroBoPath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Staging Directory" ; do
		if [[ $SDir_option = "Input path" ]] ; then
			ConfirmInput SDir "Input path to Staging Directory:"
			export SDir="${SDir}"
		elif [[ $SDir_option = "Create Staging Directory" ]] ; then 
			MakeStagingDirectory
		else
			SDir=$SDir_option
			# assigns variable to the users selection from the select menu
			export SDir="${SDir}"
			logNewLine "Path to the staging directory: ${SDir}" "$MAGENTA" 
			sleep 1
		fi
	break			
	done;
}
