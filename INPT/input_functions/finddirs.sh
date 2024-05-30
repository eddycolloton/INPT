#!/bin/bash

set -a

function InputArtistsName {
    echo -e "\n*************************************************\nInput artist's first name"
    read -e ArtistFirstName
    # Asks for user input and assigns it to variable
    echo -e "\n*************************************************\nInput artist's last name"
    read -e ArtistLastName
    # Asks for user input and assigns it to variable
	logNewLine "Artist name manually input: ${ArtistFirstName} ${ArtistLastName}" "$CYAN"
}

function ConfirmArtistsName {
	while [[ "$name_again" = yes ]] ; do
		InputArtistsName
		cowsay "Just checking for typos - Is the Artist's Name entered correctly?"
		IFS=$'\n'; select name_option in "Yes" "No, go back a step" ; do
			if [[ $name_option = "Yes" ]] ; then
				name_again=no
			elif [[ $name_option = "No, go back a step" ]] ; then
				unset ArtistFirstName ArtistLastName
			fi
		break           
		done;

		if [[ "$name_again" = yes ]]; then
			echo -e "Let's try again"
		fi
    done
}

# This function finds the Artwork file path
function FindArtworkFilesPath {
	if [[ -z "${ArtFilePath}" ]]; then
		if [[ -d /Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		elif [[ -d /Volumes/Shared-1/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		elif [[ -d /Volumes/Shared-2/departments/CONSERVATION/ARTWORK\ FILES ]]; then
			ArtFilePath=/Volumes/Shared/departments/CONSERVATION/ARTWORK\ FILES
			logNewLine "found ARTWORK FILES directory at $ArtFilePath" "$MAGENTA"
		else
			cowsay -W 30 "Please input the path to the ARTWORK FILES directory from the T:\ drive. Feel free to drag and drop the directory into terminal:"
			read -e ArtFilePath
			logNewLine "The path to the Artwork Files manually input: $ArtFilePath" "$CYAN"
		fi
		export ArtFilePath="${ArtFilePath}"
	fi
}

ConfirmInput () {
    local var="$1"
	local var_display_name="$2"
	local prompt_context="$3"
    select_again=yes
	while [[ "$select_again" = yes ]] ; do
		echo -e "\nManually input the ${var_display_name}"
        if [[ ! -z "$prompt_context" ]] ; then
        # Optional additional argument to provide context on prompt for input
            echo -e "$prompt_context"
			## vars w/ spaces passed to prompt_context not displaying correctly! 
        fi
		read -e user_input
        # Read user input as variable $user_input
        user_input="${user_input%"${user_input##*[![:space:]]}"}"
        # If the user_input path is dragged and dropped into terminal, the trailing whitespace can eventually be interpreted as a "\" which breaks the CLI tools.
		logNewLine "The ${var_display_name} manually input: ${user_input}" "$CYAN"
        if [[ "$typo_check" == true ]] ; then
        # If typo check option is turned on, then confirm user_input
            cowsay "Just checking for typos - Is the ${var_display_name} entered correctly?"
            select options in "yes" "no, go back a step"; do
                case $options in
                    yes)
                        select_again=no
                        break;;
                    "no, go back a step")
                        select_again=yes
                        unset user_input
                        break;;
                esac
            done
            if [[ "$select_again" = yes ]] ;
                    then echo -e "Let's try again"
            fi
        else
            select_again=no
        fi
	eval "${var}=\${user_input}"
	export var="${var}"
	done
}

# This function makes the nested directories of a Time-based Media Artwork File
function MakeArtworkFile {
	while [[ -z "$accession" ]] ; do
		ConfirmInput accession "artwork's accession number" "Accession number format:\nPre-2016 Accession: YY.# ->  ex. 08.20\nPost-2016 Accession: YYYY.### -> ex. 2017.001"
		export accession="${accession}"
	done
	while [[ -z "$title" ]] ; do
    	ConfirmInput title "artwork's title"
		export title="${title}"
	done
	while [[ -z "$labunmber" ]] ; do
		ConfirmInput labnumber "artwork's lab number" "Lab number format:\n###-YYYY"
        export labnumber="${labnumber}"
	done
	mkdir -p "${ArtFilePath%/}"/"$ArtistLastName"", ""$ArtistFirstName"/"time-based media"/"$accession""_""$title"/{"Acquisition and Registration","Artist Interaction","Cataloging","Conservation"/{"Condition_Tmt Reports","DAMS","Equipment Reports"},"Iteration Reports_Exhibition Info"/"Equipment Reports","Photo-Video Documentation","Research"/"Correspondence","Technical Info_Specs"/{"Past installations_Pics","Sidecars_""$labnumber"},"Trash"}
	# creates Artwork File directories
	# I've removed the path to the HMSG shared drive below for security reasons
	ArtFile="${ArtFilePath%/}"/"$ArtistLastName"", ""$ArtistFirstName"/
	# assigns the ArtFile variable to the artwork file just created 
	# I've removed the path to the HMSG shared drive below for security reasons
	logNewLine "The artwork file has been created: ${ArtFile}" "$YELLOW"
	mkArtFile=True
	export ArtFile="${ArtFile}"
	export mkArtFile="${mkArtFile}"
} 

ParseAccession () {
    local parsed_accession="$1"
    local found_dir="$2"
    local count="$3"
    dir_name=$(basename "$found_dir")
    parsed_accession=$(echo "$dir_name" | awk -F'[ _]' '{print $1}')
    # sed command cuts everything before and after ##.# in the titledir variable name. I got the sed command from https://unix.stackexchange.com/questions/243207/how-can-i-delete-everything-until-a-pattern-and-everything-after-another-pattern/243236
    if [[  $(echo -n "$parsed_accession" | wc -c) =~ $count ]]; then
	# if the number of characters (counted by 'wc -c') is equal to the provided count, then
        logNewLine "The accession number is ${parsed_accession} found in the artwork folder ${found_dir}" "$MAGENTA"
        export accession="${parsed_accession}"
    else
        ConfirmInput accession "artwork's accession number" "Accession number format:\nPre-2016 Accession: YY.# ->  ex. 08.20\nPost-2016 Accession: YYYY.### -> ex. 2017.001"
    fi
}

# this function searches the artwork folder for the accession number, if there is one, it retrieves it, if there isn't it requests one from the user
function FindAccessionNumber {
IFS=$'\n'
title_dir_results=$(find "${ArtFile}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \) -print0 | xargs -0 -L 1  | wc -l | xargs)
# uses find command to identify directories that have numbers in the name AND a . OR a -, then prints them. The first xargs command creates line breaks between the results
# I don't know how xargs works, I got that bit from https://stackoverflow.com/questions/20165321/operating-on-multiple-results-from-find-command-in-bash
# wc -l counts the lines from the output of the find command, this should give the number of directories found that have an accession number in them
# The final xargs removes white space from the output of wc so that theoutput can be evalutated by the "if" statement below
if [[ "$title_dir_results" > 1 ]]; then
	logNewLine "\nMore than one directory containing an accession number found." "$RED"
    # If the variable title_dir_results stores more than one result
	# This is to determine if there is more than one dir in the ArtFile that has an accession number (typically means there are two artworks by the same artist)
	echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
    ConfirmInput accession "artwork's accession number" "Accession number format:\nPre-2016 Accession: YY.# ->  ex. 08.20\nPost-2016 Accession: YYYY.### -> ex. 2017.001"
	accession_dir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname "*${accession}*")
	# defines the accession_dir variable as a directory stored inside the ArtFile that has the accession number in it's name
	# This is to define a more specific variable, if there is more than one artwork in the ArtFile
	if [[ -z "${accession_dir}" ]]; then
	# if the accession_dir variable is empty
	# This var will typically be empty if the find command did not return a result
		while [[ -z "$title" ]] ; do
            ConfirmInput title "artwork's title"
		done
		accession_dir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname "*${title}*")
        # defines the accession_dir variable as a directory stored inside the ArtFile that has the title in it's name
		# This is to define a more specific variable, if there is more than one artwork in the ArtFile, or the directory is named in a way that is unexpected (i.e. with no accession number or accession number written ##-##)
		if [[ -z "${accession_dir}" ]]; then
		# if the accession_dir variable is empty
			echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure.\nCannot find the parent directory from the title or accession number directory.\nChoose the directory that will store the Technical Info_Specs directory and the Condition_Tmt Reports directory.\nSee directories listed below:\n"
			sleep 1
			tree "$ArtFile"
			sleep 2
			cowsay "Select a directory, or choose to quit:"
			# prompt for select command
			IFS=$'\n'; select parentdir_option in "$ArtFile" "Enter path to parent directory" "Quit" ; do
			# lists options for select command. The IFS statment stops it from escaping when it hits spaces in directory names
			case $parentdir_option in 
				"$ArtFile") accession_dir="$ArtFile"
				# if ArtFile is selected, it is assigned the variable $accession_dir
					logNewLine "The Artwork File is $accession_dir" "$MAGENTA"
				break;;
				"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
					read -e parentdir_input &&
					# reads user input and assigns it to the variable $reportdir_parent
					accession_dir="$(echo -e "${parentdir_input}" | sed -e 's/[[:space:]]*$//')"
					# Strips a trailing space from the input. 
					# If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
					# I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
					logNewLine "The Artwork File is now $accession_dir" "$MAGENTA"
				break;;
				"Quit") echo "Quitting now..." && exit 1
				# ends the script, exits
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
# if the accession variable is not assigned, and there are numbers in the titledir name 
	titledir=$(find "${ArtFile%/}" -mindepth 0 -maxdepth 4 -type d -iname '*[0-9]*' \( -iname "*.*" -o -iname "*-*" \))
	# looks in the ArtFile for a directory with numbers in the name, if it finds one, AND it has a period OR a dash in the directory name, it assigns that to the titledir variable
	if [[ -z "$titledir" ]]; then 
	# if the $titledir variable is empty, then
        echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
    	ConfirmInput accession "artwork's accession number" "Accession number format:\nPre-2016 Accession: YY.# ->  ex. 08.20\nPost-2016 Accession: YYYY.### -> ex. 2017.001"
	else
		acount=$(echo "$titledir" | grep -oE '[0-9]')
		# this grep command prints every digit it finds in titledir on a new line, and assigns that output to the variable "acount"
		if [[ $(echo "$acount" | wc -l) =~ 3 ]]; then
		# pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 3, then
			ParseAccession accession "${titledir}" "4"
		elif [[ $(echo "$acount" | wc -l) =~ 4 ]]; then
		# pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 4, then
			ParseAccession accession "${titledir}" "5"
		elif [[ $(echo "$acount" | wc -l) =~ 7 ]]; then
		# pipes the contents of the acount variable to wc -l, which counts the number of lines. if the number of lines equals 7, then
			ParseAccession accession "${titledir}" "8"
		else 
			echo -e "\n*************************************************\n \nCannot find accession number in Artwork File directories"
			ConfirmInput accession "artwork's accession number" "Accession number format:\nPre-2016 Accession: YY.# ->  ex. 08.20\nPost-2016 Accession: YYYY.### -> ex. 2017.001"
		fi
	fi
fi
unset IFS
}

