#!/bin/bash

#Bash script for checking if the dependencies for HMSG_auto are correctly installed.
#The "if statement" is lifted from this stackoverflow post: https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script#:~:text=It%20was%20previously%20mentioned%20at,exists%20from%20a%20Bash%20script%3F&text=Non%2Dverbose%20way%20to%20do,part%20of%20util%2Dlinux).


if ! command -v brew &> /dev/null
	#if the command "brew" is not(!) found in /dev/null
then
	echo -e "homebrew is not installed! All dependencies of HMSG_auto are installed via homebrew.\n Go to https://brew.sh/ to install homebrew."
	exit
	#if brew is not installed the script exits, because all subsequent if statements run brew
fi

if ! command -v cowsay &> /dev/null
	#if the command "cowsay" is not(!) found in /dev/null
then
	echo "cowsay could not be found, installing cowsay with brew..."
	brew install cowsay
	#runs brew install cowsay. This will force a brew update. Consider running with 
	if ! command -v cowsay &> /dev/null
	then
		echo "cowsay did not install succesfully"
	else
		echo "cowsay installed"
	fi
fi

if ! command -v exiftool &> /dev/null
then
	echo "exiftool could not be found, installing exiftool with brew..."
	brew install exiftool
	if ! command -v exiftool &> /dev/null
	then
		echo "exiftool did not install succesfully"
	else
		echo "exiftool installed"
	fi
fi

if ! command -v ffmpeg &> /dev/null
then
	echo "ffmpeg could not be found, installing ffmpeg with brew..."
	brew install ffmpeg
	if ! command -v ffmpeg &> /dev/null
	then
		echo "ffmpeg did not install succesfully"
	else
		echo "ffmpeg installed"
	fi
fi

if ! command -v figlet &> /dev/null
then
	echo "figlet could not be found, installing figlet with brew..."
	brew install figlet
	if ! command -v figlet &> /dev/null
	then
		echo "figlet did not install succesfully"
	else
		echo "figlet installed"
	fi
fi

if ! command -v md5deep &> /dev/null
then
	echo "md5deep could not be found, installing md5deep with brew..."
	brew install md5deep
	if ! command -v md5deep &> /dev/null
	then
		echo "md5deep did not install succesfully"
	else
		echo "md5deep installed"
	fi
fi

if ! command -v mediainfo &> /dev/null
then
	echo "mediainfo could not be found, installing mediainfo with brew..."
	brew install mediainfo
	if ! command -v mediainfo &> /dev/null
	then
		echo "mediainfo did not install succesfully"
	else
		echo "mediainfo installed"
	fi
fi

if ! command -v qcli &> /dev/null
then
	echo "qcli could not be found, installing qcli with brew..."
	brew install qcli
	if ! command -v qcli &> /dev/null
	then
		echo "qcli did not install succesfully"
	else
		echo "qcli installed"
	fi
fi

if ! command -v tree &> /dev/null
then
	echo "tree could not be found, installing tree with brew..."
	brew install tree
	if ! command -v tree &> /dev/null
	then
		echo "tree did not install succesfully"
	else
		echo "tree installed"
	fi
fi

if ! command -v sf &> /dev/null
then
	echo "Siegfried could not be found, installing Siegfried with brew..."
	brew install richardlehane/digipres/siegfried
	if ! command -v sf &> /dev/null
	then
		echo "Siegfried did not install succesfully"
	else
		echo "Siegfried installed"
	fi
fi