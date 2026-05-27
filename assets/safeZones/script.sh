#!/bin/bash
echo "{" > index.json
first=true
for dir in */; do
  id="${dir%/}"
  # Salta se non è un numero
  [[ ! "$id" =~ ^[0-9]+$ ]] && continue
  
  files=$(ls "$dir"*.jpeg 2>/dev/null | xargs -I{} basename {} | \
    awk '{print "\""$0"\""}' | paste -sd, -)
  
  [ -z "$files" ] && continue
  [ "$first" = false ] && echo "," >> index.json
  echo "  \"$id\": [$files]" >> index.json
  first=false
done
echo "}" >> index.json
