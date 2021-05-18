#!/bin/bash

#################################################################
# Note:                                                         #
# utility of nexus3 for synchronizing from internet to intranet #
# @author:zhanghao                                              #
# @groupId:dev2                                                 #
#################################################################

# --------------------------------------------------------------|
# version |  date    | comments                                 |
# --------------------------------------------------------------|
# 1.0.0   | 20210514 | init for nexus3                          |
#---------------------------------------------------------------|

# default variable
IP=''
FILE=import
DIRS='./blobs ./db/component'
MIN=30
UPLOAD='update.tar.gz'
USER='zhanghao'
PASSWD=''
ACTION="0"
LOG_FLAG=1
DATE=$(date +"%Y-%m-%d %H:%M:%S")
STORE="/home/nexus3/sonatype-work/nexus3"

cd ~

function log() {
    msg="[${DATE}] $1"
    if [[ $# > 1 ]]; then
        LOG_FLAG=$2
    fi
    if [[ ${LOG_FLAG} == 1 ]]; then
        echo "${msg}" >> ~/syn.log
        echo $1 | grep "error" > /dev/null
        if [[ $? == 0 ]]; then
            echo "${msg}" >> ~/err.log
        fi
    else
        echo "${msg}"
    fi
}

function get_json_field() {
    # delete three char { } "
    curl_ret=$(echo ${curl_ret} | sed 's/[{}"]//g')
    if [[ $1 == "code" ]]; then
        code=$(echo ${curl_ret} | grep -E -o "code:[0-9]+" | awk -F ':' '{print $2}')
    elif [[ $1 == "token" ]]; then
        token=$(echo ${curl_ret} | grep -E -o "token:\S+" | awk -F ':' '{print $2}')
    else
        log "[error] not support parameter: $1" 0
    fi
}

function get_token() {
    # get proxy token
    curl_ret=$(curl -s -k --request POST "https://${IP}/UniExServices/restfulapi/token" \
    --header "Content-Type: application/json" \
    -d "{\"account\":\"${USER}\",\"password\":\"${PASSWD}\"}")
    # {"msg":"success","code":"200","token":"6cf6e570-da8d-404b-a4f3-8606c07aab49"}
    get_json_field code
    if [[ ${code} == "200" ]]; then
        get_json_field token
        log "[info] token: ${token}"
        return 0
    fi
    return 1
}

# put update.tar.gz to proxy server
function put() {
    log "[info] ready to put ${UPLOAD} to proxy server"
    cd ~
    get_token
    if [[ $? == 0 ]]; then
        # search file whether exist on the proxy server or not, if exists, delete it firstly
        # delete diretly
        curl_ret=$(curl -s -k --request POST "https://${IP}/UniExServices/restfulapi/${USER}/${UPLOAD}?method=delete&is_dir=false" \
        --header "Authorization: ${token}")
        log "[info] delete ${UPLOAD} from proxy server:${curl_ret}"

        curl_ret=$(curl -s -k --request POST "https://${IP}/UniExServices/restfulapi/${USER}/${UPLOAD}?method=upload&location=1" \
        --header "Authorization: ${token}" \
        --header "Content-Type: text/plain" \
        --data-binary "@./${UPLOAD}")
        get_json_field code
        if [[ ${code} == "200" ]]; then
            log "[info] put ${UPLOAD} to proxy server success"
            return 0
        else
            log "[error] put ${UPLOAD} to proxy server failed"
            return 1
        fi
    else
        log "[error] get proxy server token failed"
        return 1
    fi
}

# package changed blob and db files
function package() {
    log "[info] ready to package"
    local count=$(find ${DIRS} -type f -cmin -${MIN} -print | wc -l)
    local retry=0
    while (( ${retry} < 10 )); do
        sleep 3
        local new_count=$(find ${DIRS} -type f -cmin -${MIN} -print | wc -l)
        if [[ ${new_count} > ${count} ]]; then
            sleep 3
        else
            break
        fi
        ((retry=retry + 1))
    done
    rm -rf ~/${UPLOAD}
    cd $STORE
    log "[info] script will syn files under ${DIRS} within ${MIN} minutes"
    find ${DIRS} -type f -cmin -${MIN} -print  > ~/${FILE}
    # -s means file is not null
    if [[ -s ~/${FILE} ]]; then
        tar zcf ~/${UPLOAD} -T ~/${FILE}
        log "[info] package success"
        return 0
    else
        log "[info] there is no changess in the repositories within ${MIN} minutes"
        return 1
    fi;
}

# print infomation
function print_info() {
    get_token
    if [[ $1 == "p" ]]; then
        echo "put: curl -s -k --request POST 'https://${IP}/UniExServices/restfulapi/${USER}/${UPLOAD}?method=upload&location=1' --header 'Authorization: ${token}' --header 'Content-Type: text/plain' --data-binary '@./${UPLOAD}'"
    elif [[ $1 == "d" ]]; then
        echo "delete: curl -s -k --request POST 'https://${IP}/UniExServices/restfulapi/${USER}/${UPLOAD}?method=delete&is_dir=false' --header 'Authorization: ${token}'"
    elif [[ $1 == "t" ]]; then
        echo "token: ${token}"
    else
        log "[error] invalid parameter:$1"
    fi
}

# help
function usage() {
    echo "NAME"
    echo "        syn.sh - syn components to intranet proxy server for nexus3"
    echo "SYNOPSIS"
    echo "        syn.sh [OPTIONS]"
    echo "DESCRIPTION"
    echo "        -h"
    echo "            display help infomation"
    echo "        -p"
    echo "            execute package only"
    echo "        -t"
    echo "            execute put only"
    echo "        -d dirs"
    echo "            check these path for whether files changed or not. e.g. -d './blob ./db', multiple path should be surrounded by single quots"
    echo "        -m minutes"
    echo "            check within x minutes for wheher files changed or not. e.g. -m 90"
    echo "        -i [pdt]"
    echo "            print useful infomation"
    echo "            p: put command(curl)"
    echo "            d: delete command(curl)"
    echo "            t: token"
}


while getopts ":hptdi:m:" OPT
do
    case ${OPT} in
        h)
            usage
            exit 0;;
        p)
            ACTION="${ACTION}1";;
        t)
            ACTION="${ACTION}2";;
        d)
            DIRS="${OPTARG}";;
        m)
            MIN="${OPTARG}";;
        i)
            print_info ${OPTARG}
            exit 0;;
        ?)
            usage
            exit 1;;
    esac
done

rm -rf ./syn.log

if [[ ${ACTION} == "0" || ${ACTION} == "012" ]]; then
    package && put
elif [[ ${ACTION} == "01" ]]; then
    # package only
    package
elif [[ ${ACTION} == "02" ]]; then
    # put update.tar.gz only
    put
else
    log "[error] program has fatal error!"
fi

