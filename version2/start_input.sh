#!/bin/bash

set -a

# Function to remove BOM and non-printable characters
remove_special_chars() {
    local str=$1
    str=$(printf '%s' "$str" | LC_ALL=C tr -dc '[:print:]\n')
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    echo "$str"
}

if test -f input_template.csv; then
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
    done < input_template.csv
else
    echo "No input csv found"
fi
	
if [[ -z "${ArtistLastName}" ]] ; then
    echo -e "\n*************************************************\nInput artist's first name"
    read -e ArtistFirstName
    #Asks for user input and assigns it to variable
    echo -e "\n*************************************************\nInput artist's last name"
    read -e ArtistLastName
    #Asks for user input and assigns it to variable
    echo -e "\n Artist name is $ArtistFirstName $ArtistLastName"
else
# Print the values of the assigned variables
echo "ArtistFirstName: $ArtistFirstName"
echo "ArtistLastName: $ArtistLastName"
fi

if [[ -z "${ArtFile}" ]] ; then
    echo "No path to the artwork file found in input csv"
    source `dirname "$0"`/findartfile.sh
    FindArtworkFilesPath
    FindArtworkFile
else
    echo "Artwork File: $ArtFile"
fi

if [[ -z "${accession}" ]] ; then
    echo "No accession number in input csv"
    source `dirname "$0"`/findartfile.sh
    if [[ -z "${ArtFilePath}" ]] ;
    then
        FindArtworkFilesPath
    fi 
    FindAccessionNumber 
else
    echo "Artwork File: $ArtFile"
fi

if [[ -z "${Volume}" ]] ; then
    echo "No volume path in input csv"
    source `dirname "$0"`/findvolume.sh 
    FindVolume
else
    echo "Volume: $Volume"
fi

if [[ -z "${SDir}" ]] ; then
    echo "No path to Staging Directory found in input csv"
    source `dirname "$0"`/findsdir.sh
    if [[ -z "${TBMADroBoPath}" ]]; then
        FindTBMADroBoPath
    fi
    FindSDir
else
    echo "Staging Directory: $SDir"
fi

if [[ -z "${techdir}" ]] ; then
    echo "No path to the Technical Info and Specs directory found in input csv"
    source `dirname "$0"`/findreportdir.sh
    FindTechDir
else
    echo "Technical Info and Specs: $techdir"
fi

if [[ -z "${reportdir}" ]] ; then
    echo "No path to the Condition_Tmt Reports directory found in input csv"
    source `dirname "$0"`/findreportdir.sh
    FindConditionDir
else
    echo -e  "Condition Report: $reportdir \nSidecar directory: $sidecardir"
fi

source `dirname "$0"`/makelog.sh
MakeLog
MakeVarfile

source `dirname "$0"`/start_output.sh

set +a