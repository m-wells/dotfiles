# HP Pavilion Notebook
```
$ cat /etc/X11/xorg.conf.d/20-intel.conf
----------------------------------------
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
EndSection
```

To update file associations use `mimeo` (or edit `~/.config/mimeo/associations.txt`) and then do `sudo mimeo --update`
