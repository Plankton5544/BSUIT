#!/bin/bash
source ~/BSUIT/components/style.sh

if [[ -z $1 ]] || [[ -z $2 ]]; then
  echo "PLEASE USE:"
  echo "./core.sh [COLUMNS] [LINES]"
  exit
fi

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

read_key() {
  local flag="$1"
  if [[ "$flag" == "timed" ]]; then
    local time="$2"
    read -sr -n 1 -t ${time} input
  else
    read -sr -n 1 input
  fi
  echo -n $input
}

update() {
  local key="$1"
  case "$MODE" in
    "TEST")
      case "$key" in
        "q") RUNNING="FALSE";;
      esac ;;
  esac
}

render() {
  local key="$1"
  clears screen
  curs_goto 1 1

  case "$MODE" in
    "TEST")
      draw_box 14 10 12 2 rounded
      draw_text 0 $LINES "TEST"
      draw_aligned_text 20 10 "Hello World" center
      truncate_text 20 25 "Hello World" 5
      ;;
  esac
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
    echo -n "$horz"
    curs_goto $((x+i)) $((y+height))
    echo -n "$horz"
  done
  # LEFT & RIGHT LINE
  for ((i=1; i<$height; i++)); do
    curs_goto $x $((y+i))
    echo -n "$vert"
    curs_goto $((x+width)) $((y+i))
    echo -n "$vert"
  done
  # TOP LEFT
  curs_goto $x $y
  echo -e $tl
  # TOP RIGHT
  curs_goto $((x+width)) $y
  echo -e $tr
  # BOTTOM LEFT
  curs_goto $x $((y+height))
  echo -e $bl
  # BOTTOM RIGHT
  curs_goto $((x+width)) $((y+height))
  echo -e $br
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
  curs_goto $x $y
  echo -n "x"
  for ((h=0; h<$((height+1)); h++)); do
    for ((w=0; w<$((width+1)); w++)); do
      curs_goto $((x+w)) $((y+h))
      if [[ $h -eq 0 || $h -eq $height ]]; then
        echo -e "$horz"
      elif [[ $w -eq 0 || $w -eq $width ]]; then
        echo -e "$vert"
      else
        echo -e " "
      fi
    done
  done
  # TOP LEFT
  curs_goto $x $y
  echo -e $tl
  # TOP RIGHT
  curs_goto $((x+width)) $y
  echo -e $tr
  # BOTTOM LEFT
  curs_goto $x $((y+height))
  echo -e $bl
  # BOTTOM RIGHT
  curs_goto $((x+width)) $((y+height))
  echo -e $br
  echo -e $RST
}

draw_text() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local text="$3"
  curs_goto $x $y
  echo -e $text
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

center_pos() {
  local x="$1" ## Reversed because of LINES(y) COLUMNS(x)
  local y="$2" ## Top left is origin
  local width="$3"
  local height="$4"
  local center_x=$(((width/2)+x))
  local center_y=$(((height/2)+y))
  curs_goto $center_x $center_y
}
