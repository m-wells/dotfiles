#!/bin/bash
echo i2c-dev > /etc/modules-load.d/i2c-dev.conf

echo "[Unit]
Description=ddcci handler
After=graphical.target
Before=shutdown.target
Conflicts=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo Trying to attach ddcci to %i && success=0 && i=0 && id=\$(echo %i | cut -d \"-\" -f 2) && while ((success < 1)) && ((i++ < 5)); do /usr/bin/ddcutil getvcp 10 -b \$id && { success=1 && echo ddcci 0x37 /sys/bus/i2c/devices/%i/new_device && echo \"ddcci attached to %i\"; } || sleep 5; done'
Restart=no" > /etc/systemd/system/ddcci@.service

echo "SUBSYSTEM==\"i2c-dev\", ACTION==\"add\",\\
	ATTR{name}==\"NVIDIA i2c adapter*\",\\
	TAG+=\"ddcci\",\\
	TAG+=\"systemd\",\\
	ENV{SYSTEMD_WANTS}+=\"ddcci@\$kernel.service\"" > /etc/udev/rules.d/99-ddcci.rules

echo "SUBSYSTEM==\"i2c-dev\",KERNEL==\"i2c-[0-9]*\", MODE=\"0666\"" > /etc/udev/rules.d/99-i2c.rules
# udevadm control --reload-rules && udevadm trigger
# modprobe i2c-dev
# echo "options nvidia NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100" > /etc/modprobe.d/nvidia-ddc.conf
cp /usr/share/ddcutil/data/90-nvidia-i2c.conf /etc/X11/xorg.conf.d/.
