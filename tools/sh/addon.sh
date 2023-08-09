#!/bin/bash

function pull_docker_image() {
    k8s_img=$1
    mirror_img=$(echo "${k8s_img}" | sed 's/quay\.io/quay.dockerproxy.com/g;s/ghcr\.io/ghcr.dockerproxy.com/g;s/registry\.k8s\.io/k8s.dockerproxy.com/g;s/k8s\.gcr\.io/k8s.dockerproxy.com/g;s/gcr\.io/gcr.dockerproxy.com/g;s/docker\.io/dockerproxy.com/g')

    if [[ "${k8s_img}" == "${mirror_img}" ]]; then
        sodo docker pull "${k8s_img}"
    else
        sudo docker pull "${mirror_img}"
        sudo docker tag "${mirror_img}" "${k8s_img}"
        sudo docker rmi "${mirror_img}"
    fi
}

addon=$1


arr_dep=$(minikube addons images "${addon}" | awk -F '|' '{print $2 $3 $4}' | sed '1,4d;$d')

echo "${arr_dep}" | awk '{print $1,$2,$3}' | while read addon_name image repo; do
    image=$(echo "${image}" | awk -F '@' '{print $1}')
    docker_image="${repo}"/"${image}"
    echo "+++++++++++++${docker_image}+++++++++++++++"
    pull_docker_image "${docker_image}"
    minikube image load "${docker_image}"
    [ -z "${list_in_child}" ] && list_in_child="${addon_name}=${docker_image}" || list_in_child="${list_in_child},${addon_name}=${docker_image}"
    echo "${list_in_child}" > image_list
done

image_list=$(cat image_list)
minikube addons enable "${addon}" --images="${image_list}"
rm -f image_list