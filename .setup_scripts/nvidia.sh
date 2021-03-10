mkdir -p /etc/pacman.d/hooks
echo "Setting up pacman hook to update initramfs after NVIDIA driver upgrade"
echo "[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'" > /etc/pacman.d/hooks/nvidia.hook

#echo "Section \"Device\"
#        Identifier  \"Nvidia Card\"
#        Driver      \"nvidia\"
#        VendorName  \"NVIDIA Corporation\"
#        BoardName   \"GeForce RTX 2070 Super\"
#        Option      \"RegistryDwords\"  \"EnableBrightnessControl=1; RMUseSwI2c=0x01; RMI2cSpeed=100\"
#EndSection" > /etc/X11/xorg.conf.d/20-nvidia.conf
#        Option      \"ConnectedMonitor\" \"DFP\"

echo "make sure to edit /etc/default/grub with GRUB_CMDLINE_LINUX_DEFAULT=\"nvidia-drm.modeset=1 quiet splash\""
echo "and re-generate the grub.cfg with \"grub-mkconfig -o /boot/grub/grub.cfg\""
