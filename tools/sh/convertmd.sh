#!/bin/bash

#################################################
# convert markdown with image for mermaid section
# author: zhanghao
# date: 2024/12/24
# version: 1.0
#################################################

function usage() {
  echo "Usage:  convertmd [markdown file]"
  echo "Convert markdown files with image for mermaid section"
  echo "If no markdown file is provided, all markdown files in the current directory will be converted."
}

function check_dependencies() {
  for cmd in "$@"; do
    which "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is not installed. Please install it before running this script."; exit 1; }
  done
}

function convertmd_with_image() {
  check_dependencies mmdc node dos2unix
  ls -d convert > /dev/null 2>&1 || mkdir convert
  if [[ $# -eq 0 ]]; then
    cp *.md convert
  else
    cp "$1" convert
  fi
  cd convert && dos2unix *.md && rm -rf *.png

  # Loop through each Markdown file in the current directory
  for file in *.md; do
    local counter=0
    # Extract mermaid code blocks and convert them to images
    sed -n '/```mermaid/,/```/p' "$file" | while read -r line; do
      if [[ $line == '```mermaid' ]]; then
        local mermaid=""
      elif [[ $line == '```' ]]; then
        # Generate a unique filename for each diagram
        local filename="${file%.md}_$((counter++)).png"
        echo -e "${mermaid}" | mmdc -i - -o "$filename"
      else
        mermaid="${mermaid}\n${line}"
      fi
    done
    # Check if any PNG files were generated
    if ls *.png >/dev/null 2>&1; then
      # Replace the mermaid code block with the image link in the markdown file
      sed -i '/```mermaid/,/```/c\\![mermaid diagram](?)' $file
      lines=($(grep -n '\!\[mermaid diagram\](?)' $file | cut -d: -f1))
      counter=0
      for line in "${lines[@]}"; do
        sed -i "${line}s/(?)/(test_$((counter++))).png/" $file
      done
    fi
  done
}

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi
convertmd_with_image $@