#!/bin/bash
#################################################################
# Note:                                                         #
# generate nexus3 tutorails doc                                 #
# @author:zhanghao                                              #
# @groupId:dev2                                                 #
#################################################################

# --------------------------------------------------------------|
# version |  date    | comments                                 |
# --------------------------------------------------------------|
# 1.0.0   | 20210516 | init                                     |
# 1.0.1   | 20210519 | support mac                              |
#---------------------------------------------------------------|

ID=dev2-nexus3
USER=dev2
PASSWORD=Dev2Dev2
PORT=8082
EMAIL='abc@dev2.com'
DOMAIN='dev2.docker'

OUT_IP='172.27.234.197'
OUT_BASE_URL="http://${OUT_IP}:8082/nexus3/repository"
OUT_MAVEN_PUBLIC=${OUT_BASE_URL}/maven-public
OUT_MAVEN_RELEASES=${OUT_BASE_URL}/maven-releases
OUT_MAVEN_SNAPSHOTS=${OUT_BASE_URL}/maven-snapshots
OUT_NPM_PUBLIC=${OUT_BASE_URL}/npm-public
OUT_NPM_HOSTED=${OUT_BASE_URL}/npm-hosted
OUT_PYPI_PUBLIC=${OUT_BASE_URL}/pypi-public
OUT_PYPI_HOSTED=${OUT_BASE_URL}/pypi-hosted
OUT_CONDA_PUBLIC="http://${USER}:${PASSWORD}@${OUT_IP}:${PORT}/nexus3/repository/conda-public"

IN_IP='172.52.145.172'
IN_BASE_URL="http://${IN_IP}:8082/nexus3/repository"
IN_MAVEN_PUBLIC=${IN_BASE_URL}/maven-public
IN_MAVEN_RELEASES=${IN_BASE_URL}/maven-releases
IN_MAVEN_SNAPSHOTS=${IN_BASE_URL}/maven-snapshots
IN_NPM_PUBLIC=${IN_BASE_URL}/npm-public
IN_NPM_HOSTED=${IN_BASE_URL}/npm-hosted
IN_PYPI_PUBLIC=${IN_BASE_URL}/pypi-public
IN_PYPI_HOSTED=${IN_BASE_URL}/pypi-hosted
IN_CONDA_PUBLIC="http://${USER}:${PASSWORD}@${IN_IP}:${PORT}/nexus3/repository/conda-public"

OS=$(uname)
# alias is opened by default under interactive mode
# shell is non-interactive mode, so open alias explictly
# or use /bin/bash -login and put alias setting in ~/.bashrc
shopt -s expand_aliases

if [[ ${OS} == "Darwin" ]]; then
    alias mysed="sed -i ''"
else
    alias mysed="sed -i"
fi

function usage() {
    echo "NAME"
    echo "        doc.sh  generate doc according to internet or intranet config"
    echo "SYNOPSIS"
    echo "        syn.sh [OPTIONS]"
    echo "DESCRIPTION"
    echo "        -h"
    echo "            display help infomation"
    echo "        -i"
    echo "            in mode: generate doc for intranet"
    echo "        -o"
    echo "            out mode: generate doc for internet"
}

function doc() {
    if [[ $# == 0 ]]; then
        echo "no parameter!"
        usage
    elif [[ $1 == "i" ]]; then
        mysed -e "s#\${ID}#${ID}#g" \
            -e "s#\${USER}#${USER}#g" \
            -e "s#\${PASSWORD}#${PASSWORD}#g" \
            -e "s#\${IP}#${IN_IP}#g" \
            -e "s#\${EMAIL}#${EMAIL}#g" \
            -e "s#\${MAVEN-PUBLIC}#${IN_MAVEN_PUBLIC}#g" \
            -e "s#\${MAVEN-RELEASES}#${IN_MAVEN_RELEASES}#g" \
            -e "s#\${MAVEN-SNAPSHOTS}#${IN_MAVEN_SNAPSHOTS}#g" \
            -e "s#\${NPM-PUBLIC}#${IN_NPM_PUBLIC}#g" \
            -e "s#\${NPM-HOSTED}#${IN_NPM_HOSTED}#g" \
            -e "s#\${PYPI-PUBLIC}#${IN_PYPI_PUBLIC}#g" \
            -e "s#\${PYPI-HOSTED}#${IN_PYPI_HOSTED}#g" \
            -e "s#\${DOMAIN}#${DOMAIN}#g" \
            -e "s#\${CONDA-PUBLIC}#${IN_CONDA_PUBLIC}#g" nexus.md
    elif [[ $1 == "o" ]]; then
        mysed -e "s#\${ID}#${ID}#g" \
            -e "s#\${USER}#${USER}#g" \
            -e "s#\${PASSWORD}#${PASSWORD}#g" \
            -e "s#\${IP}#${OUT_IP}#g" \
            -e "s#\${EMAIL}#${EMAIL}#g" \
            -e "s#\${MAVEN-PUBLIC}#${OUT_MAVEN_PUBLIC}#g" \
            -e "s#\${MAVEN-RELEASES}#${OUT_MAVEN_RELEASES}#g" \
            -e "s#\${MAVEN-SNAPSHOTS}#${OUT_MAVEN_SNAPSHOTS}#g" \
            -e "s#\${NPM-PUBLIC}#${OUT_NPM_PUBLIC}#g" \
            -e "s#\${NPM-HOSTED}#${OUT_NPM_HOSTED}#g" \
            -e "s#\${PYPI-PUBLIC}#${OUT_PYPI_PUBLIC}#g" \
            -e "s#\${PYPI-HOSTED}#${OUT_PYPI_HOSTED}#g" \
            -e "s#\${DOMAIN}#${DOMAIN}#g" \
            -e "s#\${CONDA-PUBLIC}#${OUT_CONDA_PUBLIC}#g" nexus.md
    else
        echo "invalid paramenter!"
        usage
    fi
}

while getopts ":hio" OPT; do
    case ${OPT} in
        h)
            usage;;
        i)
            doc ${OPT};;
        o)
            doc ${OPT};;
        ?)
            usage;;
    esac
done
