#!/usr/bin/env bash

set -e
#set -x

Configs="\
    aarch64-3.10 \
    armv5-3.2 \
    armv7-2.6 \
    armv7-3.2 \
    mips-3.4 \
    mipsel-3.4 \
    x64-3.2 \
    x86-2.6"

DockerImage='builder'
PersistentVolume='EntwarePersistent'
EntryScriptName='propagate_env.sh'

StartContainer() {
    RunningContainers=$(docker container list --format '{{json .}}' | jq -r '.Names')
    ExistingVolumes=$(docker volume list --format '{{json .}}' | jq -r '.Name')
    if [ -z "$(echo $ExistingVolumes | grep $PersistentVolume)" ]; then
        echo 'Creating volume for persistent storage...'
        docker volume create $PersistentVolume
        TmpContainer='tmpEntwareContainer'
        docker container create --rm --mount source=${PersistentVolume},target=/mnt/${PersistentVolume} \
            --name ${TmpContainer} ${DockerImage}
        docker cp "${EntryScriptName}" "${TmpContainer}:/mnt/${PersistentVolume}"
        docker container rm $TmpContainer
    fi
    if [ -z "$(echo $RunningContainers | grep $1)" ]; then
        if [ -z "$(echo $ExistingVolumes | grep $1)" ]; then
            docker volume create $1
        fi
        gnome-terminal --tab -- \
        docker run --rm --mount source=$1,target=/home/me/E \
            --mount source=${PersistentVolume},target=/mnt/${PersistentVolume} \
            --entrypoint "/mnt/${PersistentVolume}/${EntryScriptName}" --interactive --tty \
            --name $1 --hostname $1 --env ENTWARE_ARCH=$1 ${DockerImage}
    else
        echo 'Already started, attaching'
        gnome-terminal --tab -- \
        docker exec -it $1 bash
    fi
}

i=0
echo '0) All'
for item in $Configs; do
    i=$((i+1))
    echo "${i}) $item"
done

read -p "Pick some container to run: " ConfigNr
if [ $ConfigNr -gt $i ] || [ $ConfigNr -lt 0 ]; then
    echo 'Smart choice (or not?)'
    exit 1
fi

i=0
for item in $Configs; do
    i=$((i+1))
    if [ $ConfigNr -eq 0 ]; then
         StartContainer $item
    elif [ $i -eq $ConfigNr ]; then
        StartContainer $item
        break
    fi
done
