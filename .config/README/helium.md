# HP Pavilion Notebook

```
$ cat /etc/X11/xorg.conf.d/20-intel.conf
----------------------------------------
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "True"
    Option "NoAccel" "True"
    Option "DRI" "False"
EndSection
```

To update file associations use `mimeo` (or edit `~/.config/mimeo/associations.txt`) and then do `sudo mimeo --update`

## CPUPOWER
```
$ cat /etc/default/cpupower
----------------------------------------
# Define CPUs governor
# valid governors: ondemand, performance, powersave, conservative, userspace.
governor='performance'

# Limit frequency range
# Valid suffixes: Hz, kHz (default), MHz, GHz, THz
#min_freq="2.25GHz"
#max_freq="3GHz"

# Specific frequency to be set.
# Requires userspace governor to be available.
# Do not set governor field if you use this one.
#freq=

# Utilizes cores in one processor package/socket first before processes are 
# scheduled to other processor packages/sockets.
# See man (1) CPUPOWER-SET for additional details.
#mc_scheduler=

# Utilizes thread siblings of one processor core first before processes are
# scheduled to other cores. See man (1) CPUPOWER-SET for additional details.
#smp_scheduler=

#  Sets a register on supported Intel processore which allows software to convey
# its policy for the relative importance of performance versus energy savings to
# the  processor. See man (1) CPUPOWER-SET for additional details.
#perf_bias=

# vim:set ts=2 sw=2 ft=sh et:
```
systemctl enable cpupower.service
sudo pacman -S cpupower
