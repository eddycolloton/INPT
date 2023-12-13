#!/bin/bash

mainfest_search=$(find "/Users/eddy/Desktop/artwork_files/Last, First/time-based media/2000.111_Title/Technical Info_Specs" -type f -name "*_manifest.md5")
# Use a while loop to read each line from the find command output
echo "${mainfest_search}" | while read -r file; do
# Read from the current file and process its content
	#echo "$file"
	while IFS='  ' read -r md5 filename; do
	# Print the result for each line
		echo "$filename"
		#echo "$md5"
	done < "$file"
done
unset IFS