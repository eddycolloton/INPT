#!/bin/bash

source "${script_dir}"/output_functions/move/movefiles.sh

set -a

function MultiSelection {
cowsay -s "Select directories from the list below, one at a time. Type the corresponding number and press enter to select one. Repeat as necessary. Once all the directories have been selected, press enter again."
#The majority of this function comes from here: http://serverfault.com/a/298312
options=()
while IFS=  read -r -d $'\0'; do
    options+=("$REPLY")
done < <(find "${Volume%/}" -not -path '*/\.*' ! -iname "System Volume Information" -type d -mindepth 1 -print0)
#I got the array parts of this from https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
#Except for the "not path" stuff, to avoid retrieving hidden files, which comes from here: https://askubuntu.com/questions/266179/how-to-exclude-ignore-hidden-files-and-directories-in-a-wildcard-embedded-find
#The -iname statement ignores directories named "System Volume Information" a hidden directory on a drive I was testing with, that the '*/.*' did not catch. we can add other such directories to this find command over time.
#The curly brackets and %/ around the Volume variable remove a trailing "/" if it is present (does nothing if it isn't there). This prevents a double "//" from ending up in the list of directories.
menu() {
    echo "Avaliable options:"
    for i in ${!options[@]}; do
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    [[ "$msg" ]] && echo "$msg" ; :
}
 
prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done 
#All of this is form http://serverfault.com/a/298312
for i in ${!options[@]}; do 
    [[ "${choices[i]}" ]] && { printf "${options[i]}"; msg=""; printf "\n"; } >> "${techdir}/${accession}_list_of_dirs.txt"
    #This "for" loop used to printf a message with the selected options (from http://serverfault.com/a/298312), but I've changed it to print the output of the chioces to a text file. 
done

declare -a SelectedDirs
#creates an empty array
let i=0
while IFS=$'\n' read -r line_data; do
    #stipulates a line break as a field seperator, then assigns the variable "line_data" to each field read
    SelectedDirs[i]="${line_data}"
    #states that each line will be an element in the arary
    ((++i))
    #adds each new line to the array
done < "${techdir}/${accession}_list_of_dirs.txt"
#populates the array with contents of the text file, with each new line assigned as its own element 
#got this from https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
# echo -e "\nThe selected directories are: ${SelectedDirs[@]}"
DirsList=${SelectedDirs[@]}
#lists the contents of the array, populated by the text file
logNewLine "The selected directories are: "${DirsList}""
}

function SelectFiles {
cowsay -s "Select individual files from the list below, one at a time. Type the corresponding number and press enter to select one. Repeat as necessary. Once all the directories have been selected, press enter again."
#The majority of this function comes from here: http://serverfault.com/a/298312
options=()
while IFS=  read -r -d $'\0'; do
    options+=("$REPLY")
done < <(find "${Volume%/}" -not -path '*/\.*' ! -iname "System Volume Information" -type f -mindepth 1 -print0)
#I got the array parts of this from https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
#Except for the "not path" stuff, to avoid retrieving hidden files, which comes from here: https://askubuntu.com/questions/266179/how-to-exclude-ignore-hidden-files-and-directories-in-a-wildcard-embedded-find
#The -iname statement ignores directories named "System Volume Information" a hidden directory on a drive I was testing with, that the '*/.*' did not catch. we can add other such directories to this find command over time.
#The curly brackets and %/ around the Volume variable remove a trailing "/" if it is present (does nothing if it isn't there). This prevents a double "//" from ending up in the list of directories.
menu() {
    echo "Avaliable options:"
    for i in ${!options[@]}; do
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    [[ "$msg" ]] && echo "$msg" ; :
}
 
prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done 
#All of this is form http://serverfault.com/a/298312
for i in ${!options[@]}; do 
    [[ "${choices[i]}" ]] && { printf "${options[i]}"; msg=""; printf "\n"; } >> "${techdir}/${accession}_list_of_files.txt"
    #This "for" loop used to printf a message with the selected options (from http://serverfault.com/a/298312), but I've changed it to print the output of the chioces to a text file. 
done

declare -a SelectedFiles
#creates an empty array
let i=0
while IFS=$'\n' read -r line_files; do
    #stipulates a line break as a field seperator, then assigns the variable "line_files" to each field read
    SelectedFiles[i]="${line_files}"
    #states that each line will be an element in the arary
    ((++i))
    #adds each new line to the array
done < "${techdir}/${accession}_list_of_files.txt"
#populates the array with contents of the text file, with each new line assigned as its own element 
#got this from https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
#echo -e "\nThe selected files are: ${SelectedFiles[@]}"
FileList=${SelectedFiles[@]}
#lists the contents of the array, populated by the text file
logNewLine "The selected files are: "${FileList}""
}

function UserSelectFiles {
	#Prompts user to tranfer files to Staging Driectory
	#The following select loops set vairable to either "1" or "0". This allows the script to store the user's selection without running the function till the end. 
	#At the end fo the script there are if statements that will run the different functions based on the stored answers from the user  
	echo -e "Copy all files from the volume to the staging directory?"
	select Run_Copyit in "yes" "no, only certain directories" "no, specific files" "none"
	do
	case $Run_Copyit in
		yes) Run_Copyit=1 && Run_MultiCopy=0
			break;;
		"no, only certain directories") MultiSelect=1 && DeleteList && MultiSelection 
			#Runs DeleteList just in case an exisiting list is already in the ArtFile, because the MultiSelection function will create a new one.
			break;;
		"no, specific files") IndvFiles=1 && DeleteList && SelectFiles
			break;;
		none) Run_Copyit=0 && Run_MultiCopy=0
			break;;
	esac
	done

	if [[ "$MultiSelect" -eq "1" ]]; then 
		echo -e "\n*************************************************\n
	Copy $DirsList to:\n ${SDir}?"
		select Run_MultiCopy in "yes" "no"
			do
			case $Run_MultiCopy in
				yes) Run_MultiCopy=1
				break;;
				no) Run_MultiCopy=0
				break;;
			esac
		done
	fi  

	if [[ "$IndvFiles" -eq "1" ]]; then 
		echo -e "\n*************************************************\n
	Copy $FileList to:\n ${SDir}?"
		select Run_FileCopy in "yes" "no"
			do
			case $Run_FileCopy in
				yes) Run_FileCopy=1
				break;;
				no) Run_FileCopy=0
				break;;
			esac
		done
	fi
}

set +a