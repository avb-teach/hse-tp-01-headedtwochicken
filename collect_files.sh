#!/bin/bash

input_dir="$1"
output_dir="$2"
max_depth=""
depth_limit=0

if [[ -z "$input_dir" || -z "$output_dir" ]]; then
  echo "Usage: ./collect_files.sh input_dir output_dir [--max_depth N]"
  exit 1
fi

if [[ "$3" == "--max_depth" && "$4" =~ ^[0-9]+$ ]]; then
  max_depth="$4"
  depth_limit=1
fi

mkdir -p "$output_dir"
declare -A name_count

collect_files() {
  local current_dir="$1"
  local current_depth="$2"

  if [[ -n "$max_depth" && "$current_depth" -gt "$max_depth" ]]; then
    return
  fi

  for path in "$current_dir"/*; do
    if [[ -f "$path" ]]; then
      filename=$(basename "$path")
      count=${name_count["$filename"]}
      if [[ -z "$count" ]]; then
        cp "$path" "$output_dir/$filename"
        name_count["$filename"]=1
      else
        name="${filename%.*}"
        ext="${filename##*.}"
        if [[ "$filename" == "$ext" ]]; then
          newname="${name}${count}"
        else
          newname="${name}${count}.${ext}"
        fi
        cp "$path" "$output_dir/$newname"
        ((name_count["$filename"]++))
      fi
    elif [[ -d "$path" ]]; then
      collect_files "$path" $((current_depth + 1))
    fi
  done
}

collect_files "$input_dir" 1