#! /bin/bash
#
# Terminate already running conky instances
killall -q conky

# Wait until the processes have been shut down
while pgrep -u $UID -x conky >/dev/null; do sleep 1; done

CONKYCONF="${HOME}/.config/conky/${HOSTNAME}/conky.conf"
if [ -x "$(command -v conky)" ] && [ -f ${CONKYCONF} ]; then
    conky -c ${CONKYCONF}
fi
