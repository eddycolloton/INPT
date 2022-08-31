#!/bin/bash

source `dirname "$0"`/HMSG_auto.config    #this sets the path for the config file, which should be nested next to the script 

function DeleteMetaList {
test -f $(find "$techdir" -type f \( -iname "*_makeupmeta_selects.txt" \)) && 
find "$techdir" -type f \( -iname "*_makeupmeta_selects.txt" \) -print0 |
    while IFS= read -r -d '' l;
        do rm "$l"
    done
}

DeleteMetaList

cowsay -s "Select tools from the list below, one at a time. Type the corresponding number and press enter to select one. Repeat as necessary. Once all the directories have been selected, press enter again."
#The majority of this function comes from here: http://serverfault.com/a/298312
options=("disktype" "tree" "Siegfried" "MediaInfo" "Exiftool" "Framemd5" "QCTools")

menu() {
    echo "Avaliable options:"
    for i in ${!options[@]}; do 
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    if [[ "$msg" ]]; then echo "$msg"; fi
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
    [[ "${choices[i]}" ]] && { printf "${options[i]}"; msg=""; printf "\n"; } >> "${techdir}/${accession}_makeupmeta_selects.txt"
    #This "for" loop used to printf a message with the selected options (from http://serverfault.com/a/298312), but I've changed it to print the output of the chioces to a text file. 
done


declare -a MetaSelected
#creates an empty array
let i=0
while IFS=$'\n' read -r line_data; do
    #stipulates a line break as a field seperator, then assigns the variable "line_data" to each field read
    MetaSelected[i]="${line_data}"
    #states that each line will be an element in the arary
    ((++i))
    #adds each new line to the array
done < "${techdir}/${accession}_makeupmeta_selects.txt"
#populates the array with contents of the text file, with each new line assigned as its own element 
#got this from https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
echo -e "\nThe selected metadata tools are: ${MetaSelected[@]}"
MetaList=${MetaSelected[@]}
#lists the contents of the array, populated by the text file, into a variable $MetaList
if [[ "${MetaList}" == *"disktype"* ]]; 
then
	Run_disktype=1
fi
if [[ "${MetaList}" == *"tree"* ]]; 
then
	Run_tree=1
fi
if [[ "${MetaList}" == *"Siegfried"* ]]; 
then
	Run_sf=1
fi
if [[ "${MetaList}" == *"MediaInfo"* ]]; 
then
	Run_MI=1
fi
if [[ "${MetaList}" == *"Exiftool"* ]]; 
then
	Run_exif=1
fi
if [[ "${MetaList}" == *"Framemd5"* ]]; 
then
	Run_framemd5=1
fi
if [[ "${MetaList}" == *"QCTools"* ]]; 
then
	Run_QCT=1
fi
#Series of "if" statements test to see if the variable MetaList contains these specific strings 

if [[ "$Run_disktype" = "1" ]] 
then disktype
fi

if [[ "$Run_tree" = "1" ]]
then RunTree
fi

if [[ "$Run_sf" = "1" ]]
	then RunSF
fi

if [[ "$Run_mediainfo" = "1" ]]
then RunMI
fi

if [[ "$Run_exif" = "1" ]]
then RunExif
fi

if [[ "$Run_framemd5" = "1" ]]
	then Make_Framemd5
fi

if [[ "$Run_QCTools" = "1" ]]
	then Make_QCT
fi

DeleteMetaList

figlet Fin. 

#Prompt is a placeholder. Need to prompt for what tasks are available/What user wants to do...
#IFS=$'\n'; select makeUp_option in "Make framemd5" "Make MediaInfo" "Make QCTools reports" ; do
#	if [[ $makeUp_option = "Make framemd5" ]] 
#	then 
#		Make_Framemd5
#	elif [[ $makeUp_option =  "Make MediaInfo" ]]
#  	then 
#  		RunMI
#	elif [[ $makeUp_option =  "Make QCTools reports" ]] 
#	then
#		Make_QCT
#	fi
#break			
#done;
