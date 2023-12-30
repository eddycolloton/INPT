#!/bin/bash

function FindConditionDir {
if [[ -z "$accession_dir" ]]; then
	#if the $accession_dir variable is empty (unassigned - which would mean there was only one artwork found in the Art File, then) 
	reportdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Condition*")
	#looks for a directory with Conidition in the name that is a subdirectory of $ArtFile and, if found, assigns it to the $reportdir variable
	#The "%/" removes the trailing "/" on the end of the ArtFile
	if [[ -z "$reportdir" ]]; then 
	#if the $reportdir variable is empty (unassigned), then 
		echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find Condition_Tmt Reports directory \n See directories listed below \n"
		tree "$ArtFile"
		cowsay "Select a directory to create the Condition_Tmt Reports directory, or choose to quit:"
		#prompt for select command
		IFS=$'\n'; select reportdir_option in "$ArtFile" "Enter path to parent directory" "Quit" ; do
		#lists options for select command. The IFS statment stops it from escaping when it hits spaces in directory names
		case $reportdir_option in 
		"$ArtFile") reportdir_parent="$ArtFile" &&
		#if ArtFile is selected, it is assigned the variable $reportdir_parent
			mkdir -pv "${reportdir_parent%/}/Condition_Tmt Reports" &&
			#creates Condition_Tmt Reports directory underneath the $reportdir_parent
			reportdir="${reportdir_parent%/}/Condition_Tmt Reports"
			#assigns the $reportdir variable to the newly created directory
			break;;
		"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
			read -e reportdir_parent_input &&
			#reads user input and assigns it to the variable $reportdir_parent
			reportdir_parent="$(echo -e "${reportdir_parent_input}" | sed -e 's/[[:space:]]*$//')"
			#Strips a trailing space from the input. 
			#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
			#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
			mkdir -pv "${reportdir_parent%/}/Condition_Tmt Reports" &&
			#creates Condition_Tmt Reports directory underneath the $reportdir_parent
			reportdir="${reportdir_parent%/}/Condition_Tmt Reports"
			#assigns the $reportdir variable to the newly created directory
			break;;
		"Quit") echo "Quitting now..." && exit 1
		#ends the script, exits
			esac	
		done;
		unset IFS
		logNewLine "Path to the staging directory: $reportdir" "$MAGENTA"
		logNewLine "Metadata output will be written to the appendix.txt file in $reportdir" "$MAGENTA"
	else 
		logNewLine "Path to the staging directory: $reportdir" "$MAGENTA"
		logNewLine "Metadata output will be written to the appendix.txt file in $reportdir" "$MAGENTA"
	#States the location of the report dir if it was found in the inital find command (before the if statement)
	fi
else
	reportdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Condition*")
	#looks for a directory with Conidition in the name that is a subdirectory $accession_dir, if found, assigns it to the $reportdir variable
	#The "%/" removes the trailing "/" on the end of the ArtFile
	if [[ -z "$reportdir" ]]; then 
	#if the $reportdir variable is empty (unassigned), then 
		echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find Condition_Tmt Reports directory \n See directories listed below \n"
		tree "$ArtFile"
		cowsay "Select a directory to create the Condition_Tmt Reports directory, or choose to quit:"
		#prompt for select command
		IFS=$'\n'; select reportdir_option in "$accession_dir" "Enter path to parent directory" "Quit" ; do
		#lists options for select command. The IFS statment stops it from escaping when it hits spaces in directory names
		case $reportdir_option in 
		"$accession_dir") reportdir_parent="$accession_dir" &&
		#if ArtFile is selected, it is assigned the variable $reportdir_parent
			mkdir -pv "${reportdir_parent%/}/Condition_Tmt Reports" &&
			#creates Condition_Tmt Reports directory underneath the $reportdir_parent
			reportdir="${reportdir_parent%/}/Condition_Tmt Reports"
			#assigns the $reportdir variable to the newly created directory
			break;;
		"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
			read -e reportdir_parent_input &&
			#reads user input and assigns it to the variable $reportdir_parent
			reportdir_parent="$(echo -e "${reportdir_parent_input}" | sed -e 's/[[:space:]]*$//')"
			#Strips a trailing space from the input. 
			#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
			#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
			mkdir -pv "${reportdir_parent%/}/Condition_Tmt Reports" &&
			#creates Condition_Tmt Reports directory underneath the $reportdir_parent
			reportdir="${reportdir_parent%/}/Condition_Tmt Reports"
			#assigns the $reportdir variable to the newly created directory
			break;;
		"Quit") echo "Quitting now..." && exit 1
		#ends the script, exits
			esac	
		done;
		unset IFS
		logNewLine "Path to the staging directory: $reportdir" "$MAGENTA"
		logNewLine "Metadata output will be written to the appendix.txt file in $reportdir" "$MAGENTA"
	else 
		logNewLine "Path to the staging directory: $reportdir" "$MAGENTA"
		logNewLine "Metadata output will be written to the appendix.txt file in $reportdir" "$MAGENTA"
	#States the location of the report dir if it was found in the inital find command (before the if statement)
	fi
fi
export reportdir="${reportdir}"
}

