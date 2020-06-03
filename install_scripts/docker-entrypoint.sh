#!/bin/bash
# vim: set noswapfile :

main() {
  case "$1" in
    run)
      sudo chgrp -R video /dev/dri
      emulationstation
      ;;
    help)
      cat /README.md
      ;;
    *)
      exec "$@"
      ;;
  esac
}

main "$@"
