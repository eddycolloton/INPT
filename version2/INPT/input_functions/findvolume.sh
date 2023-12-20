#!/bin/bash

function InputVolumePath () {
#Prompts user input for path to hard drive (or other carrier), defines that path as "$Volume"
	cowsay -p -W 31 "Input the path to the volume - Should begin with '/Volumes/' (use tab complete to help)"
	read -e VolumeInput
	Volume="$(echo -e "${VolumeInput}" | sed -e 's/[[:space:]]*$//')"
	#If the volume name is dragged and dropped into terminal, the trail whitespace can eventually be interpreted as a "\" which breaks the CLI tools called in make_meta.sh. To prevent this, the sed command above is used.
	#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
	echo -e "Is the artist's name correct?"
    IFS=$'\n'; select volume_option in "Yes" "No, go back a step" ; do
    if [[ $volume_option = "Yes" ]] ;
        then
            echo -e "Moving on..."
   	elif [[ $volume_option = "No, go back a step" ]] ;
        then 
            echo -e "Let's try again"
            unset Volume
            return 1
   	fi
    break           
    done;
}

function FindVolume {
	#FindVolume=$(find "/Volumes/" -maxdepth 1 -type d -iname "*$ArtistLastName*") 
	# add other variables as we build v2 out. for example title. Will then need "else" statement in this conditional for multiple results
	if [[ -z "${FindVolumes}" ]]; then
		InputVolumePath
		until InputVolumePath ; do : ; done
		# Got this 'until' line from here: https://stackoverflow.com/questions/45088696/bash-scripting-can-you-make-a-function-call-itself
		export Volume="${Volume}"
	# elif wc -l > 1... 
	fi
}
