#!/bin/bash
#***********************************************
# Utility of code statistic with git cmmmand,
# support linux or git bash,not support windows
# @author: simahao
# @version 1.0
# @date 20190804
#**********************************************

which git > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo "please install git"
    exit 1
fi
# if [[ ! -d '.git' ]]; then
#     echo 'Not a git repository'
#     exit
# fi
renamelimit=$(git config --get diff.renamelimit > /dev/null 2>&1)
if [[ renamelimit == "" ]]; then
    git config diff.renamelimit 9999999
fi
echo -e "\033[33m-------------------------"
echo -e '| name    ':$(git config --get user.name)
#echo 'remote url ':$(git config --get remote.origin.url)
echo -e '| branch  ':$(git symbolic-ref --short -q HEAD)
echo -e "-------------------------\033[0m"

#time:16,added lines:13,removed lines:15,total lines:13
echo -e "\033[34m┌────────────────┬─────────────┬───────────────┬─────────────┐\033[0m"
echo -e "\033[34m|      Time      | Added lines | Removed lines | Total lines |\033[0m"
git log --author="$(git config --get user.name)" --since=1.day   --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 day      | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
git log --author="$(git config --get user.name)" --since=3.day   --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     3 days     | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
git log --author="$(git config --get user.name)" --since=1.week  --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 week     | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
git log --author="$(git config --get user.name)" --since=1.month --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 month    | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
git log --author="$(git config --get user.name)" --since=1.year  --pretty=tformat: --numstat  | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "\033[34m|     1 year     | \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", add, subs, loc }' -
echo -e "\033[34m└────────────────┴─────────────┴───────────────┴─────────────┘\033[0m"

echo -e "\n\033[33mall contributors statistics:\033[0m"
echo -e "\033[34m┌────────────────┬─────────────┬───────────────┬─────────────┐\033[0m"
echo -e "\033[34m|name            | Added lines | Removed lines | Total lines |\033[0m"
git log --pretty='%aN' | sort -u | while read name; do git log --author="$name" --pretty=tformat: --numstat | gawk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "\033[34m|%-16s|\033[0m \033[32m%11s\033[0m \033[34m|\033[0m \033[31m%13s\033[0m \033[34m|\033[0m \033[35m%11s\033[0m \033[34m|\033[0m\n", "'$name'", add, subs, loc }' -; done
echo -e "\033[34m└────────────────┴─────────────┴───────────────┴─────────────┘\033[0m"

