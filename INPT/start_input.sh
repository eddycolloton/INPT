#!/bin/bash

set -a

## defines directory of script and parent directory
script_dir=$(realpath $(dirname $0))
parent_dir="$(dirname "$script_dir")"

figlet INPT

## Create log and if check logs directory. If there are 20+ logs, delete all but most recent 5 logs. 
# more details in input_functions/makelog.sh
source "${script_dir}"/input_functions/makelog.sh
MakeLog
CleanupLogDir

# Check if a file path has escaped characters
has_escaped_characters() {
    local path="$1"
    local escaped_pattern="\\"

    if [[ "$path" == *"$escaped_pattern"* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

if [[ "$#" -lt 1 ]]; then
# If command line arguments are less than 1, then:
    logNewLine "No input CSV files provided!" "$RED"
else
    for arg in "$@"; do
        if [[ $arg == -* ]]; then
            if [[ "$arg" == "-t" ]] || [[ "$arg" == "--typos" ]]; then
                typo_check=true
            fi
            # Can add more if statements here for other flags
        else
            input_file_path=$arg
            # Assign the first argument to a variable
            if [[ ! -f "$input_file_path" ]]; then
            # if $input_file_path is not a file then,
                logNewLine "The provided file ${input_file_path} does not exist." "$RED"
            else
                # Check the content of the file to determine it matches expected first line of input.csv or output.csv
                first_line=$(head -n 1 "$input_file_path")
                # Check if it's an input CSV file
                if [[ "$first_line" == "Artist's First Name,"* ]]; then
                    input_csv=$input_file_path
                    logNewLine "Input CSV file detected: $input_csv" "$WHITE"
                # Check if it's an output CSV file
                elif [[ "$first_line" == "Move all files to staging directory,"* ]]; then
                    output_csv=$input_file_path
                    logNewLine "Output CSV file detected: $output_csv" "$WHITE"
                else
                    logNewLine "Error: Unsupported CSV file format." "$RED"
                fi
            fi
        fi
    done
fi

# After checking the first line, if an input file has been identified then read inputs and assign them to variables
if [[ -n "${input_csv}" ]] ; then
    logNewLine "Reading variables from input csv: ${input_csv}" "$CYAN"
    source "${script_dir}"/input_functions/find/findartfile.sh
    # remove_special_chars function is stored in findartfile.sh
    if test -f "${input_csv}"; then
    # test that input_csv is a file
        while IFS=, read -r key value || [ -n "$key" ]
        do
            # Replace variable names with descriptions
            case $key in
                "Artist's First Name") key="ArtistFirstName" ;;
                "Artist's Last Name") key="ArtistLastName" ;;
                "Artwork Title") key="title" ;;
                "Accession Number") key="accession" ;;
                "Path to Artwork File on T: Drive") key="ArtFile" ;;
                "Staging Directory on DroBo") key="SDir" ;;
                "Path to hard drive") key="Volume" ;;
                "Path to Technical Info_Specs directory") key="techdir" ;;
                "Path to Technical Info_Specs/Sidecars directory") key="sidecardir" ;;
                "Path to Condition_Tmt Reports directory") key="reportdir" ;;
                "Path Artwork Files parent directory") key="ArtFilePath" ;;
                "Path to the Time-based Media Artworks directory on the TBMA DroBo") key="TBMADroBoPath" ;;
            esac

            # Remove quotes and special characters from the key and value
            key=$(remove_special_chars "$key")
            value=$(remove_special_chars "$value")

            # For variables that store paths, check for "escaped characters" (like this: '/Lastname\,\ Firstname/time-based\ media/')
            # If escaped characters are found, remove them and convert to a normal path (like this: '/Lastname, Firstname/time-based media/')
            case $key in
                "ArtFile" | "SDir" | "Volume" | "techdir" | "sidecardir" | "reportdir" | "ArtFilePath" | "TBMADroBoPath")
                    # Check if the value contains escaped characters
                    if [[ $(has_escaped_characters "$value") == true ]]; then
                        value=$(echo "$value" | sed 's/\\//g')
                    fi
                    ;;
            esac

            # Assign the value to a variable named after the key
            declare "$key=$value"
            # Print debug information but uncommenting line below:
            # echo "Key: $key, Value: $value"
        done < "${input_csv}"
        logNewLine "Successfully read variables from ${input_csv}" "$CYAN"
    else
        logNewLine "Unable to read variables from ${input_csv}" "$RED"
        unset input_csv
    fi
