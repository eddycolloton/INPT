# !/bin/bash

function MakeReportDir {
	mkdir -p "${reportdir_parent%/}/Condition_Tmt Reports" 
	# creates Condition_Tmt Reports directory underneath the $reportdir_parent
	reportdir="${reportdir_parent%/}/Condition_Tmt Reports"
	# assigns the $reportdir variable to the newly created directory
}

AssignReportDir() {
	if [[ -z "$reportdir" ]]; then 
	# if the $reportdir variable is empty (unassigned), then 
		echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find Condition_Tmt Reports directory \n See directories listed below \n"
		tree "$1"
		cowsay "Select a directory to create the Condition_Tmt Reports directory, or choose to quit:"
		# prompt for select command
		IFS=$'\n'; select reportdir_option in "$1" "Enter path to parent directory" "Quit" ; do
		# lists options for select command. The IFS statement stops it from escaping when it hits spaces in directory names
		case $reportdir_option in 
		"$1") reportdir_parent="$1" 
		# if ArtFile is selected, it is assigned the variable $reportdir_parent
			MakeReportDir
			break;;
		"Enter path to parent directory") ConfirmInput reportdir_parent "Enter the path to the parent directory of the new Condition_Tmt Reports directory, use tab complete to help:"			
			MakeReportDir
			break;;
		"Quit") echo "Quitting now..."  
			exit 1
		# ends the script, exits
			esac	
		done;
		unset IFS
		logNewLine "Path to the Condition_Tmt Reports directory: $reportdir" "$Bright_Magenta"
		logNewLine "Metadata output will be written to the appendix.txt file in $reportdir" "$MAGENTA"
	else 
		logNewLine "Path to the Condition_Tmt Reports directory: $reportdir" "$Bright_Magenta"
		logNewLine "Metadata output will be written to the appendix.txt file in $reportdir" "$MAGENTA"
	# States the location of the report dir if it was found in the initial find command (before the if statement)
	fi
}

AssignTechDir() {
	if [[ -z "$techdir" ]]; then
	# if the $techdir variable is empty (unassigned), then 
		echo -e "\n*************************************************\n \nThe artwork file does not match expected directory structure. \nCannot find Technical Info_Specs directory\nSee directories listed below \n"
		tree "$1"
		cowsay "Select a directory to create the Technical Info_Specs directory, or choose to quit:"
		# prompt for select command
		IFS=$'\n'; select techdir_option in "$1" "Enter path to parent directory" "Quit" ; do
		# lists options for select command, the ArtFile and subsequent subdirectories, regardless of name. The IFS statement stops it from escaping when it hits spaces in directory names
		case $techdir_option in 
		"$1") techdir_parent="$1"
		# if ArtFile is selected, it is assigned the variable $techdir_parent
			MakeTechAndSidecarDir
			break;;
		"Enter path to parent directory") ConfirmInput techdir_parent "Enter the path to the parent directory of the new Technical Info_Specs directory, use tab complete to help:" 		
			MakeTechAndSidecarDir
			break;;
		"Quit") echo "Quitting now..."  
			exit 1
			# ends the script, exits
			esac	
		done;
		unset IFS
		logNewLine "Path to the Technical Info_Specs directory: $techdir" "$Bright_Magenta"
		logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
	else 
		sidecardir=$(find "${techdir%/}" -maxdepth 2 -type d -iname "*Sidecars*")
		if [[ -z "$sidecardir" ]]; then
		# if the $sidecardir variable is empty (unassigned), then
		# In other words, if the find command fails to find a directory called "sidecars" in the techdir, then
			mkdir -p "${techdir%/}/Sidecars"
			sidecardir="${techdir%/}/Sidecars" 
			logNewLine "Path to the Technical Info_Specs directory: $techdir" "$Bright_Magenta"
			logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
		else
			logNewLine "Path to the Technical Info_Specs directory: $techdir" "$Bright_Magenta"
			logNewLine "Metadata output will be written to sidecar files in $sidecardir" "$MAGENTA"
		fi
	# States the location of the tech dir if it was found in the inital find command (before the if statement)
	fi
}

function FindConditionDir {
if [[ -z "$accession_dir" ]]; then
	# if the $accession_dir variable is empty (unassigned - which would mean there was only one artwork found in the Art File, then) 
	reportdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Condition*")
	# looks for a directory with Condition in the name that is a subdirectory of $ArtFile and, if found, assigns it to the $reportdir variable
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignReportDir "${ArtFile%/}"
else
	reportdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Condition*")
	# looks for a directory with Condition in the name that is a subdirectory $accession_dir, if found, assigns it to the $reportdir variable
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignReportDir "${accession_dir%/}"
fi
export reportdir="${reportdir}"
}

function MakeTechAndSidecarDir {
	mkdir -p "${techdir_parent%/}/Technical Info_Specs/Sidecars"
	# creates Technical Info_Specs directory underneath the $techdir_parent
	techdir="${techdir_parent%/}/Technical Info_Specs"
	# assigns the $techdir variable to the newly created directory
	sidecardir="${techdir_parent%/}/Technical Info_Specs/Sidecars"
	# assigns the $sidecardir variable to the newly created directory
}

function FindTechDir {
if [[ -z "$accession_dir" ]]; then
	techdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Technical Info*")
	# looks for the Technical Info_Specs directory
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignTechDir "${ArtFile%/}"
else
	techdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Technical Info*")
	# looks for the Technical Info_Specs directory
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignTechDir "${accession_dir%/}"
fi
export techdir="${techdir}"
export sidecardir="${sidecardir}"
}