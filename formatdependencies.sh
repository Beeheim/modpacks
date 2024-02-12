#!/bin/zsh

convert_to_json_array() {
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

generate_markdown_links() {
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
      local msg="- [${mod_title} Ver ${mod_version}](${url})"
      printf '%s\n' "$msg" >> "$md_output"
    fi
  done <"$input_file"
  cat "$md_output"
  rm "$md_output"
}

generate_markdown_list() {
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
    convert_to_json_array $2 >& array.json
  elif [[ "$arg" == "pretty" ]]; then
    generate_markdown_list $2 > list.md
  elif [[ "$arg" == "url" ]]; then
    generate_markdown_links $2 > urls.md
  elif [[ "$arg" == "all" ]]; then
    generate_markdown_links $2 > urls.md
    convert_to_json_array $2 > array.json
    generate_markdown_list $2 > list.md
  fi
}

main $1 $2

