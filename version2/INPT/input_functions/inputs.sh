#!/bin/bash

set -a

# Function to remove BOM and non-printable characters
function remove_special_chars {
    local str=$1
    str=$(printf '%s' "$str" | LC_ALL=C tr -dc '[:print:]\n')
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    echo "$str"
}

function InputArtistsName {
    name_again=yes
    while [[ "$name_again" = yes ]]
    do
    echo -e "\n*************************************************\nInput artist's first name"
    read -e ArtistFirstName
    #Asks for user input and assigns it to variable
    echo -e "\n*************************************************\nInput artist's last name"
    read -e ArtistLastName
    #Asks for user input and assigns it to variable
    logNewLine "Artist name manually input: ${ArtistFirstName} ${ArtistLastName}" "$CYAN"
    echo -e "\nIs the artist's name correct?"
    IFS=$'\n'; select name_option in "Yes" "No, go back a step" ; do
    if [[ $name_option = "Yes" ]] ;
        then
            name_again=no
    elif [[ $name_option = "No, go back a step" ]] ;
        then 
            unset ArtistFirstName ArtistLastName
    fi
    break           
    done;

    if [[ "$name_again" = yes ]]
    then echo -e "Let's try again"
    fi
    
    done

}

set +a