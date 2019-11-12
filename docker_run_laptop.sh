#!/usr/bin/env bash

# Make sure processes in the container can connect to the x server
# Necessary so gazebo can create a context for OpenGL rendering (even headless)
xhost +local:docker

XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist $DISPLAY)
    xauth_list=$(sed -e 's/^..../ffff/' <<< "$xauth_list")
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi


# Prevent executing "docker run" when xauth failed.
if [ ! -f $XAUTH ]
then
  echo "[$XAUTH] was not properly created. Exiting..."
  exit 1
fi


if [ $# -gt 0 ]; then
    if [ "$1" == "same" ]; then
        docker exec -it robotx-underwater bash
    fi
else
    docker run -it --net=host --rm --privileged --name=robotx-underwater \
                -e DISPLAY \
                -e QT_X11_NO_MITSHM=1 \
                -e XAUTHORITY=$XAUTH \
                -v "$XAUTH:$XAUTH" \
                -v "/tmp/.X11-unix:/tmp/.X11-unix" \
                -v "/etc/localtime:/etc/localtime:ro" \
                --device /dev/snd \
                --group-add "audio" \
                -v ${HOME}/code/robotx-underwater-task:/home/developer/robotx-underwater-task \
                -w /home/developer/robotx-underwater-task \
                coolcat647/robotx-underwater:laptop
fi