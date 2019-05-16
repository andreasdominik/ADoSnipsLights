#!/bin/bash -xv
#
# API for REST interface to ShellyBulb.
#
# Commands include:
# ON, OFF, COLOR, WHITE,
# WARM, COLD,
# RED, GREEN, BLUE, ORANGE,
# DARK, MEDIUM, BRIGHT,
# STATUS,
# any number will be used as brightness/gain (0-255)
#

IP=$1
CMD=$2

if [ $CMD == RGB ] ; then
  RED=$3
  GREEN=$4
  BLUE=$5
  WHITE=$6
  GAIN=$7
  TEMP=$8
  BRIGHTNESS=$9
fi

URL="unused"
URL2="unused"

case $CMD in
ON)
  URL="/light/0?turn=on"
  ;;
OFF)
  URL="/light/0?turn=off"
  ;;
STATUS)
  URL="/light/0"
  ;;
COLOUR)
  URL="/settings?mode=color"
  ;;
WHITE)
  URL="/settings?mode=white"
  URL2="/light/0?temp=3000"
  ;;
WARM)
  URL="/settings?mode=white"
  URL2="/light/0?temp=4100"
  ;;
COLD)
  URL="/settings?mode=white"
  URL2="/light/0?temp=3000"
  ;;
RED)
  URL="/settings?mode=color"
  URL2="/light/0?red=255&green=0&blue=0&white=0"
  ;;
ORANGE)
  URL="/settings?mode=color"
  URL2="/light/0?red=255&green=113&blue=4&white=0"
  ;;
GREEN)
  URL="/settings?mode=color"
  URL2="/light/0?red=0&green=255&blue=0&white=0"
  ;;
BLUE)
  URL="/settings?mode=color"
  URL2="/light/0?red=0&green=0&blue=255&white=0"
  ;;
PINK)
  URL="/settings?mode=color"
  URL2="/light/0?red=255&green=0&blue=190&white=0"
  ;;
BRIGHT)
  URL="/light/0?gain=100&brightness=100"
  ;;
DARK)
  URL="/light/0?gain=30&brightness=30"
  ;;
MEDIUM)
  URL="/light/0?gain=75&brightness=75"
  ;;
[0-9]*)
  URL="/light/0?gain=$CMD&brightness=$CMD"
  ;;
RGB)
  URL="/light/0?red=$RED&green=$GREEN&blue=$BLUE&white=$WHITE&gain=$GAIN&temp=$TEMP&brightness=$BRIGHTNESS"
  ;;
*)
  URL="/light/0"
  ;;
esac


if [ $URL != unused ] ; then
  curl -v http://${IP}${URL} > "shellybulb.json"
fi
if [ $URL2 != unused ] ; then
  curl -v http://${IP}${URL2}
fi

cat "shellybulb.json"

exit $?  # return curl exit status