function FindArtworkFile {
FindArtFile="$(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*")"
# searches artwork files directory for Artists Last Name
if [[ -z "${FindArtFile}" ]]; then
# if the find command returns nothing then  
		echo -e "\n*************************************************\n The Artwork File was not found!\n"
		cowsay -W 30 "Enter a number to set the path to the Artwork File on the T:\ drive:"
		# prompt for select command
		IFS=$'\n'; select artdir in $(find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*") "Input path" "Create Artwork File" ; do
		# lists options for select command - the IFS statment stops it from escaping when it hits spaces in directory names
  		if [[ $artdir = "Input path" ]]
  		then while [[ -z "$ArtFile" ]] ; do 
			ConfirmInput ArtFile "path to the artwork file" "Feel free to drag and drop Artwork File path below"
			if [[ -z "${accession}" ]];
			then
				FindAccessionNumber
				# searches the Artwork File for the accession number, and assigns it to the $accession variable
				sleep 1
			fi
  		done
  		elif [[ $artdir = "Create Artwork File" ]]
  		then MakeArtworkFile 
		else
			ArtFile=$artdir
			# assigns variable to the users selection from the select menu
			logNewLine "The artwork file is ${ArtFile}" "$Bright_Magenta"
			export ArtFile="${ArtFile}"
			if [[ -z "${accession}" ]];
			then
				FindAccessionNumber
				# searches the Artwork File for the accession number, and assigns it to the $accession variable
				sleep 1
			fi
		fi
		break			
		done;
elif [[ $(echo "${FindArtFile}" | wc -l) > 1 ]]; 
	then
		FindArtFile=(${FindArtFile[@]})
		for i in ${FindArtFile[@]}; do
			if [[ -z "${ArtFile}" ]] ; then
				# the above if statement - if $ArtFile is None then - is intended to skip the rest of the "for" loop if one of the results of FindArtFile array leads to the assignment of the art file
				if [[ -z "${accession}" ]]; then
					FindAccessionNumber
				fi
				accession_dir=$(find "${i%/}" -maxdepth 1 -type d -iname "*$accession*")
				if [[ ! -z "${accession_dir}" ]]; then
					"${i%/}"=$ArtFile
					if [[ -z "${accession}" ]]; then
						FindAccessionNumber
					fi
					logNewLine "The artwork file is ${ArtFile}" "$Bright_Magenta"
					export ArtFile="${ArtFile}"
				fi
			fi
		done
else
	ArtFile="${FindArtFile}"
	# assigns variable to the results of the find command "find "${ArtFilePath%/}" -maxdepth 1 -type d -iname "*$ArtistLastName*""
	logNewLine "The artwork file is ${ArtFile}" "$Bright_Magenta"
	export ArtFile="${ArtFile}"
	if [[ -z "${accession}" ]]; then
		FindAccessionNumber
		# searches the Artwork File for the accession number, and assigns it to the $accession variable
		sleep 1
	fi
fi
}

