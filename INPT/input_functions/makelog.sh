#!/bin/bash

set -a

## Much of this script is taken from the AMIA open source project loglog, more information here: https://github.com/amiaopensource/loglog

## Define color codes
# Foreground (text) colors:
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'

## Define color codes
# Bright (bold) versions of the above colors:
Bright_Black='\033[1;30m'
Bright_Red='\033[1;31m'
Bright_Green='\033[1;32m'
Bright_Yellow='\033[1;33m'
Bright_Blue='\033[1;34m'
Bright_Magenta='\033[1;35m'
Bright_Cyan='\033[1;36m'
Bright_White='\033[1;37m'

## Define color codes
# Background colors (replace 0 with 4):
Black_bg='\033[40m'
Red_bg='\033[41m'
Green_bg='\033[42m'
Yellow_bg='\033[43m'
Blue_bg='\033[44m'
magenta_bg='\033[45m'
Cyan_bg='\033[46m'
White_bg='\033[47m'

## Color code:
# white - data found in csv
# cyan - manual input
# magenta - data found through context
# yellow - directories and files created
# bright_red - error

#This function creates a log at a specific directory
function logCreate {
   configLogPath="${1}"
   timestamp=$(date "+%Y-%m-%d - %H.%M.%S")
   touch "${configLogPath}"
   echo "====== Script started at $timestamp ======" >> "${configLogPath}"
}

#This function adds a new line to the log
function logNewLine {
   local message="$1"
   local color="$2"
   timestamp=$(date "+%Y-%m-%d - %H.%M.%S")
   echo -e "$timestamp - ${message}" >> "${configLogPath}"
   echo -e "${color}${timestamp} - ${message}${RESET}" 
}

#This function adds a new line to the log
function logNewLineQuiet {
   timestamp=$(date "+%Y-%m-%d - %H.%M.%S")
   echo -e "$timestamp - ${1}" >> "${configLogPath}"
}

#This function adds contents to the current line fo the log
function logCurrentLine {
   sed -i '' -e '$s/$/'"$1"'/' "${configLogPath}"     #this was a doozy to write. the -i '' -e is required for MacOS for some reason
}

function MakeLog {
   logName=`date '+%Y-%m-%d-%H.%M.%S'`_INPT  #the log will be named after the Date (YYYY-MM-DD)
   logName+='.log'
   logPath="${parent_dir}"/logs/"${logName}"
   logCreate "${logPath}"
   echo -e "\nThe log has been created using the file name $logPath\n"
   export logPath="${logPath}"
   sleep 1
}

function CleanupLogDir {
  local log_dir=$(dirname "${logPath}")
  
  # Check if the directory exists
  if [ ! -d "$log_dir" ]; then
    echo "Error: Directory not found - $log_dir"
    return 1
  fi

  # Count the number of log files
  local num_logs=$(ls -1 "$log_dir" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}\.[0-9]{2}\.[0-9]{2}_INPT\.log$' | wc -l)

  # Check if cleanup is needed
  if [ "$num_logs" -gt 20 ]; then
    # Delete excess log files, keeping the newest 5
    ls -1t "$log_dir" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}\.[0-9]{2}\.[0-9]{2}_INPT\.log$' | tail -n +"$((5+1))" | xargs -I {} rm "$log_dir/{}"
    echo "Log directory cleanup complete: Deleted $((num_logs - 5)) old log files."
  fi
}

function LogVars {
logNewLineQuiet "start_input.sh complete:
----------------------->The artist name is $ArtistFirstName $ArtistLastName
----------------------->The title of the work is $title
----------------------->The accession number is $accession
----------------------->The artwork folder is $ArtFile
----------------------->The staging directory is $SDir
----------------------->The volume path is $Volume"
}

