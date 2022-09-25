#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GROUP_ID_DOCKER_SOCKET=$(cut -d: -f3 < <(getent group "$(stat -c "%G" /var/run/docker.sock)"))

echo "" > "${SCRIPT_DIR}/.env" # clear file
echo "PGID_DOCKER_SOCKET=${GROUP_ID_DOCKER_SOCKET}" >> "${SCRIPT_DIR}/.env"