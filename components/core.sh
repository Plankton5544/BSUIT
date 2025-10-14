#!/bin/bash

ui_init() {
	# Used For Initialization Of The Bash Script User Interface Translator (BSUIT)

	# Enable automatic updating of LINES and COLUMNS
	shopt -s checkwinsize

	# Force an update by running a command (needed initially)
	(:)  # Empty subshell - triggers window size check

	ui_clear entire
	ui_cursor home
	ui_running=0	
	ui_cols=$COLUMNS
	ui_rows=$LINES
}

ui_clear() {
	# Used To Clear Screen Position Based On Command
	local command=$1

	case $command in 
		"entire") 
			echo -ne "\e[2J" #<--ENTIRE SCREEN CLEAR
			;;

		"curs-end")
			echo -ne "\e[J" #<--CURSOR TO END OF SCREEN
			;;

		"curs-beg")
			echo -ne "\e[1J" #<--CURSOR TO BEGGINING OF SCREEN
			;;

		"curs-end-line")
			echo -ne "\e[K" #<--CURSOR TO END OF LINE
			;;

		"curs-beg-line")
			echo -ne "\e[1K" #<--CURSOR TO BEGGINING OF LINE
			;;

		"entire-line")
			echo -ne "\e[2K" #<--ENTIRE LINE CLEAR
			;;
		*)
			echo -n ""
			;;
	esac
}

ui_cursor() {
	# Used For Controlling The Cursor Position Etc.
	local command=$1 lines=$2 cols=$3

	case $command in 
		"up") 
			echo -ne "\e[${lines}A" #<--CURSOR UP $2 LINES
			;;

		"down")
			echo -ne "\e[${lines}B" #<--CURSOR DOWN $2 LINES
			;;

		"forward")
			echo -ne "\e[${lines}C" #<--CURSOR FORWARD $2 COLUMNS
			;;

		"backward")
			echo -ne "\e[${lines}D" #<--CURSOR BACKWARD $2 COLUMNS
			;;

		"move")
			echo -ne "\e[$cols;${lines}H" #<--CURSOR MOVE TO ROW $2 COLUMN $3
			;;

		"home")
			echo -ne "\e[H" #<--CURSOR TO POS(0,0)
			;;

		"save_pos")
			echo -ne "\e[s" #<--SAVE CURSOR POS
			;;

		"rest_pos")
			echo -ne "\e[u" #<--RESTORE CURSOR POS
			;;
		*)
			echo -n ""
			;;
	esac
}

ui_cursor_cont() {
	# Used To Control The Cursor Other Than Position Basis
	local command=$1

	case $command in 
		"hide") 
			echo -ne "\e[?25l" #<--HIDES CURSOR
			;;

		"show") 
			echo -ne "\e[?25h" #<--SHOW CURSOR
			;;
		*)
			echo -n ""
			;;
	esac
}

ui_wait() {
	# Used For Pre-Input & Potential As Sleep
	local timeout=$1 key_num=$2

	ui_cursor $ui_rows $ui_cols
	if read -t $timeout -n $key_num key; then
		process_input $key
	fi
}

ui_input() {
	# Custom Key Processes 
	local key=$1

	#<--HERE

	echo -n $key
}

ui_exit() {
	# Cleanup Process Etc.
	ui_clear entire
	ui_cursor home
	ui_running=1
	ui_cursor_cont show
}
