#!/usr/bin/env bash

if [ $# -gt 0 ]; then
    if [ "$1" == "same" ]; then
        docker exec -it robotx-underwater bash
    fi
else
    docker run -it --net=host --rm --name=robotx-underwater \
                --cap-add SYS_RAWIO \
                --device /dev/snd \
                --device /dev/mem \
                --device /dev/gpiomem \
                --group-add $(cut -d: -f3 < <(getent group gpio)) \
                --user "developer":$(id -g) \
                -v ${HOME}/robotx-underwater-task:/home/developer/robotx-underwater-task \
                coolcat647/robotx-underwater:rpi
fi
