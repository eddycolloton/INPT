#!/bin/bash

source `dirname "$0"`/HMSG_auto.config    #this sets the path for the config file, which should be nested next to the script 

echo -e "\n********move files from the source location: "${Volume}" \nto the destination \n"${SDir}"?"
IFS=$'\n'; select move_confirm in "yes" "no" ; do
	if [[ $move_confirm = no ]]
	then
		quit
	fi
break
done ;

#Prompts user to tranfer files to Staging Driectory
#The following select loops set vairable to either "1" or "0". This allows the script to store the user's selection without running the function till the end. 
#At the end fo the script there are if statements that will run the different functions based on the stored answers from the user  
cowsay -s "Copy all files from the volume to the staging directory?"
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

if [[ "$MultiSelect" -eq "1" ]];
	#this worked
	then 
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

if [[ "$IndvFiles" -eq "1" ]];
	then 
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


if [[ "$Run_Copyit" = "1" ]] 
then CopyitVolumeStaging
fi

if [[ "$Run_FileCopy" = "1" ]]
then RunIndvMD5 && CopyFiles && DeleteList
fi

if [[ "$Run_MultiCopy" = "1" ]] 
then CopyitSelected && DeleteList
fi