function FindTechDir {
if [[ -z "$accession_dir" ]]; then
	techdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Technical Info*")
	#looks for the Technical Info_Specs directory
	#The "%/" removes the trailing "/" on the end of the ArtFile
	if [[ -z "$techdir" ]]; then
	#if the $techdir variable is empty (unassigned), then 
		echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find Technical Info_Specs directory\nSee directories listed below \n"
		tree "$ArtFile"
		cowsay "Select a directory to create the Technical Info_Specs directory, or choose to quit:"
		#prompt for select command
		IFS=$'\n'; select techdir_option in "$ArtFile" "Enter path to parent directory" "Quit" ; do
		#lists options for select command, the ArtFile and subsequent subdirectories, regadless of name. The IFS statment stops it from escaping when it hits spaces in directory names
		case $techdir_option in 
		"$ArtFile") techdir_parent="$ArtFile" &&
		#if ArtFile is selected, it is assigned the variable $techdir_parent
			mkdir -pv "${techdir_parent%/}/Technical Info_Specs/Sidecars" &&
			#creates Technical Info_Specs directory underneath the $techdir_parent
			techdir="${techdir_parent%/}/Technical Info_Specs"
			#assigns the $techdir variable to the newly created directory
			sidecardir="${techdir_parent%/}/Technical Info_Specs/Sidecars"
			#assigns the $sidecardir variable to the newly created directory
			break;;
		"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
			read -e techdir_parent_input &&
			#reads user input and assigns it to the variable $techdir_parent_input
			techdir_parent="$(echo -e "${techdir_parent_input}" | sed -e 's/[[:space:]]*$//')"
			#Strips a trailing space from the input. 
			#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
			#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
			mkdir -pv "${techdir_parent%/}/Technical Info_Specs/Sidecars" &&
			#creates Technical Info_Specs directory underneath the $techdir_parent
			techdir="${techdir_parent%/}/Technical Info_Specs"
			#assigns the $techdir variable to the newly created directory
			sidecardir="${techdir_parent%/}/Technical Info_Specs/Sidecars"
			#assigns the $sidecardir variable to the newly created directory
			break;;
		"Quit") echo "Quitting now..." && exit 1
			#ends the script, exits
			esac	
		done;
		unset IFS
		logNewLine "Path to the staging directory: $techdir" "$MAGENTA"
		logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
	else 
		sidecardir=$(find "${techdir%/}" -maxdepth 2 -type d -iname "*Sidecars*")
		if [[ -z "$sidecardir" ]]; then
		#if the $sidecardir variable is empty (unassigned), then
		#In other words, if the find command fails to find a directory called "sidecars" in the techdir, then
			mkdir -pv "${techdir%/}/Sidecars" &&
			sidecardir="${techdir%/}/Sidecars" 
			logNewLine "Path to the staging directory: $techdir" "$MAGENTA"
			logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
		else
			logNewLine "Path to the staging directory: $techdir" "$MAGENTA"
			logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
		fi
	#States the location of the tech dir if it was found in the inital find command (before the if statement)
	fi
else
	techdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Technical Info*")
	#looks for the Technical Info_Specs directory
	#The "%/" removes the trailing "/" on the end of the ArtFile
	if [[ -z "$techdir" ]]; then
	#if the $techdir variable is empty (unassigned), then 
		echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find Technical Info_Specs directory\nSee directories listed below \n"
		tree "$ArtFile"
		cowsay "Select a directory to create the Technical Info_Specs directory, or choose to quit:"
		#prompt for select command
		IFS=$'\n'; select techdir_option in "$accession_dir" "Enter path to parent directory" "Quit" ; do
		#lists options for select command, the ArtFile and subsequent subdirectories, regadless of name. The IFS statment stops it from escaping when it hits spaces in directory names
		case $techdir_option in 
		"$accession_dir") techdir_parent="$accession_dir" &&
		#if ArtFile is selected, it is assigned the variable $techdir_parent
			mkdir -pv "${techdir_parent%/}/Technical Info_Specs/Sidecars" &&
			#creates Technical Info_Specs directory underneath the $techdir_parent
			techdir="${techdir_parent%/}/Technical Info_Specs"
			#assigns the $techdir variable to the newly created directory
			sidecardir="${techdir_parent%/}/Technical Info_Specs/Sidecars"
			#assigns the $sidecardir variable to the newly created directory
			break;;
		"Enter path to parent directory") echo "Enter path to parent directory, use tab complete to help:" &&
			read -e techdir_parent_input &&
			#reads user input and assigns it to the variable $techdir_parent_input
			techdir_parent="$(echo -e "${techdir_parent_input}" | sed -e 's/[[:space:]]*$//')"
			#Strips a trailing space from the input. 
			#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
			#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
			mkdir -pv "${techdir_parent%/}/Technical Info_Specs/Sidecars" &&
			#creates Technical Info_Specs directory underneath the $techdir_parent
			techdir="${techdir_parent%/}/Technical Info_Specs"
			#assigns the $techdir variable to the newly created directory
			sidecardir="${techdir_parent%/}/Technical Info_Specs/Sidecars"
			#assigns the $sidecardir variable to the newly created directory
			break;;
		"Quit") echo "Quitting now..." && exit 1
			#ends the script, exits
			esac	
		done;
		unset IFS
		logNewLine "Path to the staging directory: $techdir" "$MAGENTA"
		logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
	else 
		sidecardir=$(find "${techdir%/}" -maxdepth 2 -type d -iname "*Sidecars*")
		if [[ -z "$sidecardir" ]]; then
		#if the $sidecardir variable is empty (unassigned), then
		#In other words, if the find command fails to find a directory called "sidecars" in the techdir, then
			mkdir -pv "${techdir%/}/Sidecars" &&
			sidecardir="${techdir%/}/Sidecars" 
			logNewLine "Path to the staging directory: $techdir" "$MAGENTA"
			logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
		else
			logNewLine "Path to the staging directory: $techdir" "$MAGENTA"
			logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
		fi
	#States the location of the tech dir if it was found in the inital find command (before the if statement)
	fi
fi
export techdir="${techdir}"
}