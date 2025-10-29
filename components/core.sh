#!/bin/bash
# GLOBALS
declare selection=0



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
      # Note- just using the x & y defined locally earlier
      local sx=$4 sy=$5
      mid_x=$(((((sx-x)/2)+$x))) #<--Basically Finds Delta X
      mid_y=$(((((sy-y)/2)+$y))) #<--Basically Finds Delta Y
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
  case $key in
    "j")
        ((selection++))
      ;;
    "k")
      ((selection--))
      ;;
    "")
      ;;
  esac

}

ui_wait() {
	# Used For Pre-Input & Potential As Sleep
	local timeout=$1
read -rsn3
	ui_cursor "$LINES" "$COLUMNS"
 if read -rsn1 -t $timeout key; then
    # Check if it's an escape sequence
    if [[ $key == $'\e' ]]; then
      read -rsn2 -t 0.1 key  # Read the rest of the arrow key sequence
      case $key in
        '[A') ui_input 'k' ;;  # Up arrow
        '[B') ui_input 'j' ;;  # Down arrow
      esac
    else
      ui_input "$key"  # Regular key (j, k, Enter, Etc)
    fi
 fi
}

ui_exit() {
	# Cleanup Process Etc.
	ui_clear entire
	ui_cursor home
	ui_cursor_cont show
}
