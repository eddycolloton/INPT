#!/bin/bash

#This is a list of functions called throughout the script. The functions are "called" later on in the script.

#This function makes the nested directores of a Time-based Media Artwork File
function MakeArtworkFile {
	echo "Create the Artwork File?"
	select Make_ArtFile_option in "Yes, create the Artwork File" "No, quit"
	do
		case $Make_ArtFile_option in
			"Yes, create the Artwork File") echo "Enter Artist Name in 'Last Name, First Name' format"
				read ArtFile_ArtistName
				while [[ -z "$ArtFile_ArtistName" ]] ; do 
					echo "Enter Artist Name in 'Last Name, First Name' format" && read ArtFile_ArtistName
				done
				echo "Enter Accession Number in '##.##' format"
				read ArtFile_Accession
				while [[ -z "$ArtFile_Accession" ]] ; do
					echo "Enter Accession Number in '##.##' format" && read ArtFile_Accession
				done
				echo "Enter Artwork Title"
				read ArtFile_Title
				while [[ -z "$ArtFile_Title" ]] ; do
					echo "Enter Artwork Title" && read ArtFile_Title
				done
        #I've removed the path to the HMSG shared drive below for security reasons, hopefully we'll be able to have it back in? I have to get that cleared...
				mkdir -pv /path/to/artwork_files/"$ArtFile_ArtistName"/"time-based media"/"$ArtFile_Accession"_"$ArtFile_Title"/{"Acquisition and Registration","Artist Interaction","Cataloging","Conservation"/{"Condition_Tmt Reports","DAMS","Equipment Reports"},"Iteration Reports_Exhibition Info"/"Equipment Reports","Photo-Video Documentation","Research"/"Correspondence","Technical Info_Specs"/"Past installations_Pics","Trash"}
				ArtFile=/path/to/artwork_files/"$ArtFile_ArtistName"/"time-based media"/"$ArtFile_Accession"_"$ArtFile_Title"
				echo "The Artwork file is $ArtFile"
			break;;
			"No, quit") echo "Quitting now..." && exit 1
			break;;
		esac
	done
} 

#This function makes the staging directory if one does not exist
function MakeStagingDirectory {
	echo "Create the Staging Directory?"
	select Make_Sdir_option in "Yes, create the staging directory" "No, quit"
	do
		case $Make_Sdir_option in
			"Yes, create the staging directory") echo "Enter Accession Number in '##-##' format"
				read SDir_Accession
				while [[ -z "$SDir_Accession" ]] ; do 
					echo "Enter Accession Number in '##-##' format" && read SDir_Accession
				done
				echo "Enter Artist Last name"
				read SDir_ArtistName
				while [[ -z "$SDir_ArtistName" ]] ; do 
					echo "Enter Artist Last name" && read SDir_ArtistName
				done
				mkdir /Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork/"$SDir_Accession"_"$SDir_ArtistName"
				SDir=/Volumes/TBMA\ Drobo/Time\ Based\ Media\ Artwork/"$SDir_Accession"_"$SDir_ArtistName"
				echo "The Staging Directory is $SDir"
			break;;
			"No, quit") echo "Quitting now..." && exit 1
			break;;
		esac
	done
	
}

#This function runs the python script copyit.py from the IFIscripts directory
function CopyitVolumeStaging {
	python3 /Users/eddycolloton/IFIscripts-master/copyit.py "$Volume" "$SDir" &&
	for t in "`find "$SDir" -name "*_manifest.md5"`" ; do cp "$t" "$ArtFile"/Technical\ Info_Specs/ && echo -e "\n***** md5 checksum manifest ***** \n" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt && cat "$t" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt
	done
}

#This function will create a disktype output and copy the output to Staging Directory, Tech Specs dir in ArtFile and appendix in ArtFile
function disktype {
	sudo disktype $Device > "$SDir"/disktype_output.txt &&
	echo -e "\n***** disktype output ***** \n" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt &&
	cat "$SDir"/disktype_output.txt >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt &&
	cp "$SDir"/disktype_output.txt "$ArtFile"/Technical\ Info_Specs/
}

#This function runs tree on the Volume sends the output to three text files 
function RunTree {
	tree "$Volume" > "$SDir"/tree_output.txt &&
	echo -e "\n***** tree output ***** \n" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt &&
	cat "$SDir"/tree_output.txt >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt &&
	cp "$SDir"/tree_output.txt "$ArtFile"/Technical\ Info_Specs/
}
 
#This function will create siegfried sidecar files for all files in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunSF {
	find "$SDir" -type f \( -iname "*.*" ! -iname "*.md5" ! -iname "*_output.txt" ! -iname "*.DS_Store" \) -print0 | 
	while IFS= read -r -d '' i; do
		sf "$i" > "${i%.*}_sf."txt ; 
	#runs sf on all files in the staging directory except files that were made earlier in this workflow (md5 manifest, disktype, tree, and DS_Stores) 
	#The "for" loop was not working with this command. I found the IFS solution online, but honestly don't totally understand how it works.
	done && 
	echo -e "\n***** siegfried output ***** \n" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt &&
	find "$SDir" -type f \( -iname "*.*" ! -iname "*.md5" ! -iname "*_output.txt" ! -iname "*.DS_Store" ! -iname "*_sf.txt" \) -print0 | 
	while IFS= read -r -d '' v; 
		do sf "$v" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt ; 
	done && 
	find "$SDir" -type f \( -iname "*_sf.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$ArtFile"/Technical\ Info_Specs/
	done 
}

#This function will create MediaInfo sidecar files for all files with .mp4, .mov and .mkv file extensions in the Staging Directory, the copy output to Tech Specs dir in ArtFile and appendix in ArtFile
function RunMI {
	for i in  "`find "$SDir" -name "*.mp4" -o -name "*.mov" -o -name "*.mkv"`"; 
		do 
			mediainfo -f "$i" > "${i%.*}_mediainfo".txt
			echo -e "\n***** mediainfo -f output ***** \n" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt
			mediainfo -f "$i" >> "$ArtFile"/Conservation/Condition_Tmt\ Reports/appendix.txt  
	done &&
	for t in "`find "$SDir" -name "*_mediainfo.txt"`" ; 
		do cp "$t" "$ArtFile"/Technical\ Info_Specs/ ; 
	done 
}

#This function will make a text file containing md5 checksums of each frame of any video files in the Staging Directory. The output will be saved as a side car file in the Staging Directory and the Tech Specs dir in the ArtFile
function Make_Framemd5 {
	for i in  "`find "$SDir" -name "*.mp4" -o -name "*.mov" -o -name "*.mkv"`" ; 
	do ffmpeg -i "$i" -f framemd5 -an  "${i%.*}_framemd5".txt ; 
	done && 
	find "$SDir" -type f \( -iname "*_framemd5.txt" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$ArtFile"/Technical\ Info_Specs/
	done 
}

#This function will make a QCTools report for video files with the .mp4, .mov and .mkv extensions and save the reports as sidecar files int he Staging Directory and the Tech Specs dir in the ArtFile
function Make_QCT {
	for i in  "`find "$SDir" -name "*.mp4" -o -name "*.mov" -o -name "*.mkv"`" ; 
	do qcli -i "$i" ; done && 
	find "$SDir" -type f \( -iname "*.qctools.xml.gz" \) -print0 |
	while IFS= read -r -d '' t; 
		do cp "$t" "$ArtFile"/Technical\ Info_Specs/
	done 
}


#*****************************************************************************************************
#*****************************************************************************************************
#The "Workflow" really starts here...
#User prompts will call the functions listed above ^

figlet Automation!

#Prompts for either identifying the Artwork File or creating one using the function defined earlier. Defines that path as "$ArtFile"
cowsay -W 30 "Does the Artwork File exist? (Choose a number 1-3)"
select ArtFile_option in "yes" "no" "quit"
do
	case $ArtFile_option in
		yes) echo -e "\n*************************************************\n
Input path to Artwork File. \nThe directory name should be: \n'Accession Number_Artwork Title' "
		#Asks for user input, allows for tab completion of path
			read -e ArtFile 
			##Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
			#Assigns user input to the ArtFile variable
			while [[ -z "$ArtFile" ]] ; do 
					echo -e "\n*************************************************\n
Input path to Artwork File. \nThe directory name should be: \n'Accession Number_Artwork Title' " &&
read -e ArtFile
				done
			echo -e "\n*************************************************\n
