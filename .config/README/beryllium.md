# beryllium

## NVIDIA

```
$ cat/lib/udev/rules.d/80-nvidia-pm.rules
--------------------------------------------------------------------------------
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
```
```
$ cat /etc/modprobe.d/nvidia.conf
--------------------------------------------------------------------------------
options nvidia "NVreg_DynamicPowerManagement=0x02"
```
```
$ cat /etc/udev/rules.d/backlight.rules
--------------------------------------------------------------------------------
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", GROUP="video", MODE="0664"
```

## Keyboard Backlight
Install [`tuxedo-keyboard`](https://aur.archlinux.org/packages/tuxedo-keyboard/) and [`tuxedo-keyboard-ite`](https://aur.archlinux.org/packages/tuxedo-keyboard-ite/).

```
$ cat /etc/modules-load.d/tuxedo_keyboard
--------------------------------------------------------------------------------
tuxedo_keyboard
tuxedo_keyboard_ite
```

## Hibernation
```
$ cat /etc/default/grub
--------------------------------------------------------------------------------
...
# <UUID> is the UUID of the swap partition.
GRUB_CMDLINE_LINUX_DEFAULT="... resume=UUID=<UUID> ..."
...
```
remember to run `grub-mkconfig -o /boot/grub/grub.cfg`

```
$ cat /etc/mkinitcpio.conf
--------------------------------------------------------------------------------
...
MODULES=(... intel_agp i915 intel_lpss_pci ...)
...
# resume must go after udev
HOOKS=(... udev ... resume ...)
...
```
and run
```
$ systemctl enable nvidia-suspend
$ systemctl enable nvidia-hibernate
```
```
$ cat /etc/modprobe.d/nvidia-power-management.conf
--------------------------------------------------------------------------------
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/tmp/nvidia_video_memory
```
