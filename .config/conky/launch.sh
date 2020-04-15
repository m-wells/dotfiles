#! /bin/bash
#
# Terminate already running conky instances
killall -q conky

# Wait until the processes have been shut down
while pgrep -u $UID -x conky >/dev/null; do sleep 1; done

MONITOR=$(xrandr | grep primary | cut -d' ' -f1)
CONKYCONF="${HOME}/.config/conky/${HOSTNAME}/conky.conf"
if [ -x "$(command -v conky)" ] && [ -f ${CONKYCONF} ]; then
    i3quake -p right -m conky -- conky -c ${CONKYCONF}
    i3quake -p right -m conky -- conky -c ${CONKYCONF}
fi
