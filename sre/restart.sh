#!/bin/sh

# grep for more than 2 occurrences of the error
# if we find it, then restart the container

if [ $(grep "ERROR Database Connection Pool Empty" /app/golang.log | wc -l) -gt 2 ]; then
  exit 1
else
  exit 0
fi
