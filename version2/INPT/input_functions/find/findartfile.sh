#!/bin/bash

set -a

# Find Artwork File:
	
	#if artfile var exists, do nothing
	#else, search art files for artist last name
		#if none found:
			#use options from make_dirs
		#if multiple found
			#check inside artwork folder for accession number
		#else
			#assign artwork file and get accession (if empty)	

#This function finds the Artwork file path
function FindArtworkFilesPath {
	if [[ -z "${ArtFilePath}" ]]; then
		if [[ -d /Volumes/hmsg/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/hmsg/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES 
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$Bright_Blue"
		elif [[ -d /Volumes/SHARED/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/SHARED/DEPARTMENTS/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$Bright_Blue"
		elif [[ -d /Volumes/shared/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$Bright_Blue"
		elif [[ -d /Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$Bright_Blue"
		else
			cowsay -W 30 "Please input the path to the ARTWORK FILES directory from the T:\ drive. Feel free to drag and drop the directory into terminal:"
			read -e ArtFilePath
			logNewLine "The path to the Artwork Files is: $ArtFilePath" "$Bright_Blue"
		fi
		export ArtFilePath="${ArtFilePath}"
	fi
}

#This function makes the nested directores of a Time-based Media Artwork File
function MakeArtworkFile {
	while [[ -z "$accession" ]] ; do
		accession_again=yes
    	while [[ "$accession_again" = yes ]] ; do
			echo "Enter Accession Number in '####.###' format" && read accession
			#prompts user for accession number and reads input
			logNewLine "The accession number manually input: ${accession}" "$CYAN"
			echo -e "\nIs the accession number correct?"
		    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
		    if [[ $accession_option = "Yes" ]] ;
		        then
		            accession_again=no
		    elif [[ $accession_option = "No, go back a step" ]] ;
		        then 
		            unset accession
		    fi
		    break           
		    done;

		    if [[ "$accession_again" = yes ]]
		    then echo -e "Let's try again"
		    fi
		done
		export accession="${accession}"
	done
	while [[ -z "$title" ]] ; do
		title_again=yes
    	while [[ "$title_again" = yes ]] ; do
			echo "Enter Artwork Title" && read title
			#prompts user for artwork title and reads input
			logNewLine "The title manually input: ${title}" "$CYAN"
			echo -e "\nIs the title correct?"
		    IFS=$'\n'; select title_option in "Yes" "No, go back a step" ; do
		    if [[ $title_option = "Yes" ]] ;
		        then
		            title_again=no
		    elif [[ $title_option = "No, go back a step" ]] ;
		        then 
		            unset title
		    fi
		    break           
		    done;

		    if [[ "$title_again" = yes ]]
		    then echo -e "Let's try again"
		    fi
		done
		export title="${title}"
	done
	mkdir -pv "${ArtFilePath%/}"/"$ArtistLastName"", ""$ArtistFirstName"/"time-based media"/"$accession""_""$title"/{"Acquisition and Registration","Artist Interaction","Cataloging","Conservation"/{"Condition_Tmt Reports","DAMS","Equipment Reports"},"Iteration Reports_Exhibition Info"/"Equipment Reports","Photo-Video Documentation","Research"/"Correspondence","Technical Info_Specs"/{"Past installations_Pics","Sidecars"},"Trash"}
	#creates Artwork File directories
	#I've removed the path to the HMSG shared drive below for security reasons
	ArtFile="${ArtFilePath%/}"/"$ArtistLastName"", ""$ArtistFirstName"/
	#assigns the ArtFile variable to the artwork file just created 
	#I've removed the path to the HMSG shared drive below for security reasons
	logNewLine "The artwork file has been created: ${ArtFile}" "$Bright_Green"
	export ArtFile="${ArtFile}"
} 

#this function searches the artwork folder for the accession number, if there is one, it retrieves it, if there isn't it requests one from the user
function FindAccessionNumber {
IFS=$'\n'
title_dir_results=$(find "${ArtFile}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \) -print0 | xargs -0 -L 1  | wc -l | xargs)
#uses find command to identify directories that have numbers in the name AND a . OR a -, then prints them. The first xargs command creates line breaks between the results
#I don't know how xargs works, I got that bit from https://stackoverflow.com/questions/20165321/operating-on-multiple-results-from-find-command-in-bash
#wc -l counts the lines from the output of the find command, this should give the number of directories found that have an accession number in them
#The final xargs removes white space from the output of wc so that theoutput can be evalutated by the "if" statement below

if [ "$title_dir_results" \> 1 ]; then
	#If the variable title_dir_results stores more than one result
	#This is to determine if there is more than one dir in the ArtFile that has an accession number (typically means there are two artworks by the same artist)
	echo -e "\nCannot find accession number in Artwork File directories"
	accession_again=yes
	while [[ "$accession_again" = yes ]] ; do
		echo "\n*************************************************\nInput accession number" && read accession
		#prompts user for accession number and reads input
		logNewLine "The accession number manually input: ${accession}" "$CYAN"
		echo -e "\nIs the accession number correct?"
	    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
	    if [[ $accession_option = "Yes" ]] ;
	        then
	            accession_again=no
	    elif [[ $accession_option = "No, go back a step" ]] ;
	        then 
	            unset accession
	    fi
	    break           
	    done;

	    if [[ "$accession_again" = yes ]]
	    then echo -e "Let's try again"
	    fi
	done
	export accession="${accession}"
	accession_dir=$(find "${ArtFile}" -mindepth 0 -maxdepth 4 -type d -iname "*${accession}*")
	#defines the accession_dir variable as a directory stored inside the ArtFile that has the accession number in it's name
	#This is to define a more specific variable, if there is more than one artwork in the ArtFile
	if [[ -z "${accession_dir}" ]]; then
	#if the accession_dir variable is empty
	#This var will typically be empty if the find command did not return a result
		while [[ -z "$title" ]] ; do
			title_again=yes
	    	while [[ "$title_again" = yes ]] ; do
				echo "\n*************************************************\nInput the artwork's title" && read title
				#prompts user for artwork title and reads input
				logNewLine "The title manually input: ${title}" "$CYAN"
				echo -e "\nIs the title correct?"
			    IFS=$'\n'; select title_option in "Yes" "No, go back a step" ; do
			    if [[ $title_option = "Yes" ]] ;
			        then
			            title_again=no
			    elif [[ $title_option = "No, go back a step" ]] ;
			        then 
			            unset title
			    fi
			    break           
			    done;

			    if [[ "$title_again" = yes ]]
			    then echo -e "Let's try again"
			    fi
			done
			export title="${title}"
		done
		accession_dir=$(find "${ArtFile}" -mindepth 0 -maxdepth 4 -type d -iname "*${title}*")
		#defines the accession_dir variable as a directory stored inside the ArtFile that has the title in it's name
		#This is to define a more specific variable, if there is more than one artwork in the ArtFile, or the directory is named in a way that is unexpected (i.e. with no accession number or accession number written ##-##)
		if [[ -z "${accession_dir}" ]]; then
		#if the accession_dir variable is empty
			echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure.\nCannot find the parent directory from the title or accession number directory.\nChoose the directory that will store the Technical Info_Specs directory and the Condition_Tmt Reports directory.\nSee directories listed below:\n"
			sleep 1
			tree "$ArtFile"
			sleep 2
			cowsay "Select a directory, or choose to quit:"
			#prompt for select command
			IFS=$'\n'; select parentdir_option in "$ArtFile" "Enter path to parent directory" "Quit" ; do
			#lists options for select command. The IFS statment stops it from escaping when it hits spaces in directory names
			case $parentdir_option in 
				"$ArtFile") accession_dir="$ArtFile"
				#if ArtFile is selected, it is assigned the variable $accession_dir
					echo "The Artwork File is $accession_dir"
				break;;
				"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
					read -e parentdir_input &&
					#reads user input and assigns it to the variable $reportdir_parent
					accession_dir="$(echo -e "${parentdir_input}" | sed -e 's/[[:space:]]*$//')"
					#Strips a trailing space from the input. 
					#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
					#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
					echo "The Artwork File is now $accession_dir"
				break;;
				"Quit") echo "Quitting now..." && exit 1
				#ends the script, exits
			esac	
		done;
		unset IFS
		else echo "The Artwork File is now $accession_dir"
		fi
	else echo "The Artwork File is now $accession_dir"
	fi
fi

if [[ -z "${accession}" ]]; then
#if the accession variable is not assigned, and there are numbers in the titledir name 
	titledir=$(find "$ArtFile" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \))
	#looks in the ArtFile for a directory with numbers in the name, if it finds one, AND it has a period OR a dash in the directory name, it assigns that to the titledir variable
	if [[ -z "$titledir" ]]; then 
	#if the $titledir variable is empty, then
		echo -e "\nCannot find accession number in Artwork File directories"
		accession_again=yes
		while [[ "$accession_again" = yes ]] ; do
			echo "\n*************************************************\nInput accession number" && read accession
			#prompts user for accession number and reads input
			logNewLine "The accession number manually input: ${accession}" "$CYAN"
			echo -e "\nIs the accession number correct?"
		    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
			    if [[ $accession_option = "Yes" ]] ;
			        then
			            accession_again=no
			    elif [[ $accession_option = "No, go back a step" ]] ;
			        then 
			            unset accession
			    fi
			    break           
		    done;

		    if [[ "$accession_again" = yes ]]
		    then echo -e "Let's try again"
		    fi
		done
		export accession="${accession}"
	fi
	acount=$(echo "$titledir" | grep -oE '[0-9]')
	#this grep command prints every digit it finds in titledir on a new line, and assigns that output to the variable "acount"
	if [[ $(echo "$acount" | wc -l) =~ 3 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 3, then
		accession=`echo $titledir | sed 's/^.*\([0-9][0-9].[0-9]\).*$/\1/' ` 
		#sed command cuts everything before and after ##.# in the titledir variable name. I got the sed command from https://unix.stackexchange.com/questions/243207/how-can-i-delete-everything-until-a-pattern-and-everything-after-another-pattern/243236
		if [[  $(echo -n "$accession" | wc -c) =~ 4 ]]; then
			logNewLine "The accession number is ${accession} found in the artwork folder ${titledir}" "$Bright_Green"
			export accession="${accession}"
		else
			echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
			accession_again=yes
			while [[ "$accession_again" = yes ]] ; do
				echo "\n*************************************************\nInput accession number" && read accession
				#prompts user for accession number and reads input
				logNewLine "The accession number manually input: ${accession}" "$CYAN"
				echo -e "\nIs the accession number correct?"
			    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
				    if [[ $accession_option = "Yes" ]] ;
				        then
				            accession_again=no
				    elif [[ $accession_option = "No, go back a step" ]] ;
				        then 
				            unset accession
				    fi
				    break           
			    done;

			    if [[ "$accession_again" = yes ]]
			    then echo -e "Let's try again"
			    fi
			done
			export accession="${accession}"
		fi
	elif [[ $(echo "$acount" | wc -l) =~ 4 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 4, then
		accession=`echo $titledir | sed 's/^.*\([0-9][0-9].[0-9][0-9]\).*$/\1/' `
		# sed command cuts everything before and after ##.## in the titledir variable name. I got the sed command from https://unix.stackexchange.com/questions/243207/how-can-i-delete-everything-until-a-pattern-and-everything-after-another-pattern/243236 
		if [[  $(echo -n "$accession" | wc -c) =~ 5 ]]; then
			logNewLine "The accession number is ${accession} found in the artwork folder ${titledir}" "$Bright_Green"
			export accession="${accession}"
		else
			echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
			accession_again=yes
			while [[ "$accession_again" = yes ]] ; do
				echo "\n*************************************************\nInput accession number" && read accession
				#prompts user for accession number and reads input
				logNewLine "The accession number manually input: ${accession}" "$CYAN"
				echo -e "\nIs the accession number correct?"
			    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
				    if [[ $accession_option = "Yes" ]] ;
				        then
				            accession_again=no
				    elif [[ $accession_option = "No, go back a step" ]] ;
				        then 
				            unset accession
				    fi
				    break           
			    done;

			    if [[ "$accession_again" = yes ]]
			    then echo -e "Let's try again"
			    fi
			done
			export accession="${accession}"
		fi
	elif [[ $(echo "$acount" | wc -l) =~ 7 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 7, then
		accession=`echo $titledir | sed 's/^.*\([0-9][0-9][0-9][0-9].[0-9][0-9][0-9]\).*$/\1/' ` 
		# same as before, sed command cuts everything before and after ####.### in the titledir variable name. I got the sed command from https://unix.stackexchange.com/questions/243207/how-can-i-delete-everything-until-a-pattern-and-everything-after-another-pattern/243236
		if [[  $(echo -n "$accession" | wc -c) =~ 8 ]]; then
			logNewLine "The accession number is ${accession} found in the artwork folder ${titledir}" "$Bright_Green"
			export accession="${accession}"
		else
			echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
			accession_again=yes
			while [[ "$accession_again" = yes ]] ; do
				echo "\n*************************************************\nInput accession number" && read accession
				#prompts user for accession number and reads input
				logNewLine "The accession number manually input: ${accession}" "$CYAN"
				echo -e "\nIs the accession number correct?"
			    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
				    if [[ $accession_option = "Yes" ]] ;
				        then
				            accession_again=no
				    elif [[ $accession_option = "No, go back a step" ]] ;
				        then 
				            unset accession
				    fi
				    break           
			    done;

			    if [[ "$accession_again" = yes ]]
			    then echo -e "Let's try again"
			    fi
			done
			export accession="${accession}"
		fi
	else 
		echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
		accession_again=yes
			while [[ "$accession_again" = yes ]] ; do
				echo "\n*************************************************\nInput accession number" && read accession
				#prompts user for accession number and reads input
				logNewLine "The accession number manually input: ${accession}" "$CYAN"
				echo -e "\nIs the accession number correct?"
			    IFS=$'\n'; select accession_option in "Yes" "No, go back a step" ; do
				    if [[ $accession_option = "Yes" ]] ;
				        then
				            accession_again=no
				    elif [[ $accession_option = "No, go back a step" ]] ;
				        then 
				            unset accession
				    fi
				    break           
			    done;

			    if [[ "$accession_again" = yes ]]
			    then echo -e "Let's try again"
			    fi
			done
		export accession="${accession}"
	fi
fi
unset IFS
}

function FindArtworkFile {
FindArtFile="$(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*")"
#searches artwork files directory for Artists Last Name
if [[ -z "${FindArtFile}" ]]; then
#if the find command returns nothing then  
		echo -e "\n*************************************************\n The Artwork File was not found!\n"
		cowsay -W 30 "Enter a number to set the path to the Artwork File on the T:\ drive:"
		#prompt for select command
		IFS=$'\n'; select artdir in $(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Artwork File" ; do
		#lists options for select command - the IFS statment stops it from escaping when it hits spaces in directory names
  		if [[ $artdir = "Input path" ]]
  		then while [[ -z "$ArtFile" ]] ; do 
			artfilen_again=yes
    		while [[ "$artfile_again" = yes ]] ; do
    			echo "Input path to Artwork File:"
				read -e ArtFileInput
				#Asks for user input and assigns it to variable
				ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
				#Strips a trailing space from the input. 
				#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
				#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
				logNewLine "The artwork file manually input is ${ArtFile}" "$CYAN"
				echo -e "\nIs the artwork file correct?"
			    IFS=$'\n'; select artfile_option in "Yes" "No, go back a step" ; do
			    if [[ $artfile_option = "Yes" ]] ;
		        then
		            artfile_again=no
		    	elif [[ $artfile_option = "No, go back a step" ]] ;
		        then 
		            unset ArtFile
		    	fi
		    	break           
		    	done;

		    	if [[ "$artfile_again" = yes ]]
		    	then echo -e "Let's try again"
		    	fi
			done
			if [[ -z "${accession}" ]];
			then
				FindAccessionNumber
				#searches the Artwork File for the accession number, and assigns it to the $accession variable
				sleep 1
			fi
  		done
  		elif [[ $artdir = "Create Artwork File" ]]
  		then MakeArtworkFile 
		else
			ArtFile=$artdir
			#assigns variable to the users selection from the select menu
			logNewLine "The artwork file is ${ArtFile}" "$Bright_Green"
			export ArtFile="${ArtFile}"
			if [[ -z "${accession}" ]];
			then
				FindAccessionNumber
				#searches the Artwork File for the accession number, and assigns it to the $accession variable
				sleep 1
			fi
		fi
		break			
		done;
elif [[ $(echo "${FindArtFile}" | wc -l) > 1 ]]; 
	then
		#FindArtFile_Lines=$(echo "${FindArtFile}" | wc -l)
		FindArtFile=(${FindArtFile[@]})
		for i in ${FindArtFile[@]}; do
			if [[ -z "${accession}" ]]; then
				FindAccessionNumber
			fi
			accession_dir=$(find "${i%/}" -maxdepth 1 -type d -iname "*$accession*")
			if [[ ! -z "${accession_dir}" ]];
			then
				"${i%/}"=$ArtFile
				if [[ -z "${accession}" ]]; then
				FindAccessionNumber
				fi
				logNewLine "The artwork file is ${ArtFile}" "$Bright_Green"
				export ArtFile="${ArtFile}"
			fi
		done
else
	ArtFile="${FindArtFile}"
	#assigns variable to the results of the find command "find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*""
	logNewLine "The artwork file is ${ArtFile}" "$Bright_Green"
	export ArtFile="${ArtFile}"
	if [[ -z "${accession}" ]]; then
		FindAccessionNumber
		#searches the Artwork File for the accession number, and assigns it to the $accession variable
		sleep 1
	fi
fi
}

set +a