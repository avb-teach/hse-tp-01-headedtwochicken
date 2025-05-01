#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
fi

max_depth=9999
args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --max_depth)
      max_depth="$2"
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

input_dir="${args[0]}"
output_dir="${args[1]}"

if [ ! -d "$input_dir" ]; then
    echo "Error: input directory doesn't exist"
    exit 1
fi
mkdir -p "$output_dir"

rename_if_exists() {
    local fileName="$1" dir="$2" count=1
    local base="${fileName%.*}" ext="${fileName##*.}"
    if [[ "$base" == "$ext" ]]; then
        ext=""
    else
        ext=".$ext"
    fi
    while [ -e "$dir/$fileName" ]; do
        fileName="${base}${count}${ext}"
        count=$((count + 1))
    done
    echo "$fileName"
}

find "$input_dir" -type f | while read -r file; do
    rel="${file#$input_dir/}"
    IFS='/' read -ra parts <<< "$rel"
    fileName="${parts[-1]}"
    dir_count=$(( ${#parts[@]} - 1 ))

    if (( dir_count > max_depth )); then
        start=$(( dir_count_