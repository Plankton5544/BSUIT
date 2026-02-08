#!/bin/bash
source ~/BSUIT/components/style.sh

init() {
  curs_vis hide
  SCREEN_BUFFER=""
  BUFFERED=""
  MODE="BASE"
  SELECTED=0
  ACTIVE=0
  HISTORY=()
  ITEMS=()
  buffer alternate
}

buffer() {
  local flag="$1"
  case "$flag" in
    "write")
      local input="$2"
      SCREEN_BUFFER+="$input"
      ;;
    "flush")
      if [[ "$SCREEN_BUFFER" != "$BUFFERED" ]]; then
        echo -ne "\e[1;1H$SCREEN_BUFFER"
        # Go to 1,1 and write entire buffer
        BUFFERED="$SCREEN_BUFFER"
      fi
      buffer clears
      ;;
    "clears")
      SCREEN_BUFFER=""
      ;;
    "alternate") echo -en "\e[?1049h"  ;;
    *)     echo -en "\e[?1049l"  ;;
    # Defualts to Alternative Buff Off
  esac
}

hush() {
  builtin hash "$1" 2>/dev/null;
}

nothing() {
  (:)
}

curs_vis() {
  local flag="$1"
  case "$flag" in
    "hide") echo -en "\e[?25l" ;; # Hides Cursor
    *)      echo -en "\e[?25h" ;; # Defualts To Show
  esac
}

curs_goto() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  buffer write "\e[${y};${x}H"
  # Writes cursor instruction to buffer
}

curs_center() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"
  local center_x=$(((width/2)+x))
  local center_y=$(((height/2)+y))
  curs_goto $center_x $center_y
}

clears() {
  local flag="$1"
  case "$flag" in
    "display")     buffer write "\e[J"  ;;
    "curs-screen") buffer write "\e[0J" ;;
    "screen-curs") buffer write "\e[1J" ;;
    "screen")      buffer write "\e[2J" ;;
    "inline")      buffer write "\e[K"  ;;
    "line")        buffer write "\e[2K" ;;
    "curs-line")   buffer write "\e[0K" ;;
    "line-curs")   buffer write "\e[1K" ;;
    *)             buffer write "\e[2J" ;;
  esac
}

read_keys(){
  local time="$1"

  if [[ -n $time ]]; then
    read -rsn 1 -t "$time"
  else
    read -rsn 1
  fi

  if [[ $REPLY == $'\e' ]]; then
    read -rsn 2
    # Outputs [A, B, C, D as arrow keys
  elif [[ $REPLY == '\' ]]; then
    unset "HISTORY[-1]"
  else
    HISTORY+=("$REPLY")
  fi
}


cleanup() {
  curs_vis show
  unset "SCREEN_BUFFER"
  unset "BUFFERED"
  unset "MODE"
  unset "SELECTED"
  unset "ACTIVE"
  unset "HISTORY"
  unset "ITEMS"
  buffer normal
}

dispatch() {
  nothing
  modes_arr=("$@") # modes_arr is all of the render args

  for mode in "${modes_arr[@]}"; do
    if [[ "$MODE" == "$mode" ]]; then # Check if MODE matches current mode
      buffer clears
      clears screen
      "$mode" # Execute function named mode
      buffer flush
    fi
  done
}

draw_box() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"
  local style="$5" #Single Double Bold Rounded Block
  case $style in
    "double")
      local vert="$DBX_V" local horz="$DBX_H"
      local tl="$DBX_TL"  local tr="$DBX_TR"
      local bl="$DBX_BL"  local br="$DBX_BR"
      ;;
    "bold")
      local vert="$HBX_V" local horz="$HBX_H"
      local tl="$HBX_TL"  local tr="$HBX_TR"
      local bl="$HBX_BL"  local br="$HBX_BR"
      ;;
    "rounded")
      local vert="$BX_V" local horz="$BX_H"
      local tl="$RBX_TL" local tr="$RBX_TR"
      local bl="$RBX_BL" local br="$RBX_BR"
      ;;
    "block")
      local vert="$BLK_FULL" local horz="$BLK_FULL"
      local tl="$BLK_FULL"   local tr="$BLK_FULL"
      local bl="$BLK_FULL"   local br="$BLK_FULL"
      ;;
    *)
      local vert="$BX_V" local horz="$BX_H"
      local tl="$BX_TL"  local tr="$BX_TR"
      local bl="$BX_BL"  local br="$BX_BR"
      ;;
  esac

  # TOP & BOTTOM LINE
  for ((i=1; i<$width; i++)); do
    curs_goto $((x+i)) $y
    buffer write "$horz"
    curs_goto $((x+i)) $((y+height))
    buffer write "$horz"
  done

  # LEFT & RIGHT LINE
  for ((i=1; i<$height; i++)); do
    curs_goto $x $((y+i))
    buffer write "$vert"
    curs_goto $((x+width)) $((y+i))
    buffer write "$vert"
  done

  # TOP LEFT
  curs_goto $x $y
  buffer write $tl
  # TOP RIGHT
  curs_goto $((x+width)) $y
  buffer write $tr
  # BOTTOM LEFT
  curs_goto $x $((y+height))
  buffer write $bl
  # BOTTOM RIGHT
  curs_goto $((x+width)) $((y+height))
  buffer write $br
  }


draw_text() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local text="$3"
  curs_goto $x $y
  buffer write $text
}

draw_aligned_text() {
  local x="$1"
  local y="$2"
  local text="$3"
  local direction="$4" # Center Right Left*
  local length=${#text}
    case $direction in
      "center")
        curs_goto $((x-(length/2))) $y
        buffer write "$text"
        ;;
      "right")
        curs_goto $x $y
        buffer write "$text"
        ;;
      *) # Left
        curs_goto $((x-length)) $y
        buffer write "$text"
        ;;
    esac
}

colored() {
  local color_code="${!1}"  # Get color code via indirect expansion
  shift                     # Remove color arg
  local function="$1"       # Get function name
  shift                     # Remove function arg

  [[ -n "$color_code" ]] && buffer write "$color_code"
  "$function" "$@"          # Call function with remaining args
  buffer write "$RST"
}

display_progress() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local raw_prog="$4"
  ## Input does accept integer & with %
  local executable="$5"
  #Needs to be a function that this executes when done

  local prog=0
  local units=1

  if [[ "$raw_prog" == *'%'* ]]; then
    prog=${raw_prog//%/}
  else
    prog=$raw_prog
  fi

  if [[ $prog -lt 1 ]]; then
    units=0
    prog=0
  elif [[ $prog -gt 100 ]]; then
    if [[ -n $executable ]]; then
      units=0
      prog=0
      "$executable"
    else
      units=$width
      prog=100
    fi
  else
    local units=$(( (width * prog) / 100 ))
  fi

  curs_goto $x $y

  for i in $(seq 1 $width); do
    if [[ $i -gt 0 && $i -le $units ]]; then
      buffer write $BAR_FULL
    else
      buffer write $BAR_EMPTY
    fi
  done
}

display_spinner() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local state="$3" ## 1-8
  local spin="SPIN_$state"

  curs_goto $x $y
  buffer write "${!spin}"
}

display_menu() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"

  if [[ $SELECTED -lt 0 ]]; then
    SELECTED=0
  elif [[ $SELECTED -gt ${#ITEMS[@]} ]]; then
    SELECTED=${#ITEMS[@]}
  fi
  if [[ $SELECTED -eq $((height-1)) ]]; then
    SELECTED=$((SELECTED-=1))
  fi

  if [[ "$ACTIVE" == "1" ]]; then
    local exec="${ITEMS[SELECTED]}"
    "$exec" # Execute function named after the mode
    ACTIVE=0
    return
  fi

  draw_box $x $y $width $height single
  for ((i=0; i<${#ITEMS[@]}; i++)); do
    curs_goto $((x+1)) $(((y+1)+i))
    if [[ "$i" -eq $SELECTED ]]; then
      buffer write "[x] ${ITEMS[i]}"
    else
      buffer write "[ ] ${ITEMS[i]}"
    fi
  done
}


display_field() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  draw_box $x $y $width 2
  curs_goto $((x + 1)) $((y + 1))

  for letter in ${HISTORY[@]}; do
    buffer write "$letter"
  done
}

truncate_text() {
  local x="$1"
  local y="$2"
  local text="$3"
  local limit="$4"
  local length=${#text}
    if [[ $length -gt $limit ]]; then
      text=${text:0:$limit}
    fi
  curs_goto $x $y
  echo -n "$text"
}

center() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local flag="$3"
  if [[ "$flag" == "x" ]]; then
    local width="$4"
    local center=$(((width/2)+x))
  elif [[ "$flag" == "y" ]]; then
    local height="$4"
    local center=$(((height/2)+y))
  fi

  echo -n "$center"
}

header() {
  draw_box 1 1 $COLUMNS 2 block
  local header="${MODE^^}"
  local len=${#header}
  curs_center 1 2 $((COLUMNS - len)) 1
  buffer write "$header"
}

subber() {
  local text="$1"
  local len=${#text}
  draw_box 2 4 $((COLUMNS - 3)) 2 block
  curs_center 1 5 $((COLUMNS - len)) 1

  buffer write "$text"
}

BASE() {
  header
  subber "(q) to QUIT (1) to Leader"

  read_keys 1.5

  case "$REPLY" in
    "q") MODE="break"  ;;
    "1") MODE="leader" ;;
  esac
}


