#!/bin/bash
# источник: https://www.geeksforgeeks.org/how-to-pass-and-parse-linux-bash-script-arguments-and-parameters/  
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
# источник: https://linuxize.com/post/bash-case-statement/  

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
    # источник: https://askubuntu.com/questions/538913/how-can-i-copy-files-with-duplicate-filenames-into-one-directory-and-retain-both  
    while [ -e "$dir/$fileName" ]; do
        fileName="${base}${count}.${ext}"
        count=$((count+1))
    done
    echo "$fileName"
}

# источник: https://www.baeldung.com/linux/flattening-nested-directory  
find "$input_dir" -type f | while read -r file; do
    rel_path="${file#$input_dir/}"
    dir_path=$(dirname "$rel_path")
    depth=$(grep -o "/" <<< "$dir_path" | wc -l)
    if (( depth > max_depth )); then
        continue
    fi

    # источник: https://stackoverflow.com/questions/33469292/how-do-i-flatten-a-single-level-of-directories-in-a-shell-command  
    name=$(basename "$file")

    newName=$(rename_if_exists "$name" "$output_dir")
    cp "$file" "$output_dir/$newName"
done