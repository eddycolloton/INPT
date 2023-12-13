#!/bin/bash

source "${script_dir}"/start_output_functions/tools.sh

function RunTools {
	if [[ "$Run_meta" = "1" ]] ; then 
		RunTree; RunSF; RunMI; RunExif; Make_Framemd5; Make_QCT 
	fi

	if [[ "$Run_tree" = "1" ]] ; then 
		RunTree
	fi

	if [[ "$Run_sf" = "1" ]] ; then 
		RunSF
	fi

	if [[ "$Run_mediainfo" = "1" ]] ; then 
		RunMI
	fi

	if [[ "$Run_exif" = "1" ]] ; then 
		RunExif
	fi

	if [[ "$Run_framemd5" = "1" ]] ; then 
		Make_Framemd5
	fi

	if [[ "$Run_QCTools" = "1" ]] ; then 
		Make_QCT
	fi
}