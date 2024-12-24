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

  # check dependencies
  check_dependencies mmdc node dos2unix

  # copy markdown files to a new directory
  ls -d convert > /dev/null 2>&1 || mkdir convert
  rm -rf convert/*
  if [[ $# -eq 0 ]]; then
    cp *.md convert
  else
    cp "$1" convert
  fi

  # convert markdown files to unix format
  cd convert && dos2unix *.md

  # loop through each markdown file in the current directory
  for file in *.md; do
    echo "" >> $file
    blank_mermaid=()
    counter=0
    # extract mermaid code blocks and convert them to images
    while IFS= read -r line; do
      if [[ $line == '```mermaid' ]]; then
        mermaid=""
      elif [[ $line == '```' ]]; then
        echo -e "${mermaid}" | grep -Pqxz "^\n+$"
        # if the mermaid code block is empty, skip it and echo an error message
        if [[ $? -eq 0 ]]; then
          blank_mermaid+=(0)
          echo -e "\n\033[31mError: Empty mermaid code block was found in $file,like \`\`\`mermaid\`\`\`,script will not convert this empty block and continue\033[0m\n"
        else
          echo "-------------------------------------"
          blank_mermaid+=(1)
          # generate a unique filename for each diagram
          filename="${file%.md}_$((counter++)).png"
          # convert the mermaid code block to an image
          echo -e "${mermaid}" | mmdc -i - -o "$filename"
        fi
      else
        mermaid="${mermaid}\n${line}"
      fi
    done < <(sed -n '/```mermaid/,/```/p' "$file")

    if [[ "${#blank_mermaid[@]}" > 0 ]]; then
      echo -e "\n\033[31mblank info: ${blank_mermaid[@]}\033[0m\n"
    fi

    # check if any PNG files were generated
    if ls *.png >/dev/null 2>&1; then
      # replace the mermaid code block with the image link in the markdown file
      sed -i '/```mermaid/,/```/c\\![mermaid diagram](?)' $file
      lines=($(grep -n '\!\[mermaid diagram\](?)' $file | cut -d: -f1))
      counter=0
      for (( i = 0; i < ${#blank_mermaid[@]}; i++ )); do
        if [[ ${blank_mermaid[$i]} == 1 ]]; then
          sed -i "${lines[$i]}s/(?)/(${file%.md}_$((counter++)).png)/" $file
        fi
      done
    fi
  done
}


if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

while getopts "h" arg; do
    case $arg in
        h)
            usage
            exit 0
            ;;
        ?)
            break
            ;;
    esac
done
convertmd_with_image $@