ParseArtFile () {
    # Get the directory path from the argument
    dir_path="$1"
    
    # Extract the directory name immediately after $ArtFilePath
    dir_name="${dir_path#"$ArtFilePath"}"

    # Remove any leading or trailing '/' characters
    dir_name="${dir_name#/}"
    dir_name="${dir_name%/}"

    # Split the directory name into parts using ',' and '/'
    IFS='/' read -r -a parts <<< "$dir_name"

    # Extract the last part which contains the name and split it using ','
    IFS=',' read -r -a name_parts <<< "$parts"

    # Assign the parts to $ArtistLastName and $ArtistFirstName
    ArtistLastName="${name_parts[0]}"
    ArtistFirstName="${name_parts[1]}"

	logNewLine "Artist name found in Artwork File: ${ArtistFirstName} ${ArtistLastName}" "$Bright_Magenta"

    export ArtistFirstName="${ArtistFirstName}"
    export ArtistLastName="${ArtistLastName}"
}

MakeOutputDirectory() {
    if [[ "$dir_type" == "techdir" ]]; then
		sidecardir_match=$(find "${!dir_type%/}" -maxdepth 2 -type d -iname "*Sidecars*" | wc -l | xargs)
        if [[ "$sidecardir_match" -lt 1 ]]; then
            mkdir -p "${dir_type_parent%/}/${dir_label}/Sidecars_${labnumber}"
            dir_path="${dir_type_parent%/}/${dir_label}"
			eval "$dir_type=\"\$dir_path\""
            sidecardir="${dir_type_parent%/}/${dir_label}/Sidecars_${labnumber}" 
		else
			sidecardir=$(find "${!dir_type%/}" -maxdepth 2 -type d -iname "*Sidecars*")
        fi
	fi
    mkdir -p "${dir_type_parent%/}/${dir_label}"
    dir_path=${dir_type_parent%/}/${dir_label}
	eval "$dir_type=\"\$dir_path\""
}

AssignDirectory() {
    local dir_type="$1"
    local dir_label="$2"
    local parent_dir="$3"

    if [[ -z "${!dir_type}" ]]; then
        echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find $dir_label directory\nSee directories listed below \n"
        sleep 2
		tree "$parent_dir"
		sleep 1
        cowsay "Select a directory to create the $dir_label directory, or choose to quit:"
        IFS=$'\n'; select dir_option in "$parent_dir" "Enter path to parent directory" "Quit"; do
            case $dir_option in 
                "$parent_dir") dir_type_parent="$parent_dir"
                            MakeOutputDirectory
                            break;;
                "Enter path to parent directory") ConfirmInput dir_type_parent "directory path" "Enter the path to the parent directory of the new $dir_label directory, use tab complete to help:"
                                                    MakeOutputDirectory
                                                    break;;
                "Quit") echo "Quitting now..."
                        exit 1;;
            esac
        done
        unset IFS
        logNewLine "Path to the $dir_label directory: ${!dir_type}" "$Bright_Magenta"
    else
        logNewLine "Path to the $dir_label directory: ${!dir_type}" "$Bright_Magenta"
    fi
}

function FindConditionDir {
if [[ -z "$accession_dir" ]]; then
# if the $accession_dir variable is empty (unassigned - which would mean there was only one artwork found in the Art File, then)	 
	reportdir_match=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Condition*" | wc -l | xargs)
    # looks for directories with Condition in the name that is a subdirectory of $ArtFile and, if found, counts it. $reportdir_match stores the number of directories that have the word "Condition" in the name
    if [[ "${reportdir_match}"  -gt 1 ]]; then
    # if the number of directories that have the word "Condition" in the name is greater than 1, then
	    AssignDirectory "reportdir" "Condition_Tmt Reports" "${ArtFile%/}"
    else
        reportdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Condition*")
	    # looks for a directory with Condition in the name that is a subdirectory of $ArtFile and, if found, assigns it to the $reportdir variable
	    # The "%/" removes the trailing "/" on the end of the ArtFile
        AssignDirectory "reportdir" "Condition_Tmt Reports" "${ArtFile%/}"
    fi
else
	reportdir_match=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Condition*" | wc -l | xargs)
    # looks for directories with Condition in the name that is a subdirectory of $ArtFile and, if found, counts it. $reportdir_match stores the number of directories that have the word "Condition" in the name
    if [[ "${reportdir_match}"  -gt 1 ]]; then
    # if the number of directories that have the word "Condition" in the name is greater than 1, then
	    AssignDirectory "reportdir" "Condition_Tmt Reports" "${accession_dir%/}"
	else
		reportdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Condition*")
		# looks for a directory with Condition in the name that is a subdirectory $accession_dir, if found, assigns it to the $reportdir variable
		# The "%/" removes the trailing "/" on the end of the ArtFile
		AssignDirectory "reportdir" "Condition_Tmt Reports" "${accession_dir%/}"
	fi
fi
export reportdir="${reportdir}"
}

function FindTechDir {
if [[ -z "$accession_dir" ]]; then
	techdir_match=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Technical Info*" | wc -l | xargs)
    # looks for directories with Technical Info in the name that is a subdirectory of $ArtFile and, if found, counts it. $techdir_match stores the number of directories that have the words "Technical Info" in the name
    if [[ "${techdir_match}"  -gt 1 ]]; then
    # if the number of directories that have the word "Technical Info" in the name is greater than 1, then
		AssignDirectory  "techdir" "Technical Info_Specs" "${ArtFile%/}"
	else
		techdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Technical Info*")
		# looks for the Technical Info_Specs directory
		# The "%/" removes the trailing "/" on the end of the ArtFile
		AssignDirectory  "techdir" "Technical Info_Specs" "${ArtFile%/}"
	fi
else
	techdir_match=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Technical Info*" | wc -l | xargs)
    # looks for directories with Technical Info in the name that is a subdirectory of $ArtFile and, if found, counts it. $techdir_match stores the number of directories that have the words "Technical Info" in the name
    if [[ "${techdir_match}"  -gt 1 ]]; then
    # if the number of directories that have the word "Technical Info" in the name is greater than 1, then
		AssignDirectory  "techdir" "Technical Info_Specs" "${accession_dir%/}"
	else
		techdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Technical Info*")
		# looks for the Technical Info_Specs directory
		# The "%/" removes the trailing "/" on the end of the ArtFile
		AssignDirectory  "techdir" "Technical Info_Specs"  "${accession_dir%/}"
	fi
fi

if [[ -z "$sidecardir" ]]; then
# if the $sidecardir variable is empty (unassigned), then
	sidecardir=$(find "${techdir%/}" -maxdepth 2 -type d -iname "*Sidecars*")
	# if the find command fails to find a directory called "sidecars" in the techdir, then
	if [[ -z "$sidecardir" ]]; then
		mkdir -p "${techdir%/}/Sidecars_${labnumber}"
		sidecardir="${techdir%/}/Sidecars" 
		logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
	else
		logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
	fi
else
	logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
fi

export techdir="${techdir}"
export sidecardir="${sidecardir}"
}

