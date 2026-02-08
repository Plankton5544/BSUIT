#!/bin/bash
source ~/BSUIT/components/bsuit.sh

leader() {

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
