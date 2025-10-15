#!/bin/bash
source components/core.sh
source components/draw.sh
source components/style.sh
# GLOBAL VARS
# 0=TRUE 1+=FALSE 
# AUTHOR: Plankton5544
# Origin: October Tue 14 
# Last Edit: 7:55 PM
#
# 

ui_init
trap 'ui_exit' EXIT #Ensures Proper exiting even if killed early
draw_box 4 4 10 50 
ui_cursor move 
draw_menu 25 7 "TITLE" "Banana" "Apple" "Orange"

sleep 5
ui_exit
