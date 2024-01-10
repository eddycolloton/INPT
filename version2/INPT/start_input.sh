#!/bin/bash

set -a

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
parent_dir="$(dirname "$script_dir")"

figlet INPT

source "${script_dir}"/input_functions/makelog.sh
MakeLog
CleanupLogDir

source "${script_dir}"/input_functions/inputs.sh
if test -f "${parent_dir}"/input_template.csv; then
# Read the CSV file
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
        # Print debug information
        # echo "Key: $key, Value: $value"
    done < "${parent_dir}"/input_template.csv
    logNewLine "input csv found at "${parent_dir}"/input_template.csv" "$CYAN"
else
    logNewLine "No input csv found" "$RED"
fi
	
if [[ -z "${ArtistLastName}" ]] ; then
    source "${script_dir}"/input_functions/inputs.sh
    InputArtistsName
else
    logNewLine "Artist name found in CSV: ${ArtistFirstName} ${ArtistLastName}" "$WHITE"
fi

if [[ -z "${ArtFile}" ]] ; then
    echo -e "\nNo path to the artwork file found in input csv\n"
    source "${script_dir}"/input_functions/find/findartfile.sh
    FindArtworkFilesPath
    FindArtworkFile
else
    echo "Artwork File: $ArtFile"
    logNewLine "The artwork file path from CSV: ${ArtFile}" "$WHITE"
fi

if [[ -z "${accession}" ]] ; then
    echo "No accession number in input csv"
    source "${script_dir}"/input_functions/find/findartfile.sh
    if [[ -z "${ArtFilePath}" ]] ;
    then
        FindArtworkFilesPath
    fi 
    FindAccessionNumber 
    logNewLine "The accession number manually input: ${accession}" "$CYAN"
elif grep -q "accession" "${logPath}" ; then
    true
else
    logNewLine "The accession number from CSV: ${accession}" "$WHITE"
fi

if [[ -z "${Volume}" ]] ; then
    echo -e "\nNo volume path in input csv"
    source "${script_dir}"/input_functions/find/findvolume.sh
    FindVolume
else
    logNewLine "The path to the volume from CSV: ${Volume}" "$WHITE"
fi

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

if [[ -z "${techdir}" ]] ; then
    echo -e "\nNo path to the Technical Info and Specs directory found in input csv\n"
    source "${script_dir}"/input_functions/find/findreportdir.sh
    FindTechDir
else
    logNewLine "Technical Info and Specs: $techdir" "$WHITE"
fi

if [[ -z "${reportdir}" ]] ; then
    echo -e "\nNo path to the Condition_Tmt Reports directory found in input csv\n"
    source "${script_dir}"/input_functions/find/findreportdir.sh
    FindConditionDir
else
    logNewLine "Condition Report: $reportdir \nSidecar directory: $sidecardir" "$WHITE"
fi

LogVars

csv_file="${techdir}"/"${ArtistLastName}_${accession}_${timestamp}.csv"
WriteVarsToCSV "${csv_file}"
export csv_file="${csv_file}"


#MakeVarfile
#logNewLine "The varfile has been created using the file name $varfilePath" "$YELLOW"

source "${script_dir}"/start_output.sh

set +a