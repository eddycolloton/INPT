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

function MakeVarfile {
varfileName=`date '+%Y-%m-%d-%H.%M.%S'`_"$ArtistLastName"_"$accession"  #the file that stores the variables will be named after the the date, artists last name, and the accession number
varfileName+='.varfile'
varfilePath="${techdir}/${varfileName}"
touch "${varfilePath}"
echo 'ArtistFirstName="'"$ArtistFirstName"'"' >> "${varfilePath}"
echo 'ArtistLastName="'"$ArtistLastName"'"' >> "${varfilePath}"
echo 'title="'"$title"'"' >> "${varfilePath}"
echo 'accession="'"$accession"'"' >> "${varfilePath}"
echo 'ArtFile="'"$ArtFile"'"' >> "${varfilePath}"
echo 'SDir="'"$SDir"'"' >> "${varfilePath}"
echo 'Device="'"$Device"'"' >> "${varfilePath}"
echo 'Volume="'"$Volume"'"' >> "${varfilePath}"
echo 'techdir="'"$techdir"'"' >> "${varfilePath}"
echo 'sidecardir="'"$sidecardir"'"' >> "${varfilePath}"
echo 'reportdir="'"$reportdir"'"' >> "${varfilePath}"

export varfilePath="${varfilePath}"
}

function MoveOldLogs {
  # Check if $techdir exists
  if [ -d "$techdir" ]; then
    log_files=("$techdir"/*.log)
    
    # Check if there are .log files
    if [ ${#log_files[@]} -gt 0 ]; then
      old_logs_dir="$techdir/old_logs"
      
      # Check if old_logs directory exists
      if [ -d "$old_logs_dir" ]; then
        # Move .log files to old_logs
        mv "$techdir"/*.log "$old_logs_dir/"
        logNewLine "Moved .log files to $old_logs_dir" "$YELLOW"
      else
        # Create old_logs directory and move .log files
        mkdir "$old_logs_dir"
        mv "$techdir"/*.log "$old_logs_dir/"
        logNewLine "Created $old_logs_dir and moved pre-existing .log files" "$YELLOW"
      fi
    fi
  else
    logNewLine "Directory $techdir does not exist" "$RED"
  fi
}

write_to_csv() {
  local csv_file="$1"
    
  # Check if the CSV file already exists, if not, create it with header
  if [ ! -e "$csv_file" ]; then
      echo "ArtistFirstName,First" > "$csv_file"
      echo "ArtistLastName,Last" >> "$csv_file"
      echo "title,title" >> "$csv_file"
      echo "accession," >> "$csv_file"
      echo "ArtFile," >> "$csv_file"
      echo "SDir," >> "$csv_file"
      echo "Volume," >> "$csv_file"
      echo "techdir," >> "$csv_file"
      echo "sidecardir," >> "$csv_file"
      echo "reportdir," >> "$csv_file"
      echo "ArtFilePath," >> "$csv_file"
      echo "TBMADroBoPath," >> "$csv_file"
  fi

  # Get the variable names dynamically
  local variable_names=($(declare -p | grep -Eo ' [^=]+=' | sed 's/ $//'))

  # Append values to the CSV file
  for variable in "${variable_names[@]}"; do
      # Remove leading space from variable name
      variable="${variable:1}"
      # Get the value of the variable
      value="${!variable}"
      echo "$variable,$value" >> "$csv_file"
  done

  echo "Data has been written to $csv_file"
}

# Call the function to write to the CSV file
#write_to_csv "output.csv"

set +a