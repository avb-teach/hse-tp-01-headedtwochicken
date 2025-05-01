#!/bin/bash
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
fi

has_max=false
max_depth=0
args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --max_depth)
      has_max=true
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
    local fname="$1" dir="$2" count=1
    local base="${fname%.*}" ext="${fname##*.}"
    while [ -e "$dir/$fname" ]; do
        fname="${base}${count}.${ext}"
        count=$((count + 1))
    done
    echo "$fname"
}

find "$input_dir" -type f | while read -r file; do
    rel="${file#$input_dir/}"
    IFS='/' read -ra parts <<< "$rel"
    fileName="${parts[-1]}"
    dir_count=$(( ${#parts[@]} - 1 ))

    if [ "$has_max" = true ] && [ "$max_depth" -gt 0 ]; then
        depth_to_keep=$max_depth
        if [ "$dir_count" -lt "$max_depth" ]; then
            depth_to_keep=$dir_count
        fi
        subdirs=()
        for ((i=0; i<depth_to_keep; i++)); do
            subdirs+=("${parts[i]}")
        done
        subpath=$(IFS=/; echo "${subdirs[*]}")
        dest_dir="$output_dir/$subpath"
    else
        dest_dir="$output_dir"
    fi

    mkdir -p "$dest_dir"
    fname="$fileName"
    newName=$(rename_if_exists "$fname" "$dest_dir")
    cp "$file" "$dest_dir/$newName"
done