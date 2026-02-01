#!/bin/bash
source ~/BSUIT/components/style.sh

hush() {
  builtin hash "$1" 2>/dev/null;
}

nothing() {
  (:)
}

curs_goto() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  echo -en "\e[${y};${x}H"
}

curs_vis() {
  local flag="$1"
  case "$flag" in
    "hide") echo -en "\e[?25l" ;;
    *)      echo -en "\e[?25h" ;; # Defualts To Show
  esac
}

buffer() {
  local flag="$1"
  case "$flag" in
    "alt") echo -en "\e[?1049h"  ;;
    *)     echo -en "\e[?1049l"  ;; # Defualts to Alt Buff Off
  esac
}

clears() {
  local flag="$1"
  case "$flag" in
    "display") echo -en "\e[J";;
    "curs-screen") echo -en "\e[0J";;
    "screen-curs") echo -en "\e[1J";;
    "screen") echo -en "\e[2J";;
    "saved") echo -en "\e[3J";;
    "inline") echo -en "\e[K";;
    "curs-line") echo -en "\e[0K";;
    "line-curs") echo -en "\e[1K";;
    "line") echo -en "\e[2K";;
    *) ;;
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
    unset History[-1]
  else
    History+=("$REPLY")
  fi
}

init() {
  curs_vis hide
  Mode="base"
  Selected=0
  Active=0
  History=()
  Items=()
  buffer alt
}

cleanup() {
  curs_vis show
  Mode=""
  Selected=
  Active=
  Items=()
  buffer normal
}

dispatch() {
  nothing
  modes_arr=("$@") # modes_arr is all of the render args

  for mode in "${modes_arr[@]}"; do
    if [[ "$Mode" == "$mode" ]]; then # Check if Mode matches current mode
      clears screen
      "$mode" # Execute function named mode
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
    echo -en "$horz"
    curs_goto $((x+i)) $((y+height))
    echo -en "$horz"
  done
  # LEFT & RIGHT LINE
  for ((i=1; i<$height; i++)); do
    curs_goto $x $((y+i))
    echo -en "$vert"
    curs_goto $((x+width)) $((y+i))
    echo -en "$vert"
  done
  # TOP LEFT
  curs_goto $x $y
  echo -en $tl
  # TOP RIGHT
  curs_goto $((x+width)) $y
  echo -en $tr
  # BOTTOM LEFT
  curs_goto $x $((y+height))
  echo -en $bl
  # BOTTOM RIGHT
  curs_goto $((x+width)) $((y+height))
  echo -en $br
  }

colored_draw_box() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"
  local style="$5" #Single Double Bold Rounded Block
  local color="$6"
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
      local tl="$BX_TL"  local tr="$BX_TR"
      local vert="$BX_V" local horz="$BX_H"
      local bl="$BX_BL"  local br="$BX_BR"
      ;;
  esac
  echo -e $color

  # TOP & BOTTOM LINE
  for ((i=1; i<$width; i++)); do
    curs_goto $((x+i)) $y
    echo -en "$horz"
    curs_goto $((x+i)) $((y+height))
    echo -en "$horz"
  done
  # LEFT & RIGHT LINE
  for ((i=1; i<$height; i++)); do
    curs_goto $x $((y+i))
    echo -en "$vert"
    curs_goto $((x+width)) $((y+i))
    echo -en "$vert"
  done

  # TOP LEFT
  curs_goto $x $y
  echo -en $tl
  # TOP RIGHT
  curs_goto $((x+width)) $y
  echo -en $tr
  # BOTTOM LEFT
  curs_goto $x $((y+height))
  echo -en $bl
  # BOTTOM RIGHT
  curs_goto $((x+width)) $((y+height))
  echo -en $br
  echo -en $RST
}

draw_text() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local text="$3"
  curs_goto $x $y
  echo -n $text
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
        echo -n "$text"
        ;;
      "right")
        curs_goto $x $y
        echo -n "$text"
        ;;
      *) # Left
        curs_goto $((x-length)) $y
        echo -n "$text"
        ;;
    esac
}

display_menu() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"
  # Engine Vars:
  # Active Selected Items

  if [[ "$Active" == "1" ]]; then
    local exec="${Items[Selected]}"
    "$exec" # Execute function named after the mode
    Active=0
    return
  fi

  draw_box $x $y $width $height single
  for ((i=0; i<${#Items[@]}; i++)); do
    curs_goto $((x+1)) $(((y+1)+i))
  if [[ $Selected -lt 0 ]]; then
    Selected=0
  elif [[ $Selected -gt ${#Items[@]} ]]; then
    Selected=${#Items[@]}
  fi
    if [[ $Selected -eq $((height-1)) ]]; then
      Selected=$((Selected-=1))
    fi
    if [[ "$i" -eq $Selected ]]; then
      echo -n "[x] ${Items[i]}"
    else
      echo -n "[ ] ${Items[i]}"
    fi
  done
}

display_field() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  draw_box $x $y $width 2
  curs_goto $((x + 1)) $((y + 1))


  for letter in ${History[@]}; do
    echo -n "$letter"
  done
}

draw_progress() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local progress="$4"

  draw_box $x $y $width 2
  curs_goto $((x + 1)) $((y + 1))

  #TODO FINISH THIS
}

#TODO Tree Views
#TODO Status Bar
#TODO Notifications
#TODO Panels/Splits

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
  echo -e $text
}

center() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local flag="$3"
  if [[ "$flag" == "x" ]]; then
    local width="$4"
    return local center=$(((width/2)+x))
  elif [[ "$flag" == "y" ]]; then
    local height="$4"
    return local center_y=$(((height/2)+y))
  fi
}

center_pos() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"
  local center_x=$(((width/2)+x))
  local center_y=$(((height/2)+y))
  curs_goto $center_x $center_y
}

header() {
  draw_box 1 1 $COLUMNS 2 block
  local header="${Mode^^}"
  local len=${#header}
  center_pos 1 2 $((COLUMNS - len)) 1
  echo -n $header
}

subber() {
  local text="$1"
  local len=${#text}
  draw_box 2 4 $((COLUMNS - 3)) 2 block
  center_pos 1 5 $((COLUMNS - len)) 1
  echo -n $text
}

base() {
  header
  subber "(q) to QUIT (1) to Leader"

  read_keys 1.5
  # Time can be adjust, aber warning on Epilepsy
  case "$REPLY" in
    "q") Mode="break"  ;;
    "1") Mode="leader" ;;
  esac
}

