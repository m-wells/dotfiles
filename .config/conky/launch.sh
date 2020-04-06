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

#xgap=10
# Launch Conky on each monitor, using default config location ~/.config/conky/conky.conf
#for i in $(xrandr | grep \* | awk '{print $1}' | cut -f 1 -d x); do
#    echo "using xgap = $xgap"
#    conky -x $xgap
#    xgap=`expr $xgap + $i`
#done
