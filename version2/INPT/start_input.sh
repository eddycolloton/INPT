#!/bin/bash

set -a

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
parent_dir="$(dirname "$script_dir")"

figlet INPT

source "${script_dir}"/input_functions/makelog.sh
MakeLog

# Function to remove BOM and non-printable characters
remove_special_chars() {
    local str=$1
    str=$(printf '%s' "$str" | LC_ALL=C tr -dc '[:print:]\n')
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    echo "$str"
}

if test -f "${parent_dir}"/input_template.csv; then
  # Read the CSV file
    while IFS=, read -r key value || [ -n "$key" ]
    do
        # Remove quotes and special characters from the key and value
        key=$(remove_special_chars "$key" | tr -d '"')
        value=$(remove_special_chars "$value" | tr -d '"')
        # Assign the value to a variable named after the key
        declare "$key=$value"
        # Print debug information
        # echo "Key: $key, Value: $value"
    done < "${parent_dir}"/input_template.csv
    logNewLine "input csv found at "${parent_dir}"/input_template.csv" "$YELLOW"
else
    logNewLine "No input csv found" "$RED"
fi
	
if [[ -z "${ArtistLastName}" ]] ; then
    echo -e "\n*************************************************\nInput artist's first name"
    read -e ArtistFirstName
    #Asks for user input and assigns it to variable
    echo -e "\n*************************************************\nInput artist's last name"
    read -e ArtistLastName
    #Asks for user input and assigns it to variable
    logNewLine "Artist name manually input: ${ArtistFirstName} ${ArtistLastName}" "$YELLOW"
else
    logNewLine "Artist name found in CSV: ${ArtistFirstName} ${ArtistLastName}" "$YELLOW"
fi

if [[ -z "${ArtFile}" ]] ; then
    echo -e "\nNo path to the artwork file found in input csv"
    source "${script_dir}"/input_functions/findartfile.sh
    FindArtworkFilesPath
    FindArtworkFile  
else
    echo "Artwork File: $ArtFile"
    logNewLine "The artwork file path from CSV: ${ArtFile}" "$YELLOW"
fi


if [[ -z "${accession}" ]] ; then
    echo "No accession number in input csv"
    source "${script_dir}"/input_functions/findartfile.sh
    if [[ -z "${ArtFilePath}" ]] ;
    then
        FindArtworkFilesPath
    fi 
    FindAccessionNumber 
    logNewLine "The acession number manually input: ${accession}" "$YELLOW"
else
    logNewLine "The acession number is: ${accession}" "$YELLOW"
fi

if [[ -z "${Volume}" ]] ; then
    echo -e "\nNo volume path in input csv"
    source "${script_dir}"/input_functions/findvolume.sh
    FindVolume
    logNewLine "The path to the volume manually input: ${Volume}" "$YELLOW"
else
    echo "Volume: $Volume"
    logNewLine "The path to the volume from CSV: ${Volume}" "$YELLOW"
fi

if [[ -z "${SDir}" ]] ; then
    echo -e "\nNo path to Staging Directory found in input csv"
    source "${script_dir}"/input_functions/findsdir.sh
    if [[ -z "${TBMADroBoPath}" ]]; then
        FindTBMADroBoPath
    fi
    FindSDir
    logNewLine "Path to the staging directory manually input: ${SDir}" "$YELLOW"
else
    echo "Staging Directory: $SDir"
    logNewLine "Path to the staging directory from CSV: ${SDir}" "$YELLOW"
fi

if [[ -z "${techdir}" ]] ; then
    echo -e "\nNo path to the Technical Info and Specs directory found in input csv"
    source "${script_dir}"/input_functions/findreportdir.sh
    FindTechDir
else
    logNewLine "Technical Info and Specs: $techdir" "$YELLOW"
fi

if [[ -z "${reportdir}" ]] ; then
    echo -e "\nNo path to the Condition_Tmt Reports directory found in input csv"
    source "${script_dir}"/input_functions/findreportdir.sh
    FindConditionDir
else
    logNewLine "Condition Report: $reportdir \nSidecar directory: $sidecardir" "$YELLOW"
fi

LogVars
MakeVarfile

source "${script_dir}"/start_output.sh

set +a