#!/bin/bash
#*********************************************************
# Utility of code count with git cmmmand,
# support linux or git bash,not support windows
# @author: simahao
# @version 1.1
# @date 20190804
# @date 20230728   1. support two branch
#                  2. pretty cell alian for chinese name
#*********************************************************

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
    echo -e "\033[33m-------------------------\033[0m"
    echo -e "\033[33m| current user:$(git config --get user.name)"
    echo -e "\033[33m| current branch:$(git symbolic-ref --short -q HEAD)"
    echo -e "\033[33m-------------------------\033[0m"
}

declare -A commiterMap
function getMaxLenOfCommiter() {
    readarray -t commiters <<< "$(git log --pretty='%aN' | sort -u)"
    maxLen=0
    for commiter in "${commiters[@]}"; do
        # lenght of one chinese or english is 1
        charLen=${#commiter}
        # length of one chinese is 3, length of one english character is 1
        byteLen=$(echo -n "$commiter" | wc -c)
        if [[ "${charLen}" == "${byteLen}" ]]; then
            commiterMap["${commiter}"]=${charLen}
        else
            # note: byte length of one chinese is 3, width of one chinese in screen is 2
            # e.g.
            # maxLen=12 name="汉字ab" byteLen=2*3+2=8 charLen=4, screen width=2*2+2=6
            # chineseLen=(8-4)/2=2
            chineseLen=$(((byteLen - charLen) / 2))
            engLen=$((charLen - chineseLen))
            commiterMap["${commiter}"]=$((chineseLen * 2 + engLen))
        fi
        if [[ ${commiterMap["${commiter}"]} -gt ${maxLen} ]]; then
            maxLen=${commiterMap["${commiter}"]}
        fi
    done
    return ${maxLen}
}

function countMe() {
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

function countCode() {
    metaInfo
    getMaxLenOfCommiter
    maxLen=$?
    if [[ ${maxLen} == 0 ]]; then
        echo "no commiters are found in this repository"
        exit 1
    fi
    maxLen=$((maxLen + 2))
    # log a..b=diff a...b
    # log a...b=diff a..b=diff a b
    # count commits in the branch1 which after checkouting from branch2
    if [[ $1 == "twoBranch" ]]; then
        echo -e "\n\033[33mall contributors code counts from $1:\033[0m"
    elif [[ $1 == "fromBegin" ]]; then
        echo -e "\n\033[33mall contributors code counts since initiating repository:\033[0m"
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

    # count code by every commiter
    readarray -t names <<< "$(git log --pretty='%aN' | sort -u)"

    for name in "${names[@]}"; do
        # spaceLen means maxLen - screen width(name), for alaining cell
        spaceLen=$((maxLen - commiterMap["${name}"]))
        space="$(printf "%*s" ${spaceLen} "")"
        if [[ $1 == "twoBranch" ]]; then
            git log "$2" --author="$name" --pretty=tformat: --numstat --no-merges | gawk -v space="${space}" -v name="${name}" '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "\033[34m|%s%s|\033[0m \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", name, space, add, subs, loc }' -;
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
    echo "  lines.sh -b master..master-tas or lines.sh -b master...master-tas"
    echo "  lines.sh -c commit1..commit2 or lines.sh -c commit1...commit2"
    echo ""
    echo "required: "
    echo "  -i                    count myself by period, e.g. 1 day or 1 week"
    echo "  -a                    count all commiters from initiating repository"
    echo "  -b <parent-branch..chinld-branch|parent-branch...child-branch>"
    echo "  -b <commit1..commit2|commit1...commit2>"
    echo "  -c <parent-branch..chinld-branch|parent-branch...child-branch>"
    echo "  -c <commit1..commit2|commit1...commit2>"
    echo "                        two dots means git log b1..b2, it equals to git diff b1...b2(three dots),"
    echo "                        count all commits which only in b2 since b2 checkout from b1"
    echo "                        three dots means git log b1...b2, it equals to git diff b1..b2(two dots),"
    echo "                        after b1 checkout from b2, do some commits to b1 (1), do some commits to b2 (2),"
    echo "                        git log b1...b2(three dots) means count all commits in (1) + (2)"
    echo "                  e.g."
    echo "                        A0 -> A1 -> A2 -> A3 (master)"
    echo "                        \\"
    echo "                         C0 -> C1 (test)"
    echo "                        "
    echo "                        $ git log master..test"
    echo "                        # result:C0 C1"
    echo "                        "
    echo "                        $ git log ^master test"
    echo "                        # result: C0 C1"
    echo "                        # lines.sh don't support ^master test for parsing input argument"
    echo "                        "
    echo "                        $ git log master…test"
    echo "                        # result: A1 A2 A3 C0 C1"
    echo "                        "
    echo "                        origin..HEAD: What did I do since I forked from the origin branch"
    echo "                        HEAD..origin: What did the origin do since I forked from them"
    echo ""
}

while getopts "iahb:c:" arg; do
    case $arg in
        i)
            countMe
            ;;
        b|c)
            countCode "twoBranch" "$OPTARG"
            ;;
        a)
            countCode "fromBegin"
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done