pacman -S bluez bluez-utils blueman
cp 51-blueman.rules /etc/polkit-1/rules.d/51-blueman.rules
systemctl enable bluetooth.service --now
usermod -a -G lp $USER
