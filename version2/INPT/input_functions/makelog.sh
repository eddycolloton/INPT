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
        logNewLine "Moved pre-existing log files to $(basename "${old_logs_dir%/}")" "$YELLOW"
      else
        # Create old_logs directory and move .log files
        mkdir "$old_logs_dir"
        for log in "${found_logs[@]}"; do
          mv "${log}" "$old_logs_dir"
        done
        logNewLine "Created $(basename "${old_logs_dir%/}") and moved pre-existing .log files" "$YELLOW"
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

  echo "Artist's First Name,"${ArtistFirstName}"" > "$fullInput_csv"
  echo "Artist's Last Name,"${ArtistLastName}"" >> "$fullInput_csv"
  echo "Artwork Title,"${title}"" >> "$fullInput_csv"
  echo "Accession Number,"${accession}"" >> "$fullInput_csv"
  echo "Path to Artwork File on T: Drive,"${ArtFile}"" >> "$fullInput_csv"
  echo "Staging Directory on DroBo,"${SDir}"" >> "$fullInput_csv"
  echo "Path to hard drive,"${Volume}"" >> "$fullInput_csv"
  echo "Path to Technical Info_Specs directory,"${techdir}"" >> "$fullInput_csv"
  echo "Path to Technical Info_Specs/Sidecars directory,"${sidecardir}"" >> "$fullInput_csv"
  echo "Path to Condition_Tmt Reports directory,"${reportdir}"" >> "$fullInput_csv"
  echo "Path Artwork Files parent directory,"${ArtFilePath}"" >> "$fullInput_csv"
  echo "Path to the Time-based Media Artworks directory on the TBMA DroBo,"${TBMADroBoPath}"" >> "$fullInput_csv"

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

set +a