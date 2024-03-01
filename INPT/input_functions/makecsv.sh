#!/bin/bash

set -a

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
      
      unset csv_diff
      # Reset csv_diff per CSV file
      while IFS= read -r line1 && IFS= read -r line2 <&3; do
        key1=$(echo "$line1" | cut -d ',' -f 1)
        key2=$(echo "$line2" | cut -d ',' -f 1)

        # Check if keys are the same
        if [ "$key1" != "$key2" ]; then
            echo "Keys do not match: $key1 in CSV1, $key2 in CSV2"
            continue
        fi

        # Extract values
        value1=$(echo "$line1" | cut -d ',' -f 2-)
        value2=$(echo "$line2" | cut -d ',' -f 2-)

        # Check if values are different
        if [ "$value1" != "$value2" ]; then
          echo -e "\n$key1 has different values:"
          echo -e "${Bright_Magenta} -- New value: $value1 ${RESET}"
          echo -e "${WHITE} -- Existing value: $value2 ${RESET}"
          csv_diff=yes
        fi
      done < "$1" 3< "$existing_csv"
      
      if [ -n "$csv_diff" ]; then
        echo -e "\n"
        logNewLine "Differences in "$(basename "$existing_csv")" CSV found" "$Bright_Red"
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
                logNewLine "Created $(basename "${old_CSVs_dir%/}") directory and moved pre-existing CSV file" "$YELLOW"
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
        # Append "+" to $datetime for date command formatting 
        datetime=$(echo "+${datetime}")
        # Convert date and time to Unix timestamp
        timestamp=$(date "${datetime}")
        # Check if the current timestamp is greater than the most recent one found
        if [[ $timestamp > $most_recent_timestamp ]]; then
            most_recent_timestamp=$timestamp
            most_recent_csv=$csv_file
        fi
    done
    # Print the most recent CSV filename
    logNewLine "Most recent CSV found in Artwork File: $most_recent_csv" "$CYAN"
    export most_recent_csv="${most_recent_csv}"
}

function findCSV {
	set -a

	echo -e "Required input variables for start_output.sh are not set. To define inputs, use start_input.sh.\n\nIf you would like to run start_output.sh on an artwork that has a completed input.csv, type or drag and drop the path of the artwork file:\n"
	read -e ArtFileInput
	ArtFile="$(echo -e "${ArtFileInput}" | sed -e 's/[[:space:]]*$//')"
	#Strips a trailing space from the input. 
	#If the user drags and drops the directory into terminal, it adds a trailing space, which, if passed to other commands, can result in errors. the sed command above prevents this.
	#I find sed super confusing, I lifted this command from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable

  export ArtFile="${ArtFile}"

	allFoundCSVs=$(find "${ArtFile}" -type f \( -iname "*.csv" \) | wc -l)
  if [[ ${allFoundCSVs} -lt 1 ]] ; then 
    logNewLine "No input csv found in Artwork File. Either run start_input to create necessary inputs or re-run start_output with input csv.\nUsage: ./start_output.sh <input.csv> <optional_output.csv>" "$RED"
    exit 1
  elif [[ ${allFoundCSVs} -eq 1 ]] ; then
    foundCSV=$(find "${ArtFile%/}" -type f \( -iname "*.csv" \))
    logNewLine "Found ${foundCSV} in ${ArtFile}"
	elif [[ ${allFoundCSVs} -gt 1 ]]; then
    # Create an array called $foundCSV[@] to iterate over to find most recent 
    while IFS= read -r -d '' csv_file; do
      # Append each file to the array
      foundCSV+=("$csv_file")
    done < <(find "${ArtFile}" -type f -iname "*.csv" -print0)
		find_most_recent_csv "${foundCSV[@]}"
		echo -e "\nMore than one CSV found in Art File. Use most recent?"
		IFS=$'\n'; select recentCSV_option in "Yes" "No, show all CSVs" ; do
			if [[ $recentCSV_option = "Yes" ]] ; then
				foundCSV="${most_recent_csv}"
        logNewLine "Found ${foundCSV} in ${ArtFile}" "$MAGENTA"
			elif [[ $recentCSV_option = "No, show all CSVs" ]] ; then 
				IFS=$'\n'; select selectedCSV in $(find "${ArtFile%/}" -type f \( -iname "*.csv" \)) "None of these" ; do
          if [[ $selectedCSV = "None of these" ]] ; then
            logNewLine "No operable input csv found. Either run start_input to create necessary inputs or re-run start_output with desired input csv.\nUsage: ./start_output.sh <input.csv> <optional_output.csv>" "$RED"
            exit 1
          else
            foundCSV=$selectedCSV
            logNewLine "\nFound ${foundCSV} in ${ArtFile}" "$CYAN"
          fi
        break
        done;
			fi
		break           
		done
	fi

  export foundCSV="${foundCSV}"
	set +a
} 

ReadCSV () {
  if [[ -n ${1} ]] ; then
    if [[ -f ${1} ]]; then 
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
    else
      logNewLine "Error: $(basename "${1}") not found." "$RED"
    fi
  fi
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
                if [[ "$arg" == "-t" ]] || [[ "$arg" == "--typo" ]]; then
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