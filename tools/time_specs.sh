#!/bin/bash

for i in `/bin/ls spec/*spec.rb`; do
  /usr/bin/time -f "%E" rspec -c -fd -I. -Ispec $i > /dev/null 2>/tmp/jbl_time.txt
  ELAPSED=`cat /tmp/jbl_time.txt`; echo "$ELAPSED $i"
  rm /tmp/jbl_time.txt
done
