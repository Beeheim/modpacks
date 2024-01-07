#!/bin/bash

echo "["
while IFS= read -r line || [[ -n "$line" ]]
do
 if [[ -n "$line" ]]; then
   echo "\"$line\","
 fi
done < "$1"
echo "]"