function ExtractLabnumber {
    local found_sidecardir="$1"

    # Extract the potential lab number from the end of the sidecardir
    if [[ "$found_sidecardir" =~ /Sidecars_([0-9]{3}-[0-9]{4})$ ]]; then
        labnumber="${BASH_REMATCH[1]}"
		export labnumber="${labnumber}"
        logNewLine "Lab number found in $(basename ${found_sidecardir}): $labnumber" "$MAGENTA"
    fi
}

# This function finds the Staging Directory file path
function FindTBMADroBoPath {
	if [[ -z "${TBMADroBoPath}" ]]; then
		if [[ -d /Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork ]]; then
			TBMADroBoPath=/Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork
			echo "found TBMA DroBo at $TBMADroBoPath"
			export TBMADroBoPath="${TBMADroBoPath}"
		else
			ConfirmInput TBMADroBoPath "path to the TBMA DroBo" "Please input the path to the 'Time Based Media Artwork' directory on the TBMA DroBo. Feel free to drag and drop the directory into terminal:"
			export TBMADroBoPath="${TBMADroBoPath}"
		fi
	fi
}

# This function makes the staging directory if one does not exist
function MakeStagingDirectory {
	if [ -z "${accession+x}" ]; then
		ConfirmInput accession "Accession number format:\nPre-2016 Accession: YY.# ->  ex. 08.20\nPost-2016 Accession: YYYY.### -> ex. 2017.001"
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
			ConfirmInput SDir "staging directory" "Input path to Staging Directory:"
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

# Function to check permissions
# Recently got some error when running 'find' on the /Volumes/ directory, adding this check to (hopefully) avoid confusing error messages
check_permissions() {
    if [ -r "$1" ] && [ -x "$1" ]; then
        return 0
    else
        return 1
    fi
}


function FindVolume {
	# Loop through directories in /Volumes
	for dir in /Volumes/*; do
		if [[ -d "$dir" ]]; then
			if check_permissions "$dir"; then
			# check permissions on each directory in /Volumes/ (if you have read and execute permissions)
				if [[ -z "${title}" ]] ; then
					FindVolumes=$(find "$dir" -maxdepth 0 -type d -iname "*${ArtistLastName}*")
				else
					FindVolumes=$(find "$dir" -maxdepth 1 -type d -iname "*${ArtistLastName}*" -o -iname "*${title}*")
				fi
				# check if volume in /Volumes/ contains the artist's last name or the title
				if [[ -n "$FindVolumes" ]] ; then
					echo -e "Is this the volume? \n${FindVolumes}"
					# if a volume has the artist's last name or the title, prompt the use to assign it to $Volume (or not)
					IFS=$'\n'; select found_volume_option in "yes" "no" ; do
						if [[ $found_volume_option = "yes" ]] ; then 
							Volume="${FindVolumes}"
							logNewLine "The path to the volume is: ${Volume}" "$Bright_Magenta"
							break 2 # Break out of both select and for loops
						elif [[ $found_volume_option = "no" ]] ; then
							echo "Not the volume!"
							break # Break out of select loop
						fi
					break           
					done;
				fi
			fi
		fi
	done

	if [[ -z $Volume ]] ; then
	# if $Volume is unassigned, then no volumes matches find criteria, or were declined by user, so user is prompted to input the path to the volume
		ConfirmInput Volume "path to the volume" "Path to the volume should begin with '/Volumes/' (use tab complete to help)"
	fi

	export Volume="${Volume}"
}

set +a