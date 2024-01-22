#!/bin/bash

source "${script_dir}"/output_functions/move/movefiles.sh

function RunMoveFiles {
	if [[ "$Run_Copyit" = "1" ]] ; then 
		FindcopyitPath && CopyitVolumeStaging
	fi

	if [[ "$Run_FileCopy" = "1" ]] ; then 
		RunIndvMD5 && CopyFiles && DeleteList
	fi

	if [[ "$Run_MultiCopy" = "1" ]] ; then 
		FindcopyitPath && CopyitSelected && DeleteList
	fi
}