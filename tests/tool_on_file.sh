#!/bin/bash

check_var() {
    if [[ "$(declare -p var 2>/dev/null)" =~ "declare -a" ]]; then
        echo "Variable contains an array."
    elif [[ -d "${var}" ]]; then
        echo "Variable contains a directory."
    else
        echo "Variable does not contain a directory or an array."
    fi
}

#This function runs tree on the Volume sends the output to three text files 
RunToolOnFile () {
    local file="$1"
    local tool_name="$2"
    local command="$3"
    local suffix="$4"
            
    tool_again=yes
    while [[ "$tool_again" = yes ]] ; do
        if [[ "$command" == "ffmpeg -hide_banner -nostdin -i" ]]; then
            $command "$file" -f framemd5 -an  "${file%.*}_${suffix}".txt
            echo -e "${tool_name} run on $(basename ${file})"
        elif [[ "$command" == "qcli -i" ]]; then
            $command "$file"
            echo -e "${tool_name} run on $(basename ${file})"
        else
            $command "$file" > "${file%.*}_${suffix}."txt 
            echo -e "${tool_name} run on $(basename ${file})"
        fi   
        find "$SDir" -type f \( -iname "*_${suffix}.txt" \) -print0 |
        while IFS= read -r -d '' t; 
            do 
            cp "$t" "$sidecardir"
            echo -e "\n***** ${tool_name} output ***** \n" >> "${reportdir}/${accession}_appendix.txt"
            cat "$t" >> "${reportdir}/${accession}_appendix.txt"
        done
        if [[ -n $(find "${SDir}" -name "*${suffix}*" -newermt "$(date -v-10S '+%Y-%m-%d %H:%M:%S')") ]] ; then
        # the -newermt option along with the date command finds files modified within the last 10 seconds. The $(date -v-10S) command generates a timestamp representing the time 10 seconds ago, and the -newermt option filters files modified after that timestamp.
            duration=$SECONDS
            echo -e "${tool_name} run on ${file}! Execution Time: $(($duration / 60)) m $(($duration % 60)) s" 
            echo -e "${tool_name} output written to ${accession}_appendix.txt and saved as a sidecar file" 
            tool_again=no
        else 
            echo -e "No ${tool_name} files found in $SDir" 
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

    if [[ "$tool_again" = yes ]]; then
        echo -e "Re-running ${tool_name} on $file"
    fi

    done

    unset tool_again
}

RunToolOnFileArray () {
    files=("$@")

    for file in "${files[@]}"; do
        RunToolOnFile $file "MediaInfo" "mediainfo -f" "mediainfo" 
    done
}

#var=("/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA/dir1" "/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA/dir2")

#var='/Users/eddycolloton/git/INPT/sample_files/dir1'

#check_var

Volume='/Users/eddycolloton/git/INPT/sample_files'
SDir='/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA'
sidecardir='/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/AAA, Faker/time-based media/01.01_Something/Technical Info_Specs/Sidecars'
techdir='/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/AAA, Faker/time-based media/01.01_Something/Technical Info_Specs'
reportdir='/Users/eddycolloton/Documents/hmsg_directories/artwork_folders/AAA, Faker/time-based media/01.01_Something/Conservation/Condition_Tmt Reports'
accession='01.01'
input_test="/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA/smpte_bars_prores.mov"

#RunToolOnFile $input_test "MediaInfo" "mediainfo -f" "mediainfo" 


files=('/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA/smpte_bars_prores.mov' '/Users/eddycolloton/Documents/hmsg_directories/tbma_drobo/01-01_AAA/dir2/smpte_bars_prores_22.mov')
mi_extensions="-iname *.mov -o -iname *.mkv -o -iname *.mp4 -o -iname *.VOB -o -iname *.avi -o -iname *.mpg -o -iname *.wav -o -iname *.mp3"

# Iterate over each file in the array
for file in "${files[@]}"; do
    echo "for $file"
    # Check if the file has any of the extensions
    if find "${SDir}" -type f \( $mi_extensions \) -print0 | grep -q "$(basename "$file")"; then
        echo "$file has extentions"
        # Run mediainfo on the file
        mediainfo "$file" > "${file%.*}_test_mi.txt" 
    fi
done