#!/bin/bash
declare selection



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

ui_init() {
	# Used For Initialization Of The Bash Script User Interface Translator (BSUIT)

	# Enable automatic updating of LINES and COLUMNS
	shopt -s checkwinsize

	# Force an update by running a command (needed initially)
	(:)  # Empty subshell - triggers window size check

	ui_clear entire
	ui_cursor home
	ui_cursor_cont hide
}

ui_cursor() {
	# Used For Controlling The Cursor Position Etc.
  #	x=horizontal(col) y=vertical(row)
  local command=$1 x=$2 y=$3

	case $command in
		"up")
			echo -ne "\e[${x}A"
			;;

		"down")
			echo -ne "\e[${x}B"
			;;

		"forward")
			echo -ne "\e[${x}C"
			;;

		"backward")
			echo -ne "\e[${x}D"
			;;

		"move")
      # ANSI wants (row, col) but we take (x, y) = (col, row)
      echo -ne "\e[${y};${x}H"
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
		"center")
      # Note- The row & col are used as bot_x & y
      local sx=$4 sy=$5
      mid_x=$(((((x-sx)/2)+$x))) #<--Basically Finds Delta X
      mid_y=$(((((y-sy)/2)+$y))) #<--Basically Finds Delta Y
      echo -ne "\e[$mid_x;${mid_y}H"
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

ui_input() {
  # Custom Key Processes
  local key=$1
  case in $key
    "j")
      if [[ $selection -gt 0 ]]; then
        ((selection--))
      fi
      ;;
    "k")
      ((selection++))
      ;;
    "\\n")
      ;;
  esac

}

ui_wait() {
	# Used For Pre-Input & Potential As Sleep
	local timeout=$1 key_num=$2

	ui_cursor "$LINES" "$COLUMNS"
	if read -t $timeout -n $key_num key; then
		ui_input $key
	fi
}

ui_exit() {
	# Cleanup Process Etc.
	ui_clear entire
	ui_cursor home
	ui_cursor_cont show
}
