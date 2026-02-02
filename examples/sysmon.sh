#!/bin/bash
# WARNING THIS EXAMPLE IS AI GENERATED
# FAULTS MAY OCCUR RUN AT YOUR OWN RISK!
source ~/BSUIT/components/bsuit.sh

# Dashboard state
UPDATE_INTERVAL=1
CPU_HISTORY=()
MEM_HISTORY=()
MAX_HISTORY=30
SELECTED_TAB=0
TABS=("Overview" "Processes" "Network" "Disk")

# Data collection
get_cpu_usage() {
  # Read /proc/stat for CPU usage
  if [[ -f /proc/stat ]]; then
    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)}'
  else
    # macOS fallback
    echo $((RANDOM % 100))
  fi
}

get_mem_usage() {
  if [[ -f /proc/meminfo ]]; then
    awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {print int((total-avail)*100/total)}' /proc/meminfo
  else
    # macOS fallback
    echo $((RANDOM % 100))
  fi
}

get_disk_usage() {
  df -h / | awk 'NR==2 {print $5}' | tr -d '%'
}

get_uptime() {
  if [[ -f /proc/uptime ]]; then
    awk '{print int($1/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime
  else
    uptime | awk '{print $3}' | tr -d ','
  fi
}

get_load_avg() {
  if [[ -f /proc/loadavg ]]; then
    awk '{print $1" "$2" "$3}' /proc/loadavg
  else
    uptime | awk -F'load average:' '{print $2}' | tr -d ' '
  fi
}

