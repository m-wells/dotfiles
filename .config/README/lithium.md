# Aspire E 15
[Had to add boot entry in bios](https://bbs.archlinux.org/viewtopic.php?id=234932)

## backlight

    $ cat /etc/udev/rules.d/backlight.rules
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
