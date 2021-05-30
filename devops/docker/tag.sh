#!/bin/bash
#################################################################
# Note:                                                         #
# get tag from docker hub                                       #
# @author:zhanghao                                              #
# @groupId:dev2                                                 #
#################################################################

# --------------------------------------------------------------|
# version |  date    | comments                                 |
# --------------------------------------------------------------|
# 1.0.0   | 20210529 | init                                     |
#---------------------------------------------------------------

#OS=$(uname)
# alias is opened by default under interactive mode
# shell is non-interactive mode, so open alias explictly
# or use /bin/bash -login and put alias setting in ~/.bashrc
#shopt -s expand_aliases

# if [[ ${OS} == "Darwin" ]]; then
#     alias mysed="sed -i ''"
# else
#     alias mysed="sed -i"
# fi

function usage() {
    cat << EOF
NAME:
    tag.sh - list all tags for a Docker image accroing to remote index
EXAMPLE:
    - list tags for nginx, only show recet versions
        tag.sh nginx 
    - list tags for personal images,e.x. getting-started
        tag.sh docker/getting-started
    - list all tags for nginx 
        tag.sh -a nginx 
EOF
}

function docker-tag() {
    local url=""
    grep -s '/' $1 > /dev/null
    if [[ $? == 0 ]]; then
        # personal or organization images, e.x. docker/getting-started
        url="https://registry.hub.docker.com/v2/repositories/$1/tags/?page_size=100"
    else
        # offical images, e.x. nginx
        url="https://registry.hub.docker.com/v2/repositories/library/$1/tags/?page_size=100"
    fi
    local total_results=""
    while [[ -n ${url} ]]; do
	result=$(curl -s -S ${url})
	result=$(python3 - <<EOF
import sys, json
data = json.loads('''$result''');
print(data.get("next", "") or "");
print("\n".join([t["name"] for t in data["results"]]))
EOF
)
        #get url arrording to field["next"]
        url=$(echo "${result}" | head -n 1)
        #because of url, tags info are from line 2
        result=$(echo "${result}" | tail -n +2)
        total_results="${total_results}${result}"
        if [[ ${ALL_FLAG} == 0 ]]; then
            break
        fi
    done
    echo "${total_results}" | sort --version-sort | uniq
}

if [[ $# == 0 ]]; then
    usage
    exit 1
fi

ALL_FLAG=""
while getopts ":ha:" OPT; do
    case ${OPT} in
        h)
            usage
            exit 1;;
        a)
            ALL_FLAG=1
            IMAGE=${OPTARG};;
        ?)
            ALL_FLAG=0
            IMAGE=${OPTARG};;
    esac
done

if [[ ${ALL_FLAG} == "" ]]; then
    ALL_FLAG=0
    IMAGE=$1
fi
docker-tag ${IMAGE}
