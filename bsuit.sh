#!/bin/bash
source ~/BSUIT/components/core.sh

main() {
  COLUMNS="$1"
  LINES="$2"
  MODE="TEST"
  RUNNING="true"

  curs_vis hide
  while [[ "$RUNNING" == "true" ]]; do
    key=$(read_key timed 0.25)
    render $key
    update $key
  done
  curs_vis
}
main "$1" "$2"
