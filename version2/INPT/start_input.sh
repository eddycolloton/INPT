#!/bin/bash

set -a

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
parent_dir="$(dirname "$script_dir")"

figlet INPT

source "${script_dir}"/input_functions/makelog.sh
MakeLog
CleanupLogDir

if [[ "$#" -lt 1 ]]; then
    logNewLine "No input CSV files provided!" "$RED"
fi

# Assign the first argument to a variable
input_file_path=$1

# Check if the file exists
if [ ! -f "$input_file_path" ]; then
    logNewLine "The provided file ${input_file_path} does not exist." "$RED"
fi

# Check the content of the file to determine its type
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

if [[ -n "${input_csv}" ]] ; then
    logNewLine "Reading variables from input csv: ${input_csv}" "$CYAN"
    source "${script_dir}"/input_functions/inputs.sh
    # remove_special_chars function is stored in inputs.sh
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
            key=$(remove_special_chars "$key" | tr -d '"')
            value=$(remove_special_chars "$value" | tr -d '"')
            # Assign the value to a variable named after the key
            declare "$key=$value"
            ## consider creating an array here of assigned variables to simplify the rest of the script
            ## if assigned vars are in an array then you could run 'if $var not in $array ; then' 
            # Print debug information
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
    if [[ -z "${ArtistLastName}" ]] ; then
        source "${script_dir}"/input_functions/inputs.sh
        InputArtistsName
    else
        logNewLine "Artist name found in CSV: ${ArtistFirstName} ${ArtistLastName}" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/inputs.sh
    InputArtistsName
fi

if [[ -n "${input_csv}" ]] ; then
    if [[ -z "${ArtFile}" ]] ; then
        echo -e "\nNo path to the artwork file found in input csv\n"
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

# This chunk has gotten messy and I think unnecessarily so, need to investigate the possibility of not having accession number in csv AND not having it from FindArtworkFile...
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
    if [[ -z "${Volume}" ]] ; then
        echo -e "\nNo volume path in input csv"
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
    if [[ -z "${SDir}" ]] ; then
        echo -e "\nNo path to Staging Directory found in input csv\n"
        source "${script_dir}"/input_functions/find/findsdir.sh
        if [[ -z "${TBMADroBoPath}" ]]; then
            FindTBMADroBoPath
        fi
        FindSDir
        # added logging functions for sdir to input_functions/find/findsdir.sh
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
    if [[ -z "${techdir}" ]] ; then
        echo -e "\nNo path to the Technical Info and Specs directory found in input csv\n"
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
        echo -e "\nNo path to the Condition_Tmt Reports directory found in input csv\n"
        source "${script_dir}"/input_functions/find/findreportdir.sh
        FindConditionDir
    else
        logNewLine "Condition Report: $reportdir \nSidecar directory: $sidecardir" "$WHITE"
    fi
else
    source "${script_dir}"/input_functions/find/findreportdir.sh
    FindConditionDir
fi

LogVars

WriteVarsToCSV
CompareCSV "${fullInput_csv}"
if [[ "${old_csv_again}" = "yes" ]] ; then
    CompareCSV "${fullInput_csv}"
fi

source "${script_dir}"/start_output.sh

set +a