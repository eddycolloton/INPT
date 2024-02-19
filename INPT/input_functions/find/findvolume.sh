#!/bin/bash

function FindVolume {
	if [[ -z "${title}" ]] ; then
	# fi the variable $title has not been assigned then:
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
				ConfirmInput Volume "Path to the volume should begin with '/Volumes/' (use tab complete to help)"
        	elif [[ -n $findvolume_option ]] ; then
				Volume=$findvolume_option
			fi
		break           
		done;
	elif [[ -z "${FindVolumes}" ]]; then
		ConfirmInput Volume "Path to the volume should begin with '/Volumes/' (use tab complete to help)"
	else
		echo -e "Is this the volume? \n${FindVolumes}"
		IFS=$'\n'; select found_volume_option in "yes" "no" ; do
			if [[ $found_volume_option = "yes" ]] ; then 
				Volume="${FindVolumes}"
        	elif [[ $found_volume_option = "no" ]] ; then
				ConfirmInput Volume "Path to the volume should begin with '/Volumes/' (use tab complete to help)"
			fi
		break           
		done;
	fi

	export Volume="${Volume}"
}
