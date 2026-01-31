#!/bin/bash
source ~/BSUIT/components/bsuit.sh

leader() {
  header
  subber "(q) to QUIT (1) to Base"

  read_keys 0.75
  case "$REPLY" in
    "q") Mode="break"  ;;
    "1") Mode="base" ;;
  esac
}

main() {
  init

  while [[ "$Mode" != "break" ]]; do
    dispatch base leader
  done

  cleanup
}

main $@
