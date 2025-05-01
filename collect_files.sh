#!/bin/bash
# источник: https://www.geeksforgeeks.org/how-to-pass-and-parse-linux-bash-script-arguments-and-parameters/ 
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
    # источник: https://askubuntu.com/questions/538913/how-can-i-copy-files-with-duplicate-filenames-into-one-directory-and-retain-both 
    while [ -e "$dir/$fname" ]; do
        fname="${base}${count}.${ext}"
        count=$((count + 1))
    done
    echo "$fname"
}

find "$input_dir" -type f | while read -r file; do
    if [ "$has_max" = true ]; then
        rel="${file#$input_dir/}"
        IFS='/' read -ra parts <<< "$rel"
        fileName="${parts[-1]}"
        dir_count=$(( ${#parts[@]} - 1 ))

        if (( dir_count > 0 )); then
            start=$(( dir_count - max_depth ))
            (( start < 0 )) && start=0
            subdirs=()
            for ((i=start; i<dir_count; i++)); do
                subdirs+=("${parts[i]}")
            done
            subpath=$(IFS=/; echo "${subdirs[*]}")
        else
            subpath=""
        fi

        dest_dir="$output_dir/$subpath"
    else
        fileName=$(basename "$file")
        dest_dir="$output_dir"
    fi

    mkdir -p "$dest_dir"
    if [ "$has_max" = true ]; then
        fname="$fileName"
    else
        fname=$(basename "$file")
    fi
    newName=$(rename_if_exists "$fname" "$dest_dir")
    cp "$file" "$dest_dir/$newName"
done