fi
	
if [[ -n "${input_csv}" ]] ; then
# if input_csv has been assigned, then
    if [[ -n "${ArtFile}" ]] ; then
    # if artwork file has been assigned, 
        source "${script_dir}"/input_functions/find/findartfile.sh
        ParseArtFile "${ArtFile}"
        # parse artwork file path for artist first and last name
        FindAccessionNumber 
        # parse artwork file for accession
    fi
    if [[ -z "${ArtistLastName}" ]] ; then
    # if artist's name has not been assigned, then:
        source "${script_dir}"/input_functions/find/findartfile.sh
        if [[ "$typo_check" == true ]] ; then
            name_again=yes
            ConfirmArtistsName
        else
            InputArtistsName
        fi
    else
        # consdier adding a check here. If artist's name doesn't match any in artwork folders then confirm? Use different artist name database?
        logNewLine "Artist name found in CSV: ${ArtistFirstName} ${ArtistLastName}" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findartfile.sh
    if [[ "$typo_check" == true ]] ; then
        name_again=yes
        ConfirmArtistsName
    else
        InputArtistsName
    fi
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${ArtFile}" ]] ; then
        logNewLine "No path to the artwork file found in input csv" "$WHITE"
        source "${script_dir}"/input_functions/find/findartfile.sh
        FindArtworkFilesPath
        FindArtworkFile
    else
        logNewLine "The artwork file path from CSV: ${ArtFile}" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findartfile.sh
    FindArtworkFilesPath
    FindArtworkFile
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${accession}" ]] ; then
        echo "No accession number in input csv"
        source "${script_dir}"/input_functions/find/findartfile.sh
        if [[ -z "${ArtFilePath}" ]] ;
        then
            FindArtworkFilesPath
        fi 
        FindAccessionNumber 
        logNewLine "The accession number manually input: ${accession}" "$CYAN"
    else
        logNewLine "The accession number from CSV: ${accession}" "$WHITE"
    fi
else
    if [[ -z "${accession}" ]] ; then
        source "${script_dir}"/input_functions/find/findartfile.sh
        if [[ -z "${ArtFilePath}" ]] ;
        then
            FindArtworkFilesPath
        fi 
        FindAccessionNumber 
        logNewLine "The accession number manually input: ${accession}" "$CYAN"
    fi
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${SDir}" ]] ; then
        logNewLine "No path to Staging Directory found in input csv" "$WHITE"
        source "${script_dir}"/input_functions/find/findsdir.sh
        if [[ -z "${TBMADroBoPath}" ]]; then
            FindTBMADroBoPath
        fi
        FindSDir
    else
        logNewLine "Path to the staging directory from CSV: ${SDir}" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findsdir.sh
    if [[ -z "${TBMADroBoPath}" ]]; then
        FindTBMADroBoPath
    fi
    FindSDir
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${Volume}" ]] ; then
        logNewLine "No volume path in input csv" "$WHITE"
        source "${script_dir}"/input_functions/find/findvolume.sh
        FindVolume
    else
        logNewLine "The path to the volume from CSV: ${Volume}" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findvolume.sh
    FindVolume
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${techdir}" ]] ; then
        logNewLine "No path to the Technical Info and Specs directory found in input csv" "$WHITE"
        source "${script_dir}"/input_functions/find/findreportdir.sh
        FindTechDir
    else
        logNewLine "Technical Info and Specs: $techdir" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findreportdir.sh
    FindTechDir
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${reportdir}" ]] ; then
        logNewLine "No path to the Condition_Tmt Reports directory found in input csv" "$WHITE"
        source "${script_dir}"/input_functions/find/findreportdir.sh
        FindConditionDir
    else
        logNewLine "Condition Report: $reportdir \nSidecar directory: $sidecardir" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findreportdir.sh
    FindConditionDir
fi

# Write all assigned variables to log
LogVars

# Write all assigned variables to csv, then compare to any existing csvs in the artwork file
WriteVarsToCSV
CompareCSV "${fullInput_csv}"
if [[ "${old_csv_again}" = "yes" ]] ; then
    CompareCSV "${fullInput_csv}"
fi

# run start_output
source "${script_dir}"/start_output.sh

set +a