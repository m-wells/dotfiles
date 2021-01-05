COMMAND=/usr/bin/google-drive-ocamlfuse
GDRIVE=${HOME}/GoogleDrive

if command -v ${COMMAND} &> /dev/null
then
    mount | grep ${GDRIVE} >/dev/null || ${COMMAND} ${GDRIVE} &
fi
