#!/bin/bash

InputPath () {
	read -e input
	# Asks for user input and assigns it to variable
	echo -e $input | sed -e 's/[[:space:]]*$//'
	# Strips a trailing space from the input. 
	# If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
	# I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
}

ConfirmInputPath () {
	while [[ "$input_again" = yes ]] ; do
		UserInput=$(InputPath)
        eval $1="$UserInput"
		cowsay "Just checking for typos - Is the path to the $2 entered correctly?"
		logNewLine "The $2 path manually input: ${UserInput}" "$CYAN"
    	IFS=$'\n'; select path_option in "Yes" "No, go back a step" ; do
			if [[ $path_option = "Yes" ]] ; then
				input_again=no
			elif [[ $path_option = "No, go back a step" ]] ; then 
				input_again=no
				unset $1
			fi
    	break           
    	done;

    	if [[ "$input_again" = yes ]] ; then 
			echo -e "Let's try again"
		fi
	done
}

#This function finds the Staging Directory file path
function FindTBMADroBoPath {
	if [[ -z "${TBMADroBoPath}" ]]; then
		if [[ -d /Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork ]]; then
			TBMADroBoPath=/Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork
			echo "found TBMA DroBo at $TBMADroBoPath"
			export TBMADroBoPath="${TBMADroBoPath}"
		else
			cowsay -W 30 "Please input the path to the "Time Based Media Artwork" directory on the TBMA DroBo. Feel free to drag and drop the directory into terminal:"
			if [[ "$typo_check" == true ]] ; then
				input_again=yes
				ConfirmInputPath TBMADroBoPath "TBMA DroBo"
			else
				TBMADroBoPath=$(InputPath)
			fi
			logNewLine "The path to the Time Based Media Artwork directory on the TBMA DroBo manually input: $TBMADroBoPath" "$CYAN"
			export TBMADroBoPath="${TBMADroBoPath}"
		fi
	fi
}

function ConfirmAccession {
	while [[ "$accession_again" = yes ]] ; do
		echo "Enter Accession Number in '####-###' format" && read SDir_Accession
		cowsay "Just checking for typos - Is the Artist's Name entered correctly?"
		IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
			if [[ $accession_option = "Yes" ]] ; then
				accession_again=no
			elif [[ $accession_option = "No, go back a step" ]] ; then
				unset SDir_Accession
			fi
		break           
		done;

		if [[ "$accession_again" = yes ]]; then
			echo -e "Let's try again"
		fi
    done
}

#This function makes the staging directory if one does not exist
function MakeStagingDirectory {
	if [ -z "${accession+x}" ]; then
		while [[ -z "$SDir_Accession" ]] ; do 
			if [[ "$typo_check" == true ]] ; then
				accession_again=yes
				ConfirmAccession
			else
				echo -e "\n*************************************************\nEnter Accession Number in '####.###' format" && read accession
        		#prompts user for accession number and reads input
			fi
		logNewLine "The accession number manually input: ${accession}" "$CYAN"
		export accession="${accession}"
		done;
	else SDir_Accession=`echo "$accession" | sed 's/\./-/g'` ;
	#The sed command replaces the period in the accession variable with a dash. Found it here: https://stackoverflow.com/questions/6123915/search-and-replace-with-sed-when-dots-and-underscores-are-present 
	fi
	mkdir -pv "${TBMADroBoPath%/}"/"$SDir_Accession"_"$ArtistLastName"
	SDir="${TBMADroBoPath%/}"/"$SDir_Accession"_"$ArtistLastName"
	logNewLine "Path to the staging directory: ${SDir}" "$MAGENTA" 
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
			if [[ $SDir_option = "Input path" ]] ; then
				while [[ -z "$SDir" ]] ; do 
					echo -e "\nInput path to Staging Directory:"
					if [[ "$typo_check" == true ]] ; then
						input_again=yes
						ConfirmInputPath SDir "Staging Directory"
					else 
						SDir=$(InputPath)
					export SDir="${SDir}"
					#Confirms that the SDir variable is defined
					logNewLine "Path to the staging directory manually input: ${SDir}" "$CYAN" 
					sleep 1
					fi
				done
			elif [[ $SDir_option = "Create Staging Directory" ]] ; then 
				MakeStagingDirectory
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
