# General Configuration Notes

To enable [AppArmor](https://wiki.archlinux.org/index.php/AppArmor) set the following kernel parameters `apparmor=1 lsm=lockdown,yama,apparmor,bpf`.

## Utils
* `brightnessctl`
* `gnome-calculator`
* `libreoffice-fresh`
* `rclone`
* `systemd-ui`
    * provides the `systemadm` GUI
* `trash-cli`
* `xclip`
* `xkill`

## `i3`
  * `i3-gaps`
  * `i3-wk-switch-git`
  * `i3-lock`
  * `bemenu`
  * `bemenu-x11`
  * `j4-dmenu-desktop` (AUR)
* `polybar` (herecura/AUR)
* `conky`

## Networking
* `openssh`
* `sshfs`

## Autostarting
Using `dex` to autostart `.desktop` files in `~/.config/autostart`.
Place `exec --no-startup-id "dex -a"` in `~/.config/i3/config`.

For razer firefly mouse pad using [reactive.py](https://gist.github.com/lezed1/aa4918d6b5e6bd638e7c325c0ed44e7a#file-reactive-py) saved to `~/.config/polychromatic/reactive.py` and requires `python-pynput` to be installed.

## Theming
* `gtk-theme-material-black` (AUR)
* `lxappearance` (useful but not required)


## SDDM
### Theme
Install `archlinux-themes-sddm` from AUR

    $ cat /etc/sddm.conf.d/theme.conf
    [Theme]
    Current=archlinux-simplyblack

### Disable Avatars

    $ cat /etc/sddm.conf.d/avatar.conf
    [Theme]
    EnableAvatars=false

# Machine Specific Setups
## [helium](.config/README/helium.md)
## [beryllium](.config/README/helium.md)
    CPU: Intel i7-10875H
    GPU: NVIDIA GeForce RTX 2070 SUPER Mobile / Max-Q
    Memory: 

