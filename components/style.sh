#!/bin/bash


#===TEXT==STYLES===#
RST='\033[0m'      # Reset all
BLD='\033[1m'      # Bold
DIM='\033[2m'      # Dim
ITL='\033[3m'      # Italic
UND='\033[4m'      # Underline
BLK='\033[5m'      # Blink
REV='\033[7m'      # Reverse/Invert
HID='\033[8m'      # Hidden
STR='\033[9m'      # Strikethrough

#==Regular=Colors==#
BLK='\033[30m'     # Black
RED='\033[31m'     # Red
GRN='\033[32m'     # Green
YLW='\033[33m'     # Yellow
BLU='\033[34m'     # Blue
MAG='\033[35m'     # Magenta
CYN='\033[36m'     # Cyan
WHT='\033[37m'     # White

#==Bright==Colors==#
BBLK='\033[90m'    # Bright Black (Gray)
BRED='\033[91m'    # Bright Red
BGRN='\033[92m'    # Bright Green
BYLW='\033[93m'    # Bright Yellow
BBLU='\033[94m'    # Bright Blue
BMAG='\033[95m'    # Bright Magenta
BCYN='\033[96m'    # Bright Cyan
BWHT='\033[97m'    # Bright White

#=Regular=Backgrounds=#
BGBLK='\033[40m'   # Black background
BGRED='\033[41m'   # Red background
BGGRN='\033[42m'   # Green background
BGYLW='\033[43m'   # Yellow background
BGBLU='\033[44m'   # Blue background
BGMAG='\033[45m'   # Magenta background
BGCYN='\033[46m'   # Cyan background
BGWHT='\033[47m'   # White background

#=Bright=Backgrounds=#
BGBBLK='\033[100m' # Bright Black background
BGBRED='\033[101m' # Bright Red background
BGBGRN='\033[102m' # Bright Green background
BGBYLW='\033[103m' # Bright Yellow background
BGBBLU='\033[104m' # Bright Blue background
BGBMAG='\033[105m' # Bright Magenta background
BGBCYN='\033[106m' # Bright Cyan background
BGBWHT='\033[107m' # Bright White background

#=====Bold==Colors=====#
BLDRED='\033[1;31m'    # Bold Red
BLDGRN='\033[1;32m'    # Bold Green
BLDYLW='\033[1;33m'    # Bold Yellow
BLDBLU='\033[1;34m'    # Bold Blue
BLDMAG='\033[1;35m'    # Bold Magenta
BLDCYN='\033[1;36m'    # Bold Cyan
BLDWHT='\033[1;37m'    # Bold White

#=Uncommon==Styles=#
DBL='\033[21m'     # Double underline (not widely supported)
NRM='\033[22m'     # Normal intensity (neither bold nor dim)
Nitl='\033[23m'    # Not italic
NUND='\033[24m'    # Not underlined
NBLK='\033[25m'    # Not blinking
NREV='\033[27m'    # Not reversed
NHID='\033[28m'    # Not hidden
NSTR='\033[29m'    # Not strikethrough

#=Single=Line=Borders=#
BX_TL='┌'  # Top-left
BX_TR='┐'  # Top-right
BX_BL='└'  # Bottom-left
BX_BR='┘'  # Bottom-right
BX_H='─'   # Horizontal
BX_V='│'   # Vertical
BX_VR='├'  # Vertical right (left T)
BX_VL='┤'  # Vertical left (right T)
BX_HU='┴'  # Horizontal up (bottom T)
BX_HD='┬'  # Horizontal down (top T)
BX_CR='┼'  # Cross

#=Double=Line=Borders=#
DBX_TL='╔'  # Top-left
DBX_TR='╗'  # Top-right
DBX_BL='╚'  # Bottom-left
DBX_BR='╝'  # Bottom-right
DBX_H='═'   # Horizontal
DBX_V='║'   # Vertical
DBX_VR='╠'  # Vertical right
DBX_VL='╣'  # Vertical left
DBX_HU='╩'  # Horizontal up
DBX_HD='╦'  # Horizontal down
DBX_CR='╬'  # Cross

#=Heavy/Bold=Borders=#
HBX_TL='┏'  # Top-left
HBX_TR='┓'  # Top-right
HBX_BL='┗'  # Bottom-left
HBX_BR='┛'  # Bottom-right
HBX_H='━'   # Horizontal
HBX_V='┃'   # Vertical

#=Rounded=Corners=#
RBX_TL='╭'  # Top-left
RBX_TR='╮'  # Top-right
RBX_BL='╰'  # Bottom-left
RBX_BR='╯'  # Bottom-right

#==Full=Blocks==#
BLK_FULL='█'    # Full block
BLK_DARK='▓'    # Dark shade
BLK_MED='▒'     # Medium shade
BLK_LIGHT='░'   # Light shade

#=Partial=Block=# (vertical)
BLK_LEFT='▌'    # Left half
BLK_RIGHT='▐'   # Right half

#=Partial=Block=# (horizontal)
BLK_TOP='▀'     # Upper half
BLK_BOT='▄'     # Lower half

#=Quarter=Block=#
BLK_UL='▘'      # Upper left
BLK_UR='▝'      # Upper right
BLK_LL='▖'      # Lower left
BLK_LR='▗'      # Lower right

#====Eighths====#
BLK_1_8='▁'     # Lower 1/8
BLK_2_8='▂'     # Lower 2/8
BLK_3_8='▃'     # Lower 3/8
BLK_4_8='▄'     # Lower 4/8
BLK_5_8='▅'     # Lower 5/8
BLK_6_8='▆'     # Lower 6/8
BLK_7_8='▇'     # Lower 7/8
BLK_8_8='█'     # Full

#===Triangles===#
TRI_UP='▲'      # Up-pointing
TRI_DN='▼'      # Down-pointing
TRI_LT='◀'      # Left-pointing
TRI_RT='▶'      # Right-pointing

#=====Arrows====#
ARW_UP='↑'      # Up arrow
ARW_DN='↓'      # Down arrow
ARW_LT='←'      # Left arrow
ARW_RT='→'      # Right arrow
ARW_UD='↕'      # Up-down arrow
ARW_LR='↔'      # Left-right arrow

#=Circles=&=Dot=#
CIR_FULL='●'    # Full circle
CIR_EMPTY='○'   # Empty circle
DOT_MED='·'     # Middle dot
DOT_BUL='•'     # Bullet
SQR_FULL='■'    # Full square
SQR_EMPTY='□'   # Empty square

#=Check=&=Crosses=#
CHK='✓'         # Check mark
CRS='✗'         # Cross mark
CHK_HVY='✔'     # Heavy check
CRS_HVY='✘'     # Heavy cross

#===Spinners===#
SPIN_1='⠋'
SPIN_2='⠙'
SPIN_3='⠹'
SPIN_4='⠸'
SPIN_5='⠼'
SPIN_6='⠴'
SPIN_7='⠦'
SPIN_8='⠧'

#=Progress=Bar=#
BAR_EMPTY='▱'   # Empty bar segment
BAR_FULL='▰'    # Full bar segment