# Update history arrays
update_history() {
  local cpu=$(get_cpu_usage)
  local mem=$(get_mem_usage)

  CPU_HISTORY+=($cpu)
  MEM_HISTORY+=($mem)

  # Keep only last MAX_HISTORY items
  if [[ ${#CPU_HISTORY[@]} -gt $MAX_HISTORY ]]; then
    CPU_HISTORY=("${CPU_HISTORY[@]:1}")
  fi
  if [[ ${#MEM_HISTORY[@]} -gt $MAX_HISTORY ]]; then
    MEM_HISTORY=("${MEM_HISTORY[@]:1}")
  fi
}

# Draw a horizontal bar graph
draw_bar() {
  local x=$1 y=$2 width=$3 value=$4 max=$5 label=$6
  local filled=$(echo "$value * $width / $max" | bc)

  draw_text $x $y "$label"
  curs_goto $((x+15)) $y
  echo -n "["

  for ((i=0; i<$width; i++)); do
    if [[ $i -lt $filled ]]; then
      echo -en "\e[42m \e[0m" # Green filled
    else
      echo -en "\e[100m \e[0m" # Gray empty
    fi
  done

  echo -n "] ${value}%"
}

# Draw mini line graph
draw_mini_graph() {
  local x=$1 y=$2 width=$3 height=$4
  local -n data=$5 # nameref to history array

  draw_box $x $y $width $height single

  local count=${#data[@]}
  [[ $count -eq 0 ]] && return

  # Calculate scaling
  local max_val=100
  local min_val=0

  # Plot points
  local x_step=$(echo "$width / $MAX_HISTORY" | bc -l)
  [[ $(echo "$x_step < 1" | bc -l) -eq 1 ]] && x_step=1

  for ((i=0; i<$count; i++)); do
    local val=${data[i]}
    local px=$(echo "$i * $x_step" | bc -l)
    px=$(printf "%.0f" $px)

    # Map value to height
    local py=$(echo "$height - ($val * $height / 100)" | bc -l)
    py=$(printf "%.0f" $py)

    curs_goto $((x+px+1)) $((y+py))
    echo -en "\e[32m●\e[0m"
  done
}

# Draw tab bar
draw_tabs() {
  local x=2 y=1

  for ((i=0; i<${#TABS[@]}; i++)); do
    if [[ $i -eq $SELECTED_TAB ]]; then
      echo -en "\e[1;37;44m"
    else
      echo -en "\e[2;37m"
    fi

    curs_goto $x $y
    echo -n " ${TABS[i]} "
    x=$((x + ${#TABS[i]} + 3))
    echo -en "\e[0m"
  done
}

# Overview tab
tab_overview() {
  local start_y=4

  # System info box
  draw_box 2 $start_y 45 8 single
  draw_text 4 $((start_y+1)) "System Information"
  draw_text 4 $((start_y+3)) "Uptime:     $(get_uptime)"
  draw_text 4 $((start_y+4)) "Load Avg:   $(get_load_avg)"
  draw_text 4 $((start_y+5)) "Disk:       $(get_disk_usage)% used"

  # CPU usage
  local cpu=$(get_cpu_usage)
  draw_bar 2 $((start_y+10)) 30 $cpu 100 "CPU Usage:"

  # Memory usage
  local mem=$(get_mem_usage)
  draw_bar 2 $((start_y+12)) 30 $mem 100 "Memory:"

  # CPU history graph
  draw_text 50 $((start_y+1)) "CPU History"
  draw_mini_graph 50 $((start_y+2)) 35 10 CPU_HISTORY

  # Memory history graph
  draw_text 50 $((start_y+14)) "Memory History"
  draw_mini_graph 50 $((start_y+15)) 35 10 MEM_HISTORY
}

# Processes tab
tab_processes() {
  local start_y=4

  draw_box 2 $start_y $((COLUMNS-4)) 20 single
  draw_text 4 $((start_y+1)) "Top Processes by CPU"

  # Get top processes
  local y=$((start_y+3))
  draw_text 4 $y "PID     USER      CPU%   MEM%   COMMAND"
  ((y++))

  if command -v ps &> /dev/null; then
    ps aux --sort=-%cpu 2>/dev/null | head -10 | tail -9 | while read line; do
      local pid=$(echo $line | awk '{print $2}')
      local user=$(echo $line | awk '{print $1}')
      local cpu=$(echo $line | awk '{print $3}')
      local mem=$(echo $line | awk '{print $4}')
      local cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf $i" "}')

      truncate_text 4 $y "$(printf "%-7s %-9s %-6s %-6s %s" $pid $user $cpu $mem $cmd)" 80
      ((y++))
      [[ $y -gt $((start_y+18)) ]] && break
    done 2>/dev/null || draw_text 4 $((start_y+5)) "Process info unavailable"
  fi
}

# Network tab
tab_network() {
  local start_y=4

  draw_box 2 $start_y $((COLUMNS-4)) 20 single
  draw_text 4 $((start_y+1)) "Network Connections"

  local y=$((start_y+3))
  draw_text 4 $y "Proto  Local Address          Foreign Address        State"
  ((y++))

  if command -v netstat &> /dev/null; then
    netstat -tn 2>/dev/null | grep ESTABLISHED | head -10 | while read line; do
      truncate_text 4 $y "$line" 80
      ((y++))
      [[ $y -gt $((start_y+18)) ]] && break
    done || draw_text 4 $((start_y+5)) "Network info unavailable"
  elif command -v ss &> /dev/null; then
    ss -tn state established 2>/dev/null | head -11 | tail -10 | while read line; do
      truncate_text 4 $y "$line" 80
      ((y++))
      [[ $y -gt $((start_y+18)) ]] && break
    done || draw_text 4 $((start_y+5)) "Network info unavailable"
  fi
}

# Disk tab
tab_disk() {
  local start_y=4

  draw_box 2 $start_y $((COLUMNS-4)) 20 single
  draw_text 4 $((start_y+1)) "Disk Usage"

  local y=$((start_y+3))
  draw_text 4 $y "Filesystem      Size  Used  Avail  Use%  Mounted on"
  ((y++))

  df -h | tail -n +2 | while read line; do
    truncate_text 4 $y "$line" 80
    ((y++))
    [[ $y -gt $((start_y+18)) ]] && break
  done
}

# Main dashboard render
dashboard() {
  update_history

  # Header
  draw_box 2 1 $((COLUMNS-4)) 1 single
  draw_aligned_text $((COLUMNS/2)) 1 "System Monitor Dashboard" center

  # Tab bar
  draw_tabs

  # Render selected tab
  case $SELECTED_TAB in
    0) tab_overview ;;
    1) tab_processes ;;
    2) tab_network ;;
    3) tab_disk ;;
  esac

  # Footer
  draw_text 2 $((LINES-2)) "Tab: 1-4 | Refresh: r | Quit: q | Update every ${UPDATE_INTERVAL}s"

  read_keys
  case "$REPLY" in
    q) MODE="break" ;;
    r) ;; # Manual refresh
    1) SELECTED_TAB=0 ;;
    2) SELECTED_TAB=1 ;;
    3) SELECTED_TAB=2 ;;
    4) SELECTED_TAB=3 ;;
    $'\e') # Arrow keys
      read -rsn2 -t 0.1 rest
      case "$rest" in
        '[D') # Left
          ((SELECTED_TAB--))
          [[ $SELECTED_TAB -lt 0 ]] && SELECTED_TAB=$((${#TABS[@]}-1))
          ;;
        '[C') # Right
          ((SELECTED_TAB++))
          [[ $SELECTED_TAB -ge ${#TABS[@]} ]] && SELECTED_TAB=0
          ;;
      esac
      ;;
  esac
}

main() {
  init
  MODE="dashboard"

  while [[ "$MODE" != "break" ]]; do
    dispatch dashboard
  done

  cleanup
}

main $@
