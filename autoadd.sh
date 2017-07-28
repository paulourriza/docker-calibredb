#!/bin/bash
LOCK_FILE="${CALIBREDB_IMPORT_DIRECTORY}/add.lock"
inotifywait -r -m -e moved_to -e create -e delete --format '%e %f' "${CALIBREDB_IMPORT_DIRECTORY}" |
  while read action file; do
    echo "${file} - ${action}"
    if [ "$action" = "DELETE" ] && [ "$file" = "add.lock" ]; then
      echo "add.lock was removed"
      /opt/calibre/calibredb add "${CALIBREDB_IMPORT_DIRECTORY}" -r --with-library $CALIBRE_LIBRARY_DIRECTORY && rm -rf $CALIBREDB_IMPORT_DIRECTORY/*
      /usr/bin/mobilize.py
    else
      if [ "$file" != "add.lock" ] && [ "$action" != "DELETE" ] && [ "$action" != "DELETE,ISDIR" ]; then
        if [[ ! -e $LOCK_FILE ]]; then
          (touch $LOCK_FILE; sleep 30; rm $LOCK_FILE) &
          echo "add.lock was created for 30 sec"
        fi
      fi
    fi
  done
