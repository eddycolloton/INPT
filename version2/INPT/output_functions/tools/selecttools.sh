#!/bin/bash

function SelectMeta {
	echo -e "\nRun metadata tools (tree, siegfried, MediaInfo, Exiftool, framemd5, and qctools) on files copied to $SDir (Choose a number 1-2)"
	select Meta_option in "yes" "no"; do
		case $Meta_option in
			yes)
				Run_meta=1
				meta_option_again=no
				break;;
			no)
				Run_meta=0
				meta_option_again=no
				break;;
		esac
	done

	if [[ "$Run_meta" -eq "1" ]]; then
		echo -e "\nConfirm you would like to run all metadata tools:"
		select Meta_confirm in "yes" "no"; do
			case $Meta_confirm in
				yes)
					meta_option_again=no
					break;;
				no)
					meta_option_again=yes
					break;;
			esac
		done
	fi
}

SelectOption () {
    local option_select="$1"
    local option_again="$2"
    local prev_option_again="$3"
	select options in "yes" "no" "go back a step"; do
		case $options in
			yes)
				select_value=1
				select_again=no
                eval "$option_select=\$select_value"
                eval "$option_again=\$select_again"
				break;;
			no)
				select_value=0
				select_again=no
                eval "$option_select=$select_value"
                eval "$option_again=$select_again"
				break;;
			"go back a step")
                select_prev_again=yes
                eval "$prev_option_again=\$select_prev_again"
				break;;
		esac
	done
}

function SelectTree {
	echo -e "\n*************************************************\nRun tree on $Volume (Choose a number 1-2)"
	SelectOption "Run_tree" "tree_option_again" "meta_option_again"
}

function SelectSF {
	echo -e "\n*************************************************\nRun siegfried on $SDir (Choose a number 1-2)"
	SelectOption "Run_sf" "sf_option_again" "tree_option_again"
}

function SelectMI {
	echo -e "\n*************************************************\nRun MediaInfo on video files in $SDir (Choose a number 1-2)"
	SelectOption "Run_mediainfo" "mi_option_again" "sf_option_again"
}

function SelectExif {
	echo -e "\n*************************************************\nRun Exiftool on image files in $SDir (Choose a number 1-2)"
	SelectOption "Run_exif" "exif_option_again" "mi_option_again"
}

function SelectFmd5 {
	echo -e "\n*************************************************\nCreate framemd5 text files for each of the video files in $SDir (Choose a number 1-2)"
	SelectOption "Run_framemd5" "Fmd5_option_again" "exif_option_again"
}

function SelectQCT {
	echo -e "\n*************************************************\nThis will be the final prompt, and applications will run after this response!\nCreate QCTools reports for each of the video files in $SDir (Choose a number 1-2)\n*************************************************\n"
	SelectOption "Run_QCTools" "QCT_option_again" "Fmd5_option_again"
}

function SelectTools {
	# Prompts user to run metadata tools
	echo -e "\n*************************************************\n
If you select \"yes,\" this will be the final prompt and applications will run after this response!\n
Otherwise, you will be asked about each tool individually.
\n*************************************************"
	sleep 1

	meta_option_again=yes
	SelectMeta

	if [[ "$Run_meta" -eq "0" ]]; then
		tree_option_again=yes
		SelectTree
	fi

	if [[ "$meta_option_again" = "yes" ]]; then 
		unset Run_meta
		SelectMeta
		SelectTree
	fi
	
	if [[ "$Run_meta" -eq "0" ]]; then
		sf_option_again=yes
		SelectSF
	fi

	if [[ "$tree_option_again" = "yes" ]]; then
		unset Run_tree
		SelectTree
		SelectSF
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		mi_option_again=yes
		SelectMI
	fi

	if [[ "$sf_option_again" = "yes" ]]; then
		unset Run_sf
		SelectSF
		SelectMI
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		exif_option_again=yes
		SelectExif
	fi
	
	if [[ "$mi_option_again" = "yes" ]]; then
		unset Run_mediainfo
		SelectMI
		SelectExif
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		Fmd5_option_again=yes
		SelectFmd5
	fi
	
	if [[ "$exif_option_again" = "yes" ]]; then
		unset Run_exif
		SelectExif
		SelectFmd5
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		QCT_option_again=yes
		SelectQCT
	fi

	if [[ "$Fmd5_option_again" = "yes" ]]; then
		unset Run_framemd5
		SelectFmd5
		SelectQCT
	fi

	if [[ "$Run_QCTools" -eq "1" ]]; then
		echo -e "\nConfirm you would like to create QCTools reports for each of the video files in $SDir:"
		select QCT_confirm in "yes" "no"; do
			case $QCT_confirm in
				yes)
					QCT_option_again=no
					break;;
				no)
					QCT_option_again=yes
					break;;
			esac
		done
	fi

	if [[ "$QCT_option_again" = "yes" ]]; then
		unset Run_QCTools
		SelectQCT
	fi
}
