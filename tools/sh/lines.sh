#!/bin/bash
#***********************************************
# Utility of code statistic with git cmmmand,
# support linux or git bash,not support windows
# @author: simahao
# @version 1.0
# @date 20190804
#**********************************************

if ! which git > /dev/null 2>&1; then
    echo "please install git"
    exit 1
fi
# if [[ ! -d '.git' ]]; then
#     echo 'Not a git repository'
#     exit
# fi
renamelimit=$(git config --get diff.renamelimit > /dev/null 2>&1)
if [[ ${renamelimit} == "" ]]; then
    git config diff.renamelimit 9999999
fi

function metaInfo() {
    echo -e "\033[33m-------------------------"
    echo -e '| name    ':"$(git config --get user.name)"
    #echo 'remote url ':$(git config --get remote.origin.url)
    echo -e '| branch  ':"$(git symbolic-ref --short -q HEAD)"
    echo -e "-------------------------\033[0m"
}
function getMaxLenOfCommiter() {
    readarray -t commiters <<< "$(git log --pretty='%aN' | sort -u | sort -nr -k1)"
    return $(echo "${commiters[0]}" | wc -c)
}

function statMe() {
    metaInfo
    #time:16,added lines:13,removed lines:15,total lines:13
    echo -e "\033[34m┌────────────────┬─────────────┬───────────────┬─────────────┐\033[0m"
    echo -e "\033[34m|      Time      | Added lines | Removed lines | Total lines |\033[0m"
    git log --author="$(git config --get user.name)" --since=1.day   --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 day      | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
    git log --author="$(git config --get user.name)" --since=3.day   --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     3 days     | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
    git log --author="$(git config --get user.name)" --since=1.week  --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 week     | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
    git log --author="$(git config --get user.name)" --since=1.month --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 month    | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
    git log --author="$(git config --get user.name)" --since=1.year  --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 year     | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
    echo -e "\033[34m└────────────────┴─────────────┴───────────────┴─────────────┘\033[0m"
}

function statCode() {
    metaInfo
    getMaxLenOfCommiter
    maxLen=$?
    maxLen=$((maxLen + 2))
    # log a..b=diff a...b
    # log a...b=diff a..b=diff a b
    if [[ $1 == "twoBranch" ]]; then
        echo -e "\n\033[33mall contributors statistics from $1:\033[0m"
    elif [[ $1 == "fromBegin" ]]; then
        echo -e "\n\033[33mall contributors statistics:\033[0m"
    fi
    echo -e -n "\033[34m┌"
    c1=$maxLen
    while [[ $c1 -gt 0 ]]; do echo -n "─"; c1=$((c1 - 1)); done
    echo -e "┬─────────────┬───────────────┬─────────────┐"

    echo -n "|name"
    c2=$((maxLen - 4))
    while [[ $c2 -gt 0 ]]; do echo -e -n " "; c2=$((c2 - 1)); done
    echo -e "| Added lines | Removed lines | Total lines |\033[0m"

    echo -e -n "\033[34m└"
    c1=$maxLen
    while [[ $c1 -gt 0 ]]; do echo -n -e "─"; c1=$((c1 - 1)); done
    echo -e "┴─────────────┴───────────────┴─────────────┘\033[0m"


    readarray -t names <<< "$(git log --pretty='%aN' | sort -u)"

    for name in "${names[@]}"; do
        charLen=${#name}
        byteLen=$(echo -n $name | wc  -c)
        local space=""
        if [[ ${charLen} == ${byteLen} ]]; then
            spaceLen=$((maxLen - charLen))
        else
            # note: byte length of one chinese is 3, width of one chinese is 2
            # e.g.
            # maxLen=12 name="汉字ab" byteLen=2*3+2=8 charLen=4
            # hanziLen=(8-4)/2=2
            # engLen=4-2=2
            # spaceLen=12 - 2*2 - 2*1 = 6
            hanziLen=$(((byteLen - charLen) / 2))
            engLen=$((charLen - hanziLen))
            spaceLen=$((maxLen - hanziLen * 2 - engLen))
        fi
        space="$(printf "%*s" ${spaceLen} "")"
        if [[ $1 == "twoBranch" ]]; then
            git log $2 --author="$name" --pretty=tformat: --numstat --no-merges | gawk -v space="${space}" -v name="${name}" '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "\033[34m|%s%s|\033[0m \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", name, space, add, subs, loc }' -;
        else
            git log --author="$name" --pretty=tformat: --numstat --no-merges | gawk -v space="${space}" -v name="${name}" '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "\033[34m|%s%s|\033[0m \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", name, space, add, subs, loc }' -;
        fi
    done

    echo -e -n "\033[34m└"
    c1=$maxLen
    while [[ $c1 -gt 0 ]]; do echo -n -e "─"; c1=$((c1 - 1)); done
    echo -e "┴─────────────┴───────────────┴─────────────┘\033[0m"
}

function usage() {
    echo "usage: "
    echo "  lines.sh -i"
    echo "  lines.sh -a"
    echo "  lines.sh -b master-tas..master"
    echo ""
    echo "required: "
    echo "  -i                         statistic myself by period, e.g. 1 day or 1 week"
    echo "  -a                         statistic all commiters from initiating repository"
    echo "  -b <b1..b2|b1...b2>        two dots means: git log b1..b2 equals to git diff b1...b2, statistic all commits which only in b1 since b1 checkout from b2"
    echo "                             three dots means: git log b1...b2 equals to git diff b1..b2, b1 checkout from b2, do some commits to b1 (1), do some commits to b2 (2), three dots means statistic all commits in (1) + (2)"
    echo ""
}

while getopts "iab:" arg; do
    case $arg in
        i)
            statMe
            ;;
        b)
            statCode "twoBranch" "$OPTARG"
            ;;
        a)
            statCode "fromBegin"
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done