function MoveOldLogs {
  # Check if $techdir exists
  if [ -d "$techdir" ]; then
    found_logs=()
    while IFS=  read -r -d $'\0'; do
      found_logs+=("$REPLY")
    done < <(find "${techdir}" -maxdepth 1 -name "*.log" -print0)
    # Check if there are .log files
    if [[ ${#found_logs[@]} -gt 0 ]]; then
      old_logs_dir="${techdir%/}/old_logs"
      # Check if old_logs directory exists
      if [ -d "$old_logs_dir" ]; then
        # Move .log files to old_logs
        for log in "${found_logs[@]}"; do
          mv "${log}" "$old_logs_dir"
        done
        logNewLine "Moved pre-existing log files to $(basename "${old_logs_dir%/}") directory" "$YELLOW"
      else
        # Create old_logs directory and move .log files
        mkdir "$old_logs_dir"
        for log in "${found_logs[@]}"; do
          mv "${log}" "$old_logs_dir"
        done
        logNewLine "Created $(basename "${old_logs_dir%/}") directory and moved pre-existing .log files" "$YELLOW"
      fi
    fi
  else
    logNewLine "Directory $techdir does not exist" "$RED"
  fi
}

function WriteVarsToCSV {
  fullInput_csv_name="${ArtistLastName}"_"${accession}"_`date '+%Y-%m-%d-%H.%M.%S'`
  fullInput_csv_name+='.csv'
  fullInput_csv="${techdir}/${fullInput_csv_name}"
  touch "${fullInput_csv}"

  echo "Artist's First Name,\"${ArtistFirstName}\"" > "$fullInput_csv"
  echo "Artist's Last Name,\"${ArtistLastName}\"" >> "$fullInput_csv"
  echo "Artwork Title,\"${title}\"" >> "$fullInput_csv"
  echo "Accession Number,\"${accession}\"" >> "$fullInput_csv"
  echo "Path to Artwork File on T: Drive,\"${ArtFile}\"" >> "$fullInput_csv"
  echo "Staging Directory on DroBo,\"${SDir}\"" >> "$fullInput_csv"
  echo "Path to hard drive,\"${Volume}\"" >> "$fullInput_csv"
  echo "Path to Technical Info_Specs directory,\"${techdir}\"" >> "$fullInput_csv"
  echo "Path to Technical Info_Specs/Sidecars directory,\"${sidecardir}\"" >> "$fullInput_csv"
  echo "Path to Condition_Tmt Reports directory,\"${reportdir}\"" >> "$fullInput_csv"
  echo "Path Artwork Files parent directory,\"${ArtFilePath}\"" >> "$fullInput_csv"
  echo "Path to the Time-based Media Artworks directory on the TBMA DroBo,\"${TBMADroBoPath}\"" >> "$fullInput_csv"

  logNewLine "Declared variables have been written to $fullInput_csv" "$YELLOW"
  export fullInput_csv="${fullInput_csv}"
}

CompareCSV () {
  existing_csv_files=()
  while IFS=  read -r -d $'\0'; do
    existing_csv_files+=("$REPLY")
  done < <(find "${techdir}" -maxdepth 1 -name "*.csv" -print0)

  if [ ${#existing_csv_files[@]} -eq 0 ]; then
      logNewLine "No existing CSV files found in ${techdir}" "$WHITE"
  else
      old_CSVs_dir="${techdir%/}/old_CSVs"
  fi
  # Loop through existing CSV files and compare with the new CSV
  for existing_csv in "${existing_csv_files[@]}"; do
    if [ "$existing_csv" != "$1" ]; then 
      logNewLine "Comparing "$(basename "$1")" with "$(basename "$existing_csv")"" "$WHITE"
      # Use awk to compare the first column and print differences in the second column
      csv_diff=$(awk -F ',' 'NR==FNR{a[$1]=$2; next} $1 in a && a[$1]!=$2{print $1 "," $2 "," a[$1]}' "$1" "$existing_csv")
      if [ -n "$csv_diff" ]; then
        logNewLine "Differences in "$(basename "$existing_csv")" CSV found" "$Bright_Red"
        echo "$csv_diff" | while IFS=, read -r col1 existing_val new_val; do
          echo "'$col1' has different values:"
          echo "- New value: $new_val"
          echo "- Existing old: $existing_val"
        done
      fi
      # Check if differences were found and print the message
      if [ -n "$csv_diff" ]; then
        echo -e "\nWhat would you like to do with pre-existing CSV files in the Artwork File?"
        select old_csv_option in "Replace pre-existing CSV" "Archive old CSV" ; do
          case $old_csv_option in
            "Replace pre-existing CSV")
              logNewLine "Deleting old CSV file: ${existing_csv}" "$YELLOW"
              rm "${existing_csv}"
              break;;
            "Archive old CSV")
              logNewLine "Moving old CSV file: ${existing_csv}" "$YELLOW"
              if [[ -d "$old_CSVs_dir" ]] ; then
                # Move .log file to old_logs
                mv "${existing_csv}" "$old_CSVs_dir"
                logNewLine "Moved pre-existing CSV files to $(basename "${old_CSVs_dir%/}")" "$YELLOW"
              else
                # Create old_logs directory and move .log files
                mkdir "$old_CSVs_dir"
                mv "${existing_csv}" "$old_CSVs_dir"
                logNewLine "Created $(basename "${old_CSVs_dir%/}") and moved pre-existing CSV file" "$YELLOW"
              fi
              break;;
          esac
        done
      else
        logNewLine "No differences between new CSV: "$(basename "$1")" and old CSV: "$(basename "$existing_csv")". \nOld CSV removed" "$YELLOW"
        rm "${existing_csv}"
      fi
    fi
  done
}

# Function to find the most recent CSV file
find_most_recent_csv() {
    # Initialize variables
    most_recent_timestamp=0
    most_recent_csv=""
    # Iterate over each CSV filename in the array
    for csv_file in "${foundCSV[@]}"; do
        # Extract date and time from the filename
        datetime="${csv_file##*_}"
        datetime="${datetime%.csv}"
        # Convert date and time to Unix timestamp
        timestamp=$(date -d "$datetime" +"%s")
        # Check if the current timestamp is greater than the most recent one found
        if [ $timestamp -gt $most_recent_timestamp ]; then
            most_recent_timestamp=$timestamp
            most_recent_csv=$csv_file
        fi
    done
    # Print the most recent CSV filename
    logNewLine "Most recent CSV found in Artwork File: $most_recent_csv" "$CYAN"
}

function findCSV {
	set -a

	echo -e "type or drag and drop the path of the artwork file\n"
	read -e ArtFileInput
	ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
	#Strips a trailing space from the input. 
	#If the user drags and drops the directory into terminal, it adds a trailling space, which, if passed to other commands, can result in errors. the sed command above prevents this.
	#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
	export ArtFile="${ArtFile}"

	allFoundCSVs=$(find "${ArtFile%/}" -type f \( -iname "*.csv" \) | wc -l)
  if [[ ${allFoundCSVs} -lt 1 ]] ; then 
    logNewLine "No input csv found in Artwork File. Either run start_input to create necessary inputs or re-run start_output with input csv.\nUsage: ./start_output.sh <input.csv> <optional_output.csv>" "$RED"
    exit 1
  elif [[ ${allFoundCSVs} -eq 1 ]] ; then
    foundCSV=$(find "${ArtFile%/}" -type f \( -iname "*.csv" \))
    logNewLine "Found ${foundCSV} in ${ArtFile}"
	elif [[ $(echo ${foundCSV} | wc -l) -gt 1 ]]; then
		foundCSV=(${foundCSV[@]})
		most_recent_foundCSV=$(find_most_recent_csv "${foundCSV[@]}")
		echo "\nMore than one CSV found in Art File. Use most recent?"
		IFS=$'\n'; select recentCSV_option in "Yes" "No, show all CSVs" ; do
			if [[ $recentCSV_option = "Yes" ]] ; then
				foundCSV="${most_recent_foundCSV}"
        logNewLine "Found "${foundCSV}" in "${ArtFile}"" 
			elif [[ $recentCSV_option = "No, show all CSVs" ]] ; then 
				IFS=$'\n'; select selectedCSV in $(find "${ArtFile%/}" -type f \( -iname "*.csv" \)) "None of these" ; do
          if [[ $selectedCSV = "None of these" ]] ; then
            logNewLine "No operable input csv found. Either run start_input to create necessary inputs or re-run start_output with desired input csv.\nUsage: ./start_output.sh <input.csv> <optional_output.csv>" "$RED"
            exit 1
          else
            foundCSV=$recentCSV_option
            logNewLine "\nFound ${foundCSV} in ${ArtFile}" 
          fi
        break
        done;
			fi
		break           
		done
	fi

	set +a
} 

ReadCSV () {
  if [[ -n ${1} ]] ; then
    logNewLine "Reading CSV file: $(basename "${1}")" "$MAGENTA"
    # Check the content of the file to determine it matches expected first line of input.csv or output.csv
    first_line=$(head -n 1 "$1")
    # Check if it's an input CSV file
    if [[ "$first_line" == "Artist's First Name,"* ]]; then
      input_csv=$1
      logNewLine "Input CSV file detected: $input_csv" "$WHITE"
    # Check if it's an output CSV file
    elif [[ "$first_line" == "Move all files to staging directory,"* ]]; then
      output_csv=$1
      logNewLine "Output CSV file detected: $output_csv" "$WHITE"
    else
      logNewLine "Error: Unsupported CSV file format." "$RED"
    fi
  fi
}

function searchArtFile {
#This function searches the artwork file for sidecars created by the make_meta.sh script. 
	set -a
	if [[ -z $(find "${techdir}" -iname "*_manifest.md5") ]]; then 
	#if no file with "mainfest.md5" is in the technical info and specs directory, then
		echo -e "No md5 manifest found"
		md5_report=0
	else
		echo -e "md5 manifest found"
		md5_report=1
    	#assigns a value to the $md5_report variable depending ont he results of the find command in the if statement above
	fi
	if [[ -f "${techdir}/${accession}_tree_output.txt" ]]; then
		echo -e "No tree text file found"
		tree_report=0
	else
		echo -e "tree text file found"
		tree_report=1
	fi	
	if [[ -f "${techdir}/${accession}_disktype_output.txt" ]]; then
		echo -e "No disktype report found"
		dt_report=0
	else
		echo -e "disktype report found"
		dt_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*_sf.txt") ]] ; then 
		echo -e "No siegfried report found"
		sf_report=0
	else
		echo -e "siegfried report found"
		sf_report=1
	fi	
	if [[ -z $(find "${techdir}" -iname "*_mediainfo.txt") ]]; then 
		echo -e "No MediaInfo report found"
		mi_report=0
	else
		echo -e "MediaInfo report found"
		mi_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*_exif.txt") ]]; then
		echo -e "No exiftool report found"
		exif_report=0
	else
		echo -e "exiftool report found"
		exif_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*_framemd5.txt") ]]; then
		echo -e "No framemd5 text file found"
		fmd5_report=0
	else
		echo -e "framemd5 text file found"
		fmd5_report=1
	fi
	if [[ -z $(find "${techdir}" -iname "*.qctools*") ]]; then
		echo -e "No qctools report found"
		qct_report=0
	else
		echo -e "qctools report found"
		qct_report=1
	fi
	sleep 1
	set +a
}

# Check if a file path has escaped characters
FindEscapedCharacters() {
    local path="$1"
    local escaped_pattern="\\"

    if [[ "$path" == *"$escaped_pattern"* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

ParseArgs() {
    if [[ "$#" -lt 1 ]]; then
    # If command line arguments are less than 1, then:
        logNewLine "No input CSV files provided!" "$RED"
    else
        for arg in "$@"; do
            if [[ $arg == -* ]]; then
                # Can add more if statements here for other flags
                if [[ "$arg" == "-t" ]] || [[ "$arg" == "--typos" ]]; then
                    typo_check=true
                    export typo_check="${typo_check}"
                fi
                if [[ "$arg" == "-s" ]] || [[ "$arg" == "--stop" ]]; then
                    stop_input=true
                    export stop_input="{$stop_input}"
                fi
                if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
                    echo -e "INPT is a bash scripting project created for TBMA processing at HMSG.\n\n./start_input [options] [optional input.csv] [optional output.csv]\n\nOptions:\n--help, -h\n\tDisplay this text.\n--stop, -s\n\tStop process after start_input.sh, do not proceed to start_output.sh\n--typos, -t\n\tConfirm manually input text\n"
                    exit 1
                fi
            else
                input_file_path=$arg
                # Assign the first argument to a variable
                ReadCSV "${input_file_path}"
            fi
        done
    fi
}

# Function to remove BOM and non-printable characters
function RemoveSpecialChars {
    local str=$1
    local accented_chars='éèêëàáâäãåæçèéêëìíîïðñòóôõöùúûüýÿ'
    str=$(printf '%s' "$str" | LC_ALL=C sed -E "s/[^[:print:]\n\r\t$accented_chars]//g")
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    str="${str//[\"]}"
    echo "${str//[\']}"
}

set +a