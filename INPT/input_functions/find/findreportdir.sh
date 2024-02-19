# !/bin/bash

MakeDirectory() {
    if [[ "$dir_type" == "techdir" ]]; then
        sidecardir=$(find "${!dir_type%/}" -maxdepth 2 -type d -iname "*Sidecars*")
        if [[ -z "$sidecardir" ]]; then
            mkdir -p "${dir_type_parent%/}/${dir_label}/Sidecars"
            dir_path="${dir_type_parent%/}/${dir_label}"
			eval "$dir_type=\"\$dir_path\""
            sidecardir="${dir_type_parent%/}/${dir_label}/Sidecars" 
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
        sleep 1
		tree "$parent_dir"
		sleep 1
        cowsay "Select a directory to create the $dir_label directory, or choose to quit:"
        IFS=$'\n'; select dir_option in "$parent_dir" "Enter path to parent directory" "Quit"; do
            case $dir_option in 
                "$parent_dir") dir_type_parent="$parent_dir"
                            MakeDirectory
                            break;;
                "Enter path to parent directory") ConfirmInput dir_type_parent "Enter the path to the parent directory of the new $dir_label directory, use tab complete to help:"
                                                    MakeDirectory
                                                    break;;
                "Quit") echo "Quitting now..."
                        exit 1;;
            esac
        done
        unset IFS
        logNewLine "Path to the $dir_label directory: ${!dir_type}" "$Bright_Magenta"
        logNewLine "Metadata output will be written to the appendix.txt file in ${!dir_type}" "$MAGENTA"
    else
        logNewLine "Path to the $dir_label directory: ${!dir_type}" "$Bright_Magenta"
        logNewLine "Metadata output will be written to the appendix.txt file in ${!dir_type}" "$MAGENTA"
    fi
}

function FindConditionDir {
if [[ -z "$accession_dir" ]]; then
	# if the $accession_dir variable is empty (unassigned - which would mean there was only one artwork found in the Art File, then) 
	reportdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Condition*")
	# looks for a directory with Condition in the name that is a subdirectory of $ArtFile and, if found, assigns it to the $reportdir variable
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignDirectory "reportdir" "Condition_Tmt Reports" "${ArtFile%/}"
else
	reportdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Condition*")
	# looks for a directory with Condition in the name that is a subdirectory $accession_dir, if found, assigns it to the $reportdir variable
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignDirectory "reportdir" "Condition_Tmt Reports" "${accession_dir%/}"
fi
export reportdir="${reportdir}"
}



function FindTechDir {
if [[ -z "$accession_dir" ]]; then
	techdir=$(find "${ArtFile%/}" -maxdepth 4 -type d -iname "*Technical Info*")
	# looks for the Technical Info_Specs directory
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignDirectory  "techdir" "Technical Info_Specs" "${ArtFile%/}"
else
	techdir=$(find "${accession_dir%/}" -maxdepth 4 -type d -iname "*Technical Info*")
	# looks for the Technical Info_Specs directory
	# The "%/" removes the trailing "/" on the end of the ArtFile
	AssignDirectory  "techdir" "Technical Info_Specs"  "${accession_dir%/}"
fi
export techdir="${techdir}"
export sidecardir="${sidecardir}"
}