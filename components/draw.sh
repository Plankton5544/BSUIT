#!/bin/bash
#!IMPORTANT!
# Coordinate system note:
# All functions use (x, y) order for clarity.
#   x → horizontal (columns)
#   y → vertical   (rows)
# "first" (fx, fy) = top-left
# "second" (sx, sy) = bottom-right

draw_box() {
	# Used To Control Where To Draw Boxes
	local fx=$1 fy=$2 sx=$3 sy=$4 text=$5

	#TOP Line
	ui_cursor move "$fx" "$fy"
	for ((i=$fx; i=<$sx; i++)); do
		echo -n "_"
	done

	#BOTTOM LINE
	ui_cursor move "$sx" "$(($fy))"
	for ((i=$fx; i<=$sx; i++)); do
		if [[ $i == $fx || $i == $(($sx-1)) ]]; then
			echo -n "|"
		else
			echo -n "_"
		fi
	done

	#LEFT SIDE
	ui_cursor move "$fx" "$(($fy+1))"
	for ((i=$fy; i<=$(($sy-1)); i++)); do
		echo -n "|"
		ui_cursor down 1
		ui_cursor backward 1
	done

	#RIGHT SIDE
	ui_cursor move "$(($sx-1))" "$(($fy+1))"
	for ((i=$fy; i<=$(($sy-1)); i++)); do
		echo -n "|"
		ui_cursor down 1
		ui_cursor backward 1
	done

	if [[ -n $text ]]; then
		local	center_x=$((((sx-fx)/2)+fx))
		local	center_y=$((((sy-fy)/2)+fy))
		ui_cursor move $center_x $center_y
		local text_len=${#text}
		ui_cursor backward $(($text_len/2))
			echo -n $text
	fi
}

draw_text() {
	# Used To Print Text To The Screen 
	local fx=$1 fy=$2 text=$3 

	ui_cursor move "$fy" "$fx"
	echo -n $text
}
