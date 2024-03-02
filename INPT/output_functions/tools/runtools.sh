#!/bin/bash

source "${script_dir}"/output_functions/tools/tools.sh

function RunTools {
	# if the sidecar directory doesn't exist, create one
	if [[ ! -d ${sidecardir} ]] ; then
		mkdir "${sidecardir}"
	fi
	
	if [[ "$Run_meta" = "1" ]] ; then
		echo -e "\n" 
		RunTree; RunSF; RunMI; RunExif; Make_Framemd5; Make_QCT 
	fi

	if [[ "$Run_tree" = "1" ]] ; then 
		echo -e "\n" 
		RunTree
	fi

	if [[ "$Run_sf" = "1" ]] ; then 
		echo -e "\n" 
		RunSF
	fi

	if [[ "$Run_mediainfo" = "1" ]] ; then 
		echo -e "\n" 
		RunMI
	fi

	if [[ "$Run_exif" = "1" ]] ; then 
		echo -e "\n" 
		RunExif
	fi

	if [[ "$Run_framemd5" = "1" ]] ; then 
		echo -e "\n" 
		Make_Framemd5
	fi

	if [[ "$Run_QCTools" = "1" ]] ; then 
		echo -e "\n" 
		Make_QCT
	fi
}