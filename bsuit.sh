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
temp=0

ui_init
trap 'ui_exit' EXIT #Ensures Proper exiting even if killed early
draw_menu 20 10 "#==TITLE==#" "Banana" "Apple" "Orange"
ui_wait 1 1
 

ui_exit
