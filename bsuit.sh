#!/bin/bash
source components/core.sh
source components/draw.sh
source components/style.sh
# GLOBAL VARS
# 0=TRUE 1+=FALSE
# AUTHOR: Plankton5544
# Origin: October Tue 14
# Last Edit: 8:34 PM Oct 27
#
#

ui_init
trap 'ui_exit' EXIT #Ensures Proper exiting even if killed early
draw_menu 20 20 "#==TITLE==#" "Banana" "Apple" "Orange"
ui_wait 5 1
sleep 1
draw_menu 20 20 "#==TITLE==#" "Banana" "Apple" "Orange"
sleep 1


ui_exit
