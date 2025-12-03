## This script separates YAML or text with separator "---" and output
## them as 1.....[ENDVALUE].yaml

#!/usr/bin/env bash

input_file="$1"

if [[ -z "$input_file" ]]; then
  echo "Usage: $0 <input.yaml>"
  exit 1
fi

count=0

awk -v out_prefix="output" '
  /^---[[:space:]]*$/ {
    # When encountering a separator, start a new file
    count++
    filename = count ".yaml"
    next
  }
  {
    if (count > 0) {
      print > filename
    }
  }
' "$input_file"
