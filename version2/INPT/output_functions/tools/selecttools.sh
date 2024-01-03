function SelectTools {
	# Prompts user to run metadata tools
	echo -e "\n*************************************************\n
If you select \"yes,\" this will be the final prompt and applications will run after this response!\n
Otherwise, you will be asked about each tool individually.
\n*************************************************\n"
	sleep 1

#Consider - changing all tool selection to a function that takes 2 vars, option and repeat_prev_option
#Then run functions and repeat functions w/ if statement or something instead of while loop

	meta_option_again=yes
	while [[ "$meta_option_again" = yes ]]
	# https://unix.stackexchange.com/questions/232761/get-script-to-run-again-if-input-is-yes
	do
	echo -e "Run metadata tools (tree, siegfried, MediaInfo, Exiftool, framemd5, and qctools) on files copied to $SDir (Choose a number 1-2)"
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

	if [[ "$Run_meta" -eq "0" ]]; then
		echo -e "\n*************************************************\nRun tree on $Volume (Choose a number 1-2)"
		select Tree_option in "yes" "no" "go back a step"; do
			case $Tree_option in
				yes)
					Run_tree=1
					tree_option_again=no
					break;;
				no)
					Run_tree=0
					tree_option_again=no
					break;;
				"go back a step")
					unset Meta_option Run_meta Tree_option
					meta_option_again=yes
					break;;
			esac
		done
	fi

	if [[ "$meta_option_again" = yes ]]; then 
		echo -e "\n\n!! Going back a step !! \n"
	fi
	done

	if [[ "$Run_meta" -eq "0" ]]; then
		echo -e "\n*************************************************\nRun siegfried on $SDir (Choose a number 1-2)"
		select SF_option in "yes" "no" "go back a step"; do
			case $SF_option in
				yes)
					Run_sf=1
					sf_option_again=no
					break;;
				no)
					Run_sf=0
					sf_option_again=no
					break;;
				"go back a step")
					unset Tree_option Run_tree SF_option
					tree_option_again=yes
					break;;
			esac
		done
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		echo -e "\n*************************************************\nRun MediaInfo on video files in $SDir (Choose a number 1-2)"
		select MI_option in "yes" "no" "go back a step"; do
			case $MI_option in
				yes)
					Run_mediainfo=1
					mi_option_again=no
					break;;
				no)
					Run_mediainfo=0
					mi_option_again=no
					break;;
				"go back a step")
					unset SF_option Run_sf MI_option
					sf_option_again=yes
					break;;
			esac
		done
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		echo -e "\n*************************************************\nRun Exiftool on image files in $SDir (Choose a number 1-2)"
		select Exif_option in "yes" "no" "go back a step"; do
			case $Exif_option in
				yes)
					Run_exif=1
					exif_option_again=no
					break;;
				no)
					Run_exif=0
					exif_option_again=no
					break;;
				"go back a step")
					unset MI_option Run_mediainfo Exif_option
					mi_option_again=yes
					break;;
			esac
		done
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		echo -e "\n*************************************************\nCreate framemd5 text files for each of the video files in $SDir (Choose a number 1-2)"
		select Fmd5_option in "yes" "no" "go back a step"; do
			case $Fmd5_option in
				yes)
					Run_framemd5=1
					Fmd5_option_again=no
					break;;
				no)
					Run_framemd5=0
					Fmd5_option_again=no
					break;;
				"go back a step")
					unset Exif_option Run_exif Fmd5_option
					exif_option_again=yes
					break;;
			esac
		done
	fi

	if [[ "$Run_meta" -eq "0" ]]; then
		echo -e "\n*************************************************\nThis will be the final prompt, and applications will run after this response!\nCreate QCTools reports for each of the video files in $SDir (Choose a number 1-2)\n*************************************************\n"
		select QCT_option in "yes" "no"; do
			case $QCT_option in
				yes)
					Run_QCTools=1
					QCT_option_again=no
					break;;
				no)
					Run_QCTools=0
					QCT_option_again=no
					break;;
				"go back a step")
					unset Fmd5_option Run_framemd5 QCT_option
					Fmd5_option_again=yes
					break;;
			esac
		done
	fi
}
