#!/bin/bash

function InputVolume {
	# Prompts user input for path to hard drive (or other carrier), defines that path as "$Volume"
	cowsay -p -W 31 "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)"
	read -e VolumeInput
	Volume="$(echo -e "${VolumeInput}" | sed -e 's/[[:space:]]*$//')"
	# If the volume name is dragged and dropped into terminal, the trail whitespace can eventually be interpreted as a "\" which breaks the CLI tools called in make_meta.sh. To prevent this, the sed command above is used.
	# I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
	logNewLine "The path to the volume manually input: ${Volume}" "$CYAN"
	volume_again=yes
    while [[ "$volume_again" = yes ]] ; do
		echo -e "\nIs the volume path correct?"
    	IFS=$'\n'; select volume_option in "Yes" "No, go back a step" ; do
    	if [[ $volume_option = "Yes" ]] ;
       		then
            	volume_again=no
   		elif [[ $volume_option = "No, go back a step" ]] ;
        	then 
            	echo -e "Let's try again"
            	unset Volume
   		fi
    	break           
    	done;

    	if [[ "$volume_again" = yes ]]
			then echo -e "Let's try again"
		fi
	done
    export Volume="${Volume}"
}

function FindVolume {
	if [[ -z "${title}" ]] ; then
		VolumesMatch=$(find "/Volumes" -maxdepth 1 -type d -iname "*$ArtistLastName*" | wc -l | xargs)
		# Gives number of results in the /Volumes/ directory that contain either the artist's last name or the title of the artwork
		FindVolumes=$(find "/Volumes" -maxdepth 1 -type d -iname "*${ArtistLastName}*")
	else
		VolumesMatch=$(find "/Volumes" -maxdepth 1 -type d -iname "*$ArtistLastName*"  -o -iname "*$title*" | wc -l | xargs)
		# Gives number of results in the /Volumes/ directory that contain either the artist's last name or the title of the artwork
		FindVolumes=$(find "/Volumes" -maxdepth 1 -type d -iname "*${ArtistLastName}*" -o -iname "*${title}*")
	fi

	if [ "${VolumesMatch}" \> 1 ]; then
	# If there is more than 1 line in the $FindVolumes variable, then
		declare -a FindVolumes_array
		IFS=$'\n'
    	for line in $(find "/Volumes" -maxdepth 1 -type d -iname "*${ArtistLastName}*" -o -iname "*${title}*"); do
			# Store each line in the array
			FindVolumes_array+=("$line")
		done
	
		IFS=$'\n'; select findvolume_option in ${FindVolumes_array[@]} "None of these" ; do
			if [[ $findvolume_option = "None of these" ]] ; then 
				InputVolume
        	elif [[ -n $findvolume_option ]] ; then
				Volume=$findvolume_option
			fi
		break           
		done;
	elif [[ -z "${FindVolumes}" ]]; then
		InputVolume
	else
		echo -e "Is this the volume? \n${FindVolumes}"
		IFS=$'\n'; select confirmvolume_option in "yes" "no" ; do
			if [[ $confirmvolume_option = "yes" ]] ; then 
				Volume="${FindVolumes}"
        	elif [[ $confirmvolume_option = "no" ]] ; then
				InputVolume
			fi
		break           
		done;
	fi
}
