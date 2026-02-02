#!/bin/bash
source ~/BSUIT/components/bsuit.sh

leader() {
  header
  subber "(q) to QUIT (1) to BASE"

  #spinner 10 10 $STATE
  #if [[ $STATE -lt 8 ]]; then
  #  STATE=$((STATE+1))
  #else
  #  STATE=1
  #fi

  read_keys 0.1
  case $REPLY in
    'q') MODE="break" ;;
    '1') MODE="BASE" ;;
  esac
}

main() {
  init

  while [[ "$MODE" != "break" ]]; do
    dispatch BASE leader
  done

  cleanup
}

main $@
