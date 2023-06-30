#!/bin/bash

# Function to remove BOM and non-printable characters
remove_special_chars() {
    local str=$1
    str=$(printf '%s' "$str" | LC_ALL=C tr -dc '[:print:]\n')
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    echo "$str"
}

# Read the CSV file
while IFS=, read -r key value
do
    # Remove quotes and special characters from the key and value
    key=$(remove_special_chars "$key" | tr -d '"')
    value=$(remove_special_chars "$value" | tr -d '"')
    # Assign the value to a variable named after the key
    declare "$key=$value"
done < input_template.csv
	
if [[ -z "${ArtistLastName}" ]] ;
then
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

if [[ -z "${accession}" ]] ;
then
    echo "No accession number in input csv"
else
    echo "accession: $accession"
fi

if [[ -z "${Volume}" ]] ;
then
    echo "No volume path in input csv"
else
    echo "Volume: $Volume"
fi
    
