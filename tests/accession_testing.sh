#!/bin/bash

ArtFile="/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/Last, First/"

ConfirmInput () {
    local var="$1"
    local var_again="$2"
	select options in "yes" "no, go back a step"; do
		case $options in
			yes)
				select_again=no
                eval "$var_again=\$select_again"
				break;;
			"no, go back a step")
				select_again=yes
                eval "$var_again=$select_again"
                unset var
				break;;
		esac
	done
}

function CheckAccession {
    echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
    accession_again=yes
    while [[ "$accession_again" = yes ]] ; do
        echo -e "\n*************************************************\nInput accession number" && read accession
        #prompts user for accession number and reads input
        logNewLine "The accession number manually input: ${accession}" "$CYAN"
        echo -e "\nIs the accession number correct?"
        ConfirmInput accession accession_again
        if [[ "$accession_again" = yes ]] ;
            then echo -e "Let's try again"
        fi
    done
    export accession="${accession}"
}

ParseAccession () {
    local parsed_accession="$1"
    local found_dir="$2"
    local count="$3"
    dir_name=$(basename "$found_dir")
    parsed_accession=$(echo "$dir_name" | awk -F'[ _]' '{print $1}')
    #sed command cuts everything before and after ##.# in the titledir variable name. I got the sed command from https://unix.stackexchange.com/questions/243207/how-can-i-delete-everything-until-a-pattern-and-everything-after-another-pattern/243236
    if [[  $(echo -n "$parsed_accession" | wc -c) =~ $count ]]; then
        logNewLine "The accession number is ${parsed_accession} found in the artwork folder ${found_dir}" "$MAGENTA"
        export accession="${parsed_accession}"
    else
        CheckAccession 
    fi
}

#this function searches the artwork folder for the accession number, if there is one, it retrieves it, if there isn't it requests one from the user
function FindAccessionNumber {
IFS=$'\n'
title_dir_results=$(find "${ArtFile}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \) -print0 | xargs -0 -L 1  | wc -l | xargs)
#uses find command to identify directories that have numbers in the name AND a . OR a -, then prints them. The first xargs command creates line breaks between the results
#I don't know how xargs works, I got that bit from https://stackoverflow.com/questions/20165321/operating-on-multiple-results-from-find-command-in-bash
#wc -l counts the lines from the output of the find command, this should give the number of directories found that have an accession number in them
#The final xargs removes white space from the output of wc so that theoutput can be evalutated by the "if" statement below
if [[ "$title_dir_results" > 1 ]]; then
	logNewLine "More than one directory containing an accession number found." "$MAGENTA"
    #If the variable title_dir_results stores more than one result
	#This is to determine if there is more than one dir in the ArtFile that has an accession number (typically means there are two artworks by the same artist)
	CheckAccession
	accession_dir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname "*${accession}*")
	#defines the accession_dir variable as a directory stored inside the ArtFile that has the accession number in it's name
	#This is to define a more specific variable, if there is more than one artwork in the ArtFile
	if [[ -z "${accession_dir}" ]]; then
	#if the accession_dir variable is empty
	#This var will typically be empty if the find command did not return a result
		while [[ -z "$title" ]] ; do
			title_again=yes
            while [[ "$title_again" = yes ]] ; do
                echo -e "\n*************************************************\nInput the artwork's title" && read title
                #prompts user for artwork title and reads input
                echo "The title manually input: ${title}"
                echo -e "\nIs the title correct?"
                ConfirmInput title title_again
                if [[ "$title_again" = yes ]] ;
                    then echo -e "Let's try again"
                fi
			export title="${title}"
		    done
		accession_dir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname "*${title}*")
		done
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
					logNewLine "The Artwork File is $accession_dir" "$MAGENTA"
				break;;
				"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
					read -e parentdir_input &&
					#reads user input and assigns it to the variable $reportdir_parent
					accession_dir="$(echo -e "${parentdir_input}" | sed -e 's/[[:space:]]*$//')"
					#Strips a trailing space from the input. 
					#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
					#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
					logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
				break;;
				"Quit") echo "Quitting now..." && exit 1
				#ends the script, exits
			esac	
		    done;
		    unset IFS
		else 
            logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
		fi
	else 
        logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
	fi
fi

if [[ -z "${accession}" ]]; then
#if the accession variable is not assigned, and there are numbers in the titledir name 
	titledir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \))
	#looks in the ArtFile for a directory with numbers in the name, if it finds one, AND it has a period OR a dash in the directory name, it assigns that to the titledir variable
	if [[ -z "$titledir" ]]; then 
	#if the $titledir variable is empty, then
        CheckAccession
	fi
	acount=$(echo "$titledir" | grep -oE '[0-9]')
	#this grep command prints every digit it finds in titledir on a new line, and assigns that output to the variable "acount"
	if [[ $(echo "$acount" | wc -l) =~ 3 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 3, then
	    ParseAccession accession "${titledir}" "4"
	elif [[ $(echo "$acount" | wc -l) =~ 4 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 4, then
        ParseAccession accession "${titledir}" "5"
	elif [[ $(echo "$acount" | wc -l) =~ 7 ]]; then
	#pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 7, then
        ParseAccession accession "${titledir}" "8"
	else 
		CheckAccession
	fi
fi
unset IFS
}

FindAccessionNumber