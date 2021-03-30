# General Configuration Notes

[Managing **dotfiles** with `git`](https://medium.com/@antelolive/how-to-manage-your-dotfiles-with-git-f7aeed8adf8b)
https://www.atlassian.com/git/tutorials/dotfiles

## Utils
* `asp`
    * for use with the [Arch Build System](https://wiki.archlinux.org/index.php/Arch_Build_System)
* `brightnessctl`
* `ctags`
* `debtap` (AUR, for devel AUR packages from `.deb` files)
* `gnome-calculator`
* `libreoffice-fresh`
* `rclone`
* `rsync`
* `ruby`
* `systemd-ui`
    * provides the `systemadm` GUI
* `tlp`
    * `tlp-rdw` with `--asdeps`
* `trash-cli`
* `xclip`
* `xkill`
* `evhz-git` (AUR)

## `i3`
  * `i3-gaps`
  * `i3-wk-switch-git`
  * `i3-lock`
  * `bemenu`
  * `bemenu-x11`
  * `j4-dmenu-desktop` (AUR)
* `polybar` (herecura/AUR)
* `conky`

## Julia
Ideally I would use [julia-mkl](https://aur.archlinux.org/packages/julia-mkl/) but currently there is an issue with [intel-common-libs](https://aur.archlinux.org/packages/intel-common-libs).
* `julia`
* `gcc-fortran` (asdeps)

Packages to install
* Revise
* LanguageServer
* SymbolServer
* StaticLint

## Useful Commands
To remove orphan packages (packages not required or optionally required) use `sudo pacman -R $(pacman -Qtdq)`

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

## Silent Boot

    $ cat /etc/default/grub
    ...
    GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 vga-current ..."
    ...
    $ cat /etc/mkinitcpio.conf
    ...
    # replace udev with systemd
    HOOKS = ( base systemd fsck ...)
    ...

Now edit `systemd-fsck-root.service` and `systemd-fsck@.service`:

    $ systemctl edit --full systemd-fsck-root.service
    $ systemctl edit --full systemd-fsck@.service

Configuring StandardOutput and StandardError like this:
    
    (...)
    
    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/usr/lib/systemd/systemd-fsck
    StandardOutput=null
    StandardError=journal+console
    TimeoutSec=0

`plymouth` (AUR)

/etc/mkinitcpio.conf

HOOKS=(base systemd sd-plymouth ... sd-encrypt ...)

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
## [lithium](.config/README/lithium.md)
## [beryllium](.config/README/beryllium.md)
    CPU: Intel i7-10875H
    GPU: NVIDIA GeForce RTX 2070 SUPER Mobile / Max-Q
    Memory: 

## CUDA
If you run into trouble with CUDA not being available, run `nvidia-modprobe` first.

# New installations
If ethernet was plugged in after starting environment may need to issue `systemctl restart dhcpcd@<interface.service>` (for one machine I had to do `systemctl restart dhcpcd@enp3s0f1`).

## SSDs
Completely reset an SSD's cells to restore factory default write performance see [Solid state drive/Memory cell clearing](https://wiki.archlinux.org/index.php/Solid_state_drive/Memory_cell_clearing).

## Makepkg
[Improve build and compile times](https://wiki.archlinux.org/index.php/Makepkg#Improving_compile_times)

    $ cat /etc/makepkg.conf
    CFLAGS="-march=native -O2 -pipe -fstack-protector-strong -fno-plt"
    CXXFLAGS="${CFLAGS}"
    MAKEFLAGS="-j$(nproc)"
    BUILDDIR=/tmp/makepkg
    BUILDENV=(!distcc color ccache check !sign)

[Using_a_compilation_cache](https://wiki.archlinux.org/index.php/Makepkg#Using_a_compilation_cache)

    $ cat /etc/profile
    export PATH="/usr/lib/ccache/bin/:$PATH"

## Mirrorlist
[Reflector](https://wiki.archlinux.org/index.php/Reflector)
`reflector --country 'United States' --latest 200 --age 24 --sort rate --save /etc/pacman.d/mirrorlist`

## File systems
### [Advanced Format](https://wiki.archlinux.org/index.php/Advanced_Format)
Check if drive uses 4k sectors `fdisk -l /dev/sdX`
If drive supports 4096 then use `mkfs.ext4 -F -b 4096 /dev/device`

## AppArmor
To enable [AppArmor](https://wiki.archlinux.org/index.php/AppArmor) set the following kernel parameters `apparmor=1 lsm=lockdown,yama,apparmor,bpf`.

    systemctl enable apparmor.service --now
    systemctl enable snapd.apparmor.service --now


