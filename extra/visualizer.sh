#!/bin/bash
# WARNING THIS EXAMPLE IS AI GENERATED
# FAULTS MAY OCCUR RUN AT YOUR OWN RISK!
source ~/BSUIT/components/bsuit.sh
file="$1"

# Graph state
GRAPH_X=5
GRAPH_Y=5
GRAPH_WIDTH=60
GRAPH_HEIGHT=20
SCALE_MODE="auto" # auto or manual
Y_MIN=0
Y_MAX=100
SHOW_GRID=1
SHOW_VALUES=1
CURRENT_DATASET=0

header() {
  draw_box 2 1 $((COLUMNS-4)) 3 single
  draw_text 4 2 "CSV Graph Visualizer - $file"
}

footer() {
  draw_text 4 $((LINES-2)) "q=quit | g=toggle grid | v=toggle values | left/right=dataset | +/-=zoom"
}

if [[ -z $file ]]; then
    echo "Error: No file specified" >&2
    echo "Usage: $0 [COLUMNS] [LINES] [CSV_FILE]" >&2
    exit 1
fi

if [[ ! -f $file ]]; then
    echo "Error: File '$file' does not exist" >&2
    exit 1
fi

# Parse CSV into datasets
# Supports multiple rows (each row is a dataset)
store_csv() {
  local file="$1"
  local row=0
  datasets=()
  dataset_lengths=()

  while IFS=',' read -r -a fields; do
    # Skip empty lines
    [[ ${#fields[@]} -eq 0 ]] && continue

    # Store each row as a separate dataset
    local dataset_name="dataset_${row}"
    eval "${dataset_name}=()"

    for value in "${fields[@]}"; do
      # Remove whitespace and validate numeric
      value=$(echo "$value" | tr -d ' ')
      if [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
        eval "${dataset_name}+=($value)"
      fi
    done

    # Store dataset info
    local count=$(eval "echo \${#${dataset_name}[@]}")
    if [[ $count -gt 0 ]]; then
      datasets+=("$dataset_name")
      dataset_lengths+=($count)
      ((row++))
    fi
  done < "$file"

  unset IFS
}

# Calculate min/max for auto-scaling
calc_bounds() {
  local dataset_name="${datasets[$CURRENT_DATASET]}"
  local values=($(eval "echo \${${dataset_name}[@]}"))

  Y_MIN=${values[0]}
  Y_MAX=${values[0]}

  for val in "${values[@]}"; do
    if (( $(echo "$val < $Y_MIN" | bc -l) )); then
      Y_MIN=$val
    fi
    if (( $(echo "$val > $Y_MAX" | bc -l) )); then
      Y_MAX=$val
    fi
  done

  # Add padding (10%)
  local range=$(echo "$Y_MAX - $Y_MIN" | bc -l)
  local padding=$(echo "$range * 0.1" | bc -l)
  Y_MIN=$(echo "$Y_MIN - $padding" | bc -l)
  Y_MAX=$(echo "$Y_MAX + $padding" | bc -l)

  # Handle flat data
  if (( $(echo "$range == 0" | bc -l) )); then
    Y_MIN=$(echo "$Y_MIN - 1" | bc -l)
    Y_MAX=$(echo "$Y_MAX + 1" | bc -l)
  fi
}

# Map value to Y coordinate
map_to_y() {
  local value=$1
  local range=$(echo "$Y_MAX - $Y_MIN" | bc -l)
  local normalized=$(echo "($value - $Y_MIN) / $range" | bc -l)
  local y=$(echo "$GRAPH_HEIGHT - ($normalized * $GRAPH_HEIGHT)" | bc -l)
  printf "%.0f" $y
}

# Draw the graph axes and grid
draw_graph_frame() {
  # Main graph box
  draw_box $GRAPH_X $GRAPH_Y $GRAPH_WIDTH $GRAPH_HEIGHT single

  # Y-axis labels
  draw_text $((GRAPH_X-8)) $GRAPH_Y "$(printf "%.2f" $Y_MAX)"
  draw_text $((GRAPH_X-8)) $((GRAPH_Y+GRAPH_HEIGHT/2)) "$(printf "%.2f" $(echo "($Y_MAX+$Y_MIN)/2" | bc -l))"
  draw_text $((GRAPH_X-8)) $((GRAPH_Y+GRAPH_HEIGHT)) "$(printf "%.2f" $Y_MIN)"

  # Grid lines
  if [[ $SHOW_GRID -eq 1 ]]; then
    for ((i=1; i<$GRAPH_HEIGHT; i+=4)); do
      for ((j=1; j<$GRAPH_WIDTH; j++)); do
        curs_goto $((GRAPH_X+j)) $((GRAPH_Y+i))
        echo -n "·"
      done
    done
  fi
}

# Draw the line graph
draw_line_graph() {
  local dataset_name="${datasets[$CURRENT_DATASET]}"
  local values=($(eval "echo \${${dataset_name}[@]}"))
  local count=${#values[@]}

  [[ $count -eq 0 ]] && return

  # Calculate x spacing
  local x_step=$(echo "$GRAPH_WIDTH / $count" | bc -l)
  [[ $(echo "$x_step < 1" | bc -l) -eq 1 ]] && x_step=1

  local prev_x=0
  local prev_y=0

  for ((i=0; i<$count; i++)); do
    local value=${values[i]}
    local x=$(echo "$i * $x_step" | bc -l)
    x=$(printf "%.0f" $x)
    local y=$(map_to_y $value)

    # Draw point
    curs_goto $((GRAPH_X+x+1)) $((GRAPH_Y+y))
    echo -en "\e[1;32m●\e[0m"

    # Draw line from previous point
    if [[ $i -gt 0 ]]; then
      draw_line_segment $prev_x $prev_y $x $y
    fi

    # Show value labels
    if [[ $SHOW_VALUES -eq 1 && $(($i % 3)) -eq 0 ]]; then
      curs_goto $((GRAPH_X+x+1)) $((GRAPH_Y+y-1))
      echo -en "\e[36m$(printf "%.1f" $value)\e[0m"
    fi

    prev_x=$x
    prev_y=$y
  done

  # X-axis labels
  draw_text $((GRAPH_X+1)) $((GRAPH_Y+GRAPH_HEIGHT+1)) "0"
  draw_text $((GRAPH_X+GRAPH_WIDTH/2)) $((GRAPH_Y+GRAPH_HEIGHT+1)) "$((count/2))"
  draw_text $((GRAPH_X+GRAPH_WIDTH-5)) $((GRAPH_Y+GRAPH_HEIGHT+1)) "$count"
}

# Draw a line segment between two points (simple Bresenham-like)
draw_line_segment() {
  local x1=$1 y1=$2 x2=$3 y2=$4

  local dx=$((x2 - x1))
  local dy=$((y2 - y1))

  # Determine number of steps
  local steps=$((dx > dy ? dx : dy))
  [[ $steps -lt 0 ]] && steps=$((-steps))
  [[ $steps -eq 0 ]] && steps=1

  local x_inc=$(echo "$dx / $steps" | bc -l)
  local y_inc=$(echo "$dy / $steps" | bc -l)

  local x=$x1
  local y=$y1

  for ((s=0; s<$steps; s++)); do
    curs_goto $((GRAPH_X+$(printf "%.0f" $x)+1)) $((GRAPH_Y+$(printf "%.0f" $y)))
    echo -en "\e[32m─\e[0m"
    x=$(echo "$x + $x_inc" | bc -l)
    y=$(echo "$y + $y_inc" | bc -l)
  done
}

# Info panel
draw_info() {
  local info_x=$((GRAPH_X+GRAPH_WIDTH+5))
  local info_y=$GRAPH_Y

  draw_box $info_x $info_y 25 15 single

  draw_text $((info_x+2)) $((info_y+1)) "Dataset Info"
  draw_text $((info_x+2)) $((info_y+3)) "Current: $((CURRENT_DATASET+1))/${#datasets[@]}"

  local dataset_name="${datasets[$CURRENT_DATASET]}"
  local count=$(eval "echo \${#${dataset_name}[@]}")
  draw_text $((info_x+2)) $((info_y+4)) "Points: $count"

  draw_text $((info_x+2)) $((info_y+6)) "Y Range:"
  draw_text $((info_x+2)) $((info_y+7)) "Min: $(printf "%.2f" $Y_MIN)"
  draw_text $((info_x+2)) $((info_y+8)) "Max: $(printf "%.2f" $Y_MAX)"

  draw_text $((info_x+2)) $((info_y+10)) "Grid: $([[ $SHOW_GRID -eq 1 ]] && echo "ON" || echo "OFF")"
  draw_text $((info_x+2)) $((info_y+11)) "Values: $([[ $SHOW_VALUES -eq 1 ]] && echo "ON" || echo "OFF")"
}

graph() {
  calc_bounds
  header
  draw_graph_frame
  draw_line_graph
  draw_info
  footer

  read_keys 2.5
  case "$REPLY" in
    q) Mode="break" ;;
    g) SHOW_GRID=$((1-SHOW_GRID)) ;;
    v) SHOW_VALUES=$((1-SHOW_VALUES)) ;;
    '[D') # Left arrow
      ((CURRENT_DATASET--))
      [[ $CURRENT_DATASET -lt 0 ]] && CURRENT_DATASET=$((${#datasets[@]}-1)) ;;
      '[C') # Right arrow
        ((CURRENT_DATASET++))
        [[ $CURRENT_DATASET -ge ${#datasets[@]} ]] && CURRENT_DATASET=0 ;;
    '+') # Zoom in
      local range=$(echo "$Y_MAX - $Y_MIN" | bc -l)
      Y_MIN=$(echo "$Y_MIN + $range * 0.1" | bc -l)
      Y_MAX=$(echo "$Y_MAX - $range * 0.1" | bc -l)
      ;;
    '-') # Zoom out
      local range=$(echo "$Y_MAX - $Y_MIN" | bc -l)
      Y_MIN=$(echo "$Y_MIN - $range * 0.1" | bc -l)
      Y_MAX=$(echo "$Y_MAX + $range * 0.1" | bc -l)
      ;;
  esac
}

main() {

  # Check if bc is available
  if ! hush bc; then
    echo "Error: 'bc' is required but not installed" >&2
    exit 1
  fi

  store_csv "$file"

  if [[ ${#datasets[@]} -eq 0 ]]; then
    echo "Error: No valid numeric data found in CSV" >&2
    exit 1
  fi

  init
  Mode="graph"

  while [[ "$Mode" != "break" ]]; do
    dispatch graph
  done

  cleanup
}

main $@