The Artwork File is $ArtFile"
			break;;
		no) MakeArtworkFile 
			break;;
		quit) exit 1 ;;
	esac
done

#Prompts for either identifying the staging directory or creating one using the function defined earlier. Defines that path as "$SDir"
cowsay "Does the Staging Directory exist? (Choose a number 1-3)"
select SDir_option in "yes" "no" "quit"
do
	case $SDir_option in
		yes) echo -e "\n*************************************************\n
Input path to Staging Directory"
		#Asks for user input, allows for tab completion of path
			read -e SDir 
			#Takes user input. might be ok with either a "/" or no "/"?? Is that possible?
			#Confirms that the SDir variable is defined 
			echo -e "\n*************************************************\n
Staging Driectory is $SDir"
			break;;
		no) MakeStagingDirectory
			break;;
		quit) exit 1 ;;
	esac
done

#Prompts user input for path to hard drive (or other carrier), defines that path as "$Volume"
cowsay -p -W 31 "Input the path to the volume - Should begin with '/Volume/' (use tab complete to help)"
read -e Volume
while [[ -z "$Volume" ]] ; do 
	echo -e "Input the path to the volume - Should begin with '/Volume/' (use tab complete to help)" && read -e Volume 
done
echo "The volume path is $Volume"

#Uses the function defined at the top to copy media from the (now defined) variable Volume to the (now defined) variable Staging Directory
cowsay -s "Copy all files from the volume to the staging directory?"
select Copy_option in "yes" "no" "quit"
do
	case $Copy_option in
		yes) CopyitVolumeStaging
			break;;
		no) break;;
		quit) exit 1 ;;
		esac
	done

#Going straight into disktype seemed weird, decided to add a prompt here...
cowsay -b "Move on to metadata creation? Next step is to identify the device path to run disktype"
select MoveOn_option in "yes" "quit"
do
	case $MoveOn_option in
		yes) echo "Generating diskutil list..."
			break;;
		quit) exit 1 ;;
	esac
done

#Prompts user input for path to hard drive (or other carrier), defines that path as "$Device"
diskutil list
echo -e "\n*************************************************\n
Input the path to the device - Should be '/dev/disk#' "
read -e Device
while [[ -z "$Device" ]] ; do
	echo -e "\n*************************************************\n
Input the path to the device - Should be '/dev/disk#' " && read -e Device
done
echo "The device path is $Device"

#Prompts user that disktype is being run? Not sure about this...
echo -e "\n*************************************************\n
Run disktype on $Device (Choose a number 1-2)"
select Disktype_option in "yes" "no"
do
	case $Disktype_option in
		yes) disktype
			#Should run disktype on device path and then pipe output to tee, copy output to Staging Directory, Tech Specs dir in ArtFile and appendix in ArtFile
			break;;
		no) break;;
	esac
done  

#Prompts user to run tree
echo -e "\n*************************************************\n
Run tree on $Volume (Choose a number 1-2)"
select Tree_option in "yes" "no"
do
	case $Tree_option in
		yes) RunTree
			#Runs tree function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done  

#Prompts user to run siegfried file format id
echo -e "\n*************************************************\n
Run siegfried on $SDir (Choose a number 1-2)"
select SF_option in "yes" "no"
do
	case $SF_option in
		yes) RunSF
			#Runs siegfried function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done  

#Prompts user to run mediainfo 
echo -e "\n*************************************************\n
Run MediaInfo on video files in $SDir (Choose a number 1-2)"
select MI_option in "yes" "no"
do
	case $MI_option in
		yes) RunMI
			#Runs mediainfo function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done  

#Prompts user to make framemd5 text files for videos
echo -e "\n*************************************************\n
Create framemd5 text files for each of the video files in $SDir (Choose a number 1-2)"
select Fmd5_option in "yes" "no"
do
	case $Fmd5_option in
		yes) Make_Framemd5
			#Runs ffmpeg to create 
			break;;
		no) break;;
	esac
done  

#Prompts user to make QCTools reports for ech video file in the staging directory
echo -e "\n*************************************************\n
Create QCTools reports for each of the video files in $SDir (Choose a number 1-2)"
select QCT_option in "yes" "no"
do
	case $QCT_option in
		yes) Make_QCT
			#Runs QCTools function defined at the top of the doc. 
			break;;
		no) break;;
	esac
done

figlet Fin.  
