#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if [ "${HOSTNAME}" == "helium" ]; then
    MONITOR="eDP-1" \
    WIRED="eno1" \
    WIRELESS="wlo1" \
    BATTERY="BAT0" \
    ADAPTER="ADP1" \
    polybar top &
elif [ "${HOSTNAME}" == "lithium" ]; then
    MONITOR="eDP1" \
    WIRED="enp3s0f1" \
    WIRELESS="wlp2s0" \
    BATTERY="BAT1" \
    ADAPTER="ACAD" \
    polybar top &
fi
