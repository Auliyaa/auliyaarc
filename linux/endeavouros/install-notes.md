
# Arch Linux installation notes

## Installing from Live ISO

- Use **nvidia turing GPU** from the grub menu in the installer, this selects the latest nvidia drivers (590+)
- Start the installer and select **online mode**
- Use **plasma KDE** desktop environment
- Use **systemd-boot** as the bootloader
- Finish the installation, reboot and login.
- Setup your displays.
- In the welcome window, select **Update your mirrors** and then don't show anymore.
- Open a terminal

```bash
# let's configure git and fetch our bashrc files
# ----------------------------------------------
ssh-keygen # generate a ssh key and upload it to github
mkdir -p ~/dev
cd ~/dev
git clone git@github.com:Auliyaa/auliyaarc.git
git config --global user.name "Auliyaa"
git config --global user.email "mymail"

# now let's setup the bash environment
# ----------------------------------------------
cd
rm .bashrc
rm -fr Documents/ Music/ Pictures/ Public/ Templates/ Videos/
ln -s ~/dev/auliyaarc/Pictures/
ln -s ~/dev/auliyaarc/linux/bashrc ~/.bashrc
bash # should show no error

# install base software
# ----------------------------------------------
yay -S --noconfirm filelight discord dropbox vlc vlc-plugin-ffmpeg vlc-plugins-all git visual-studio-code-bin yakuake python-pip python gitkraken veracrypt python-pygments jq zip unzip kolourpaint onlyoffice-bin nano-syntax-highlighting python-tabulate hardinfo ytmdesktop-bin

# shell utils
# ----------------------------------------------
yay -S --noconfirm bat # pretty colored cat alternative
yay -S --noconfirm gum # very nice bash library for user inputs: https://github.com/charmbracelet/gum
yay -S --noconfirm aria2 # fast wget

# KDE connect
# ----------------------------------------------
yay -S --noconfirm kdeconnect

# configure KDE
# ----------------------------------------------
# - Global theme: Ant-Dark KDE
# - Colors: Breeze Dark
# - Application Style: Breeze
# - Window decoration: Large icon size
# - Icons: Papirus Dark (Install papirus and it will have a dark option once installed)
# - Splash screen: Kuro the cat
# - Login screen: Ant-Dark-Plasma-6

# reuse our synchronized config files
# ----------------------------------------------
rm -fr .config/ && ln -s ~/dev/auliyaarc/linux/endeavouros/config/ ~/.config

# smb4k connects out samba share
# ----------------------------------------------
yay -S --noconfirm smb4k

# Add your shares in the **Network Neighborhood** tab > **Open Mount Dialog (Ctrl+O)** then bookmark your shares.
# For each share, you can right click > **Add custom settings** and check the **Always remount this share** option to ensure they are mounted on startup.
# Add smb4k to the autostart list of applications. Use the wrapper script in this repository's autostart folder if you want it to start minimized

# OBS
# ----------------------------------------------
yay -S --noconfirm obs-studio obs-scene-as-transition

# Fan control
# ----------------------------------------------
yay --noconfirm -S coolercontrol
sudo modprobe nct6775
sudo sensors-detect --auto
sudo systemctl enable coolercontrold
sudo systemctl restart coolercontrold

# RGB control
# ----------------------------------------------
yay -S --noconfirm openrgb

# Add control for the XG279Q in the main menu
# ----------------------------------------------
mkdir -p ~/.local/share/applications/
cp ~/dev/auliyaarc/xg279q-control/xg279q-control.desktop ~/.local/share/applications/

# Plymouth
# ----------------------------------------------
yay -S --noconfirm plymouth
echo 'add_dracutmodules+=" plymouth "' | sudo tee /etc/dracut.conf.d/plymouth.conf

# Append the following to /etc/kernel/cmdline:
# splash

# set the theme
yay -S --noconfirm plymouth-theme-arch-os
sudo plymouth-set-default-theme arch-os

# ASUS motherboards sensor module
# ----------------------------------------------
cat << EOF | sudo tee /etc/modules-load.d/nct6775.conf
# Load nct6775.ko at boot (ASUS motherboards sensor)
nct6775
EOF

# Steam
# ----------------------------------------------
yay -S --noconfirm steam

# as described here: https://askubuntu.com/questions/1356884/why-is-x86-split-lock-detection-spamming-my-syslog-when-steam-is-running
# steam uses split locks and this spams the kernel logs
# add this to /etc/kernel/cmdline
# split_lock_detect=off

# Bottles
# ----------------------------------------------
# Bottles allow you to manage separate Wine installations and can be used for either gaming or other desktop applications.
# we use wine-staging as it provides additional patches and the codebase is rebased over the wine repo so versions are synchronized
yay -S --noconfirm wine-staging winetricks wine-mono bottles
yay -S --needed --asdeps --noconfirm giflib lib32-giflib gnutls lib32-gnutls v4l-utils lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib sqlite lib32-sqlite libxcomposite lib32-libxcomposite ocl-icd lib32-ocl-icd libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader sdl2-compat lib32-sdl2-compat lib32-gamemode

# System tweaks for gaming
# ----------------------------------------------
# See https://wiki.archlinux.org/title/Gaming#Starting_games_in_a_separate_X_server
# Increase vm.max_map_count
echo 'vm.max_map_count = 2147483642' | sudo tee /etc/sysctl.d/00-gamecompatibility.conf

# Cheat engines
# ----------------------------------------------
yay -S --noconfirm gameconqueror pince

# FPS counter
# ----------------------------------------------
yay -S --noconfirm mangohud goverlay
# to launch a game with mangohud from steam, edit the launch option and set it to:
# MANGOHUD=1 %command%

# regenerate boot options and update initramfs
# ----------------------------------------------
sudo reinstall-kernels 

# and reboot
# ----------------------------------------------
sudo reboot
```

## Additional system setup

### multi-core makepkg  

Edit **/etc/makepkg.conf** and look for the **MAKEFLAGS** definition:

```
MAKEFLAGS="-j10"
```

### zen kernel

```
yay -S --noconfirm linux-zen linux-zen-headers
yay -R linux linux-headers # remove base kernel which is no longer needed
```

Then reboot and press **d** on the boot option you want to select by default.

### nvidia

[Source](https://linuxiac.com/nvidia-with-wayland-on-arch-setup-guide/)

**/etc/dracut.conf.d/nvidia.conf**:

```
omit_dracutmodules+=" kms "
force_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
```

**/etc/modules-load.d/nvidia.conf**:

```
nvidia nvidia_modeset nvidia_uvm nvidia_drm
```

**/etc/kernel/cmdline**

```
... nvidia_drm.modeset=1 nvidia_drm.fbdev=1 nvidia.NVreg_EnableGpuFirmware=0 ...
```

**/etc/environment**

```
...
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
```

```bash
nvidia-inst --32 # reinstall nvidia drivers via endeavour os script
sudo reinstall-kernels
```

### disable AMD integrated GPU

**/etc/dracut.conf.d/blacklist-amd.conf**

```
omit_dracutmodules+=" amdgpu "
```

### Kernel & boot entries

- systemd-boot entries are located in **/efi/loader/entries**
- Module options can be added in **/etc/dracut.conf.d/**
- Kernel command line is edited through **/etc/kernel/cmdline**
- Load modules at boot through files in **/etc/modules-load.d/**
- Rebuild kernel through the **reinstall-kernels** command

### swapfile creation

```bash
mkswap -U clear --size 8G --file /swapfile
swapon /swapfile
```

**/etc/fstab**:

```
/swapfile none swap defaults 0 0
```

## VirtualBox

```
yay -S --noconfirm virtualbox virtualbox-host-dkms virtualbox-guest-iso
# Guest additions ISO is in /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso
sudo gpasswd -a ${USER} vboxusers
sudo reboot
```

## Developer environment
 
### git config

**~/.gitconfig**:
```
[log]
  date = relative
[format]
  auliyaa = format:%C(auto,yellow)%h%C(auto,magenta)% G? %C(auto,blue)%ad %C(auto,green)%aN%C(auto,reset) %s%C(auto,red)% gD% D
```

Then setup an alias:
```bash
git config --global alias.hs "log --pretty=auliyaa"
git hs
```

Disable pager
```bash
git config --global core.pager cat
# to restore pager:
#git config --global --replace-all core.pager "less -F -X"
```

## Troubleshooting

### Running from a live USB environment

When booted in live usb (root has no password for eos live usb), open a terminal and mount your / partition somewhere, then:

```bash
arch-chroot /path/to/your/mountpoint
```

### Unresolved issues

##### Soundblaster X3

This one seems to cause freezes when login manager starts (no kayboard, no display)
Replacing it with a X4 seems to workaround the issue for now.
