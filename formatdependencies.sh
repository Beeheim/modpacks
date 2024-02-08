#!/bin/zsh

json_dependencies() {
  local input_file=$1
  local last_line=$(tail -n 1 "$input_file")
  local str="[\n"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | tr -d '\r') # Remove carriage return characters
    if [[ -n "$line" ]]; then
      if [[ "$line" != "$last_line" ]]; then
        str+="\"$line\",\n"
      else
        str+="\"$line\"\n"
      fi
    fi
  done <"$input_file"
  str+="]"
  echo $str
}

build_download_url() {
  local md_output=$(mktemp)
  local input_file=$1
  local base_url="https://valheim.thunderstore.io/package/"
  while IFS='-' read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | tr -d '\r') # Remove carriage return characters
    if [[ -n "$line" ]]; then
      local author="${line%%-*}"
      local mod_title="${line#*-}"
      mod_title="${mod_title%%-*}"
      local mod_version="${line##*-}"
      local url="${base_url}${author}/${mod_title}/${mod_version}/"
      local msg="- [${mod_title} Ver ${mod_version}](<${url}>)"
      printf '%s\n' "$msg" >> "$md_output"
    fi
  done <"$input_file"
  cat "$md_output"
  rm "$md_output"
}

pretty_print_dependencies() {
  local input_file=$1
  while IFS='-' read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | tr -d '\r') # Remove carriage return characters
    if [[ -n "$line" ]]; then
      IFS='-' read -rA ADDR <<< "$line"
      if [[ ${#ADDR[@]} -ge 3 ]]; then
        echo "- *Mod:* \`${ADDR[1]}\`, *Ver:* \`${ADDR[2]}\`"
      fi
    fi
  done <"$input_file"
}

main() {
  local arg=$1
  if [[ "$arg" == "json" ]]; then
    json_dependencies $2 >& dependencies.json
  elif [[ "$arg" == "pretty" ]]; then
    pretty_print_dependencies $2 > dependencies.md
  elif [[ "$arg" == "url" ]]; then
    build_download_url $2 > urls.md
  elif [[ "$arg" == "all" ]]; then
    build_download_url $2 >& urls.md
    json_dependencies $2 >& dependencies.json
    pretty_print_dependencies $2 >& dependencies.md
  fi
}

main $1 $2

