#!/bin/bash
source style.sh
#!IMPORTANT!
# Coordinate system note:
# All functions use (x, y) order for clarity.
#   x → horizontal (columns)
#   y → vertical   (rows)
# "first" (fx, fy) = top-left
# "second" (sx, sy) = bottom-right


draw_box() {
	# Used To Control Where To Draw Boxes
	#local fx=$1 fy=$2 sx=$3 sy=$4 text=$5
	local fy=$1 fx=$2 sy=$3 sx=$4 text=$5  # row,col,row,col

	#TOP Line
	ui_cursor move "$fx" "$fy"
	for ((i=$fx; i<=$sx; i++)); do
		if [[ $i == $fx ]]; then
			echo -n $BX_TL
		elif [[ $i == $sx ]]; then
			echo -n $BX_TR
		else
			echo -n $BX_H
		fi
	done
	#BOTTOM LINE
	ui_cursor move "$fx" "$sy"  
	for ((i=$fx; i<=$sx; i++)); do
		if [[ $i == $fx ]]; then
			echo -n $BX_BL
		elif [[ $i == $sx ]]; then
			echo -n $BX_BR
		else
			echo -n $BX_H
		fi
	done

	#LEFT SIDE
	ui_cursor move "$fx" "$(($fy+1))"
	for ((i=$fy; i<=$((sy-2)); i++)); do
		echo -n $BX_V
		ui_cursor down 1
		ui_cursor backward 1
	done

	#RIGHT SIDE
	ui_cursor move "$sx" "$(($fy+1))"
	for ((i=$fy; i<=$(($sy-2)); i++)); do
		echo -n $BX_V
		ui_cursor down 1
		ui_cursor backward 1
	done

	if [[ -n $text ]]; then
		local text_len=${#text}
			local center_x=$((((sx-fx)/2)+$fx))

			local starting_x=$((center_x-(text_len/2)))
			local starting_y=$((((sy-fy)/2)+fy))
			ui_cursor move $((starting_x+1)) $starting_y
			local text_len=${#text}
				ui_cursor backward $(($text_len/2))
				echo -n $text
	fi
}

draw_text() {
	# Used To Print Text To The Screen 
	local fx=$1 fy=$2 text=$3 

	ui_cursor move "$fx" "$fy"
	echo -n $text
}

draw_menu() {
	# Used To Print An Interactable Menu To The Screen 
	local fx=$1 fy=$2 title=$3 
	local items=($4)
	local selected=0
	local text_len
	
	# Use read -rsn1 for key capture (up/down arrows)
	ui_cursor move "$fx" "$fy"
	echo -n "X"
	ui_cursor up 1
	echo -n "$title"
	ui_cursor down 2 
	for item in ${items[@]}; do
		echo -n "$item"
		text_len=${#item}
		ui_cursor backward $text_len
		ui_cursor down 1
	done
}

draw_progress() {
}

draw_spinner() {
}

draw_input_field() {
}

draw_confirmation() {
}


