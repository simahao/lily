#!/bin/bash

MIRROR='dockerhub.icu'
function pull_docker_image() {
    img=$1
    mirror_img=$(echo "${img}" | sed "s/quay\.io/quay.${MIRROR}/g;s/ghcr\.io/ghcr.${MIRROR}/g;s/registry\.k8s\.io/k8s.${MIRROR}/g;s/k8s\.gcr\.io/k8s.${MIRROR}/g;s/gcr\.io/gcr.${MIRROR}/g;s/docker\.io/${MIRROR}/g")

    if [[ "${img}" == "${mirror_img}" ]]; then
        sodu docker pull "${MIRROR}/${img}"
    else
        sudo docker pull "${mirror_img}"
        sudo docker tag "${mirror_img}" "${img}"
        sudo docker rmi "${mirror_img}"
    fi
}

pull_docker_image "$1"

