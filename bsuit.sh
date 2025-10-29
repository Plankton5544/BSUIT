#!/bin/bash
source components/core.sh
source components/draw.sh
source components/style.sh
# GLOBAL VARS
# 0=TRUE 1+=FALSE
# AUTHOR: Plankton5544
# Origin: October Tue 14
# Last Edit: 7:50 PM Oct 28
#
#

ui_init
ui_error_check $COLUMNS
ui_error_check $LINES
trap 'ui_exit' EXIT #Ensures Proper exiting even if killed early
draw_menu 20 20 "#==FRUITS==#" "Banana" "Apple" "Orange"
ui_wait 2
# Could expand of repeatability?
draw_menu 20 20 "#==FRUITS==#" "Banana" "Apple" "Orange"
ui_wait 2
draw_menu 20 20 "#==FRUITS==#" "Banana" "Apple" "Orange"
ui_wait 2
draw_menu 20 20 "#==FRUITS==#" "Banana" "Apple" "Orange"
ui_wait 2
draw_menu 20 20 "#==FRUITS==#" "Banana" "Apple" "Orange"
ui_wait 2
draw_menu 20 20 "#==FRUITS==#" "Banana" "Apple" "Orange"
ui_wait 2

ui_exit
