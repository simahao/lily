#!/bin/bash

EXT=(java json yml md js yaml xml properties MF)


function encrypt() {

    local i=0
    for ext in "${EXT[@]}"; do
        echo "deal $ext file"
        find . -name "*.${ext}" -exec sh -c 'f="{}"; mv -- "$f" "${f%.\${ext}}.log\${i}"' \;
        i=$((i + 1))
    done
}


function decrypt() {
    line=""
}

encrypt
