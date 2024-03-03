#!/bin/bash

function DeleteList {
#test -f $(find "$techdir" -type f \( -iname "*_list_of_dirs.txt" -o -iname "*_list_of_files.txt" \)) && 
find "$techdir" -type f \( -iname "*_list_of_dirs.txt" -o -iname "*_list_of_files.txt" \) -print0 |
	while IFS= read -r -d '' l;
		do rm "$l"
	done
}

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
    
    prompt="Check an option (again to uncheck, ENTER when done): 
    "
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
    echo -e "The selected directories are: ${DirsList}" 
    export DirsList="${DirsList}"
}

RunThisTool () {
	local tool_name="$1"
	local input="$2"
	local command="$3"
	local suffix="$4"
	local extension_list_string="$5"

	IFS=' ' read -r -a extension_list <<< "${extension_list_string}"

	tool_again=yes
	while [[ "$tool_again" = yes ]] ; do
		SECONDS=0  
		echo -e "$tool_name started! $tool_name will be run on $input"
		#prints statement to terminal
		if [[ "$command" == "tree" ]]; then
			$command "${input}" > ${SDir}/"${accession}_${suffix}".txt
			echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
			cat ${SDir}/"${accession}_${suffix}.txt" >> "${reportdir}/${accession}_appendix.txt"  
			cp ${SDir}/"${accession}_${suffix}.txt" "$sidecardir"
		else
			find "${input}" -type f  \( "${extension_list[@]}" \) ! -iname "*qctools*" -print0 | 
			while IFS= read -r -d '' i; do
				# conditional statements below account for different command structures of different tools
				if [[ "$command" == "ffmpeg -hide_banner -nostdin -i" ]]; then
					$command "$i" -f framemd5 -an  "${i%.*}_${suffix}".txt
					echo -e "${tool_name} run on $(basename ${i})"  
				elif [[ "$command" == "qcli -i" ]]; then
					$command "$i"
					echo -e "${tool_name} run on $(basename ${i})"  
				else
					$command "$i" > "${i%.*}_${suffix}."txt 
					echo -e "${tool_name} run on $(basename ${i})"  
				fi
			done
			# Search for side car files and, if found, move contents of sidecars to additional outputs (appendix and sidecars directory of the artwork file)
			find "$input" -type f \( -iname "*_${suffix}.txt" \) -print0 |
			while IFS= read -r -d '' t; do 
				cp "$t" "$sidecardir"
				if [[ "$suffix" != "framemd5" ]] ; then
					echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
					cat "$t" >> "${reportdir}/${accession}_appendix.txt"
				fi
			done
		fi
		# because the input for tree will be the $volume, need to reassign the input variable to work with the find command below, which will ensure find is searching where tree output is sent
		if [[ "$command" == "tree" ]]; then
			input="$SDir"
		fi
		# Search sidecars if recent output is found, log timing and outputs, otherwise report no output and offer to run tool again 
		if [[ -n $(find "${input}" -name "*${suffix}*" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
		# the -newermt option along with the date command finds files modified within the last 10 seconds. The $(date -v-10S) command generates a timestamp representing the time 10 seconds ago, and the -newermt option filters files modified after that timestamp.
			duration=$SECONDS
			echo -e "===================> ${tool_name} complete! Total Execution Time: $(($duration / 60)) m $(($duration % 60)) s"
			if [[ "$tool_name" != "Frame MD5" ]] ; then
				echo -e "${tool_name} output written to ${accession}_appendix.txt and saved as a sidecar file"  
			fi
			tool_again=no
		else 
			echo -e "No ${tool_name} files found in $input" 
			echo -e "\n Run ${tool_name} again? (Choose a number 1-2)"
			select tool_again_option in "yes" "no"
			do
				case $tool_again_option in
					yes) tool_again=yes
					# set again variable to enable loop
					break;;
					no) tool_again=no
					break;;
					esac
			done
		fi

		# if the user selects to run the tool again the "while [[ "$tool_again" = yes ]] ; do" will loop through again
		if [[ "$tool_again" = yes ]]; then
			echo -e "Re-running ${tool_name} on $input" 
		fi

	done
}

SelectedInSDirArray() {
    local dirs_string="$1"
    local sdir="$2"
    local transformed_array=()

    unset dirs_array

    IFS=' ' read -r -a dirs_array <<< "$dirs_string"

    for dir in "${dirs_array[@]}"; do
        local basename=$(basename "$dir")
        transformed_array+=("$sdir/$basename")
    done
    echo "${transformed_array[@]}"
}

Volume='/Users/eddycolloton/git/INPT/sample_files'
SDir='/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA'
sidecardir='/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/AAA, Faker/time-based media/01.01_Something/Technical Info_Specs/Sidecars'
techdir='/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/AAA, Faker/time-based media/01.01_Something/Technical Info_Specs'
reportdir='/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/AAA, Faker/time-based media/01.01_Something/Conservation/Condition_Tmt Reports'
accession='01.01'
input_test="/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA/smpte_bars_prores.mov"

DeleteList

MultiSelection

SelectedInSDirArray "${DirsList}" "${SDir}"

RunToolOnDirArray () {
    directories=("$@")

    for dir in "${directories[@]}"; do
        echo "searching $dir for files"
        RunThisTool "MediaInfo" "$dir" "mediainfo -f" "mediainfo" "-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg -o -iname *.wav -o -iname *.mp3"
    done
}

RunToolOnDirArray "${dirs_array[@]}"