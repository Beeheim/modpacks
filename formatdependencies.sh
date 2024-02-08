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

build_download_url() {
  local input_file=$1
  local base_url="https://valheim.thunderstore.io/package/"
  while IFS='-' read -rA ADDR || [[ -n "${ADDR[*]}" ]]; do
    if [[ ${#ADDR[@]} -ge 3 ]]; then
      local author="${ADDR[1]}"
      local mod_title="${ADDR[2]}"
      local mod_version="${ADDR[3]}"
      local url="${base_url}${author}/${mod_title}/${mod_version}/"
      local msg="- [${mod_title}](<${url}>)"
      echo "$msg"
    fi
  done <"$input_file"
}

pretty_print_dependencies() {
  local input_file=$1
  while IFS='-' read -rA ADDR || [[ -n "${ADDR[*]}" ]]; do
    if [[ ${#ADDR[@]} -ge 3 ]]; then
      echo "- *Mod:* \`${ADDR[2]}\`, *Ver:* \`${ADDR[3]}\`"
    fi
  done <"$input_file"
}

main() {
  local arg=$1
  if [[ "$arg" == "json" ]]; then
    json_dependencies $2 > dependencies.json
  elif [[ "$arg" == "pretty" ]]; then
    pretty_print_dependencies $2 > dependencies.md
  elif [[ "$arg" == "url" ]]; then
    build_download_url $2 > urls.md
  elif [[ "$arg" == "all" ]]; then
    build_download_url $2 > urls.md
    json_dependencies $2 > dependencies.json
    pretty_print_dependencies $2 > dependencies.md
  fi
}

main $1 $2

