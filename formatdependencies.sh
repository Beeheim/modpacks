#!/bin/bash

json_dependencies() {
  local input_file=$1
  local last_line=$(tail -n 1 "$input_file")
  echo "["
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -n "$line" ]]; then
      if [[ "$line" != "$last_line" ]]; then
        echo "\"$line\", "
      else
        echo "\"$line\""
      fi
    fi
  done <"$input_file"
  echo -n "]"
}

pretty_print_dependencies() {
  local input_file=$1
  while IFS='-' read -rA ADDR || [[ -n "${ADDR[*]}" ]]; do
    if [[ ${#ADDR[@]} -ge 3 ]]; then
      echo " - Mod: ${ADDR[2]}, Ver: ${ADDR[3]}"
    fi
  done <"$input_file"
}

main() {
  local arg=$1
  if [[ "$arg" == "json" ]]; then
    json_dependencies $2
  elif [[ "$arg" == "pretty" ]]; then
    pretty_print_dependencies $2
  fi
}

main $1 $2
