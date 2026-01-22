
# Arch Linux installation notes

## Base software

```bash
yay -S --noconfirm filelight discord dropbox vlc vlc-plugin-ffmpeg vlc-plugins-all git visual-studio-code-bin yakuake python-pip python gitkraken veracrypt python-pygments jq zip unzip kolourpaint onlyoffice-bin nano-syntax-highlighting python-tabulate hardinfo ytmdesktop-bin
```

## shell utils

```bash
yay -S --noconfirm bat # pretty colored cat alternative
yay -S --noconfirm gum # very nice bash library for user inputs: https://github.com/charmbracelet/gum
yay -S --noconfirm aria2 # fast wget
```

## KDE configuration

- Global theme: Ant-Dark KDE
- Colors: Breeze Dark
- Application Style: Breeze
- Window decoration: Large icon size
- Icons: Papirus Dark
- Splash screen: Kuro the cat

### KDE Connect

```bash
yay -S --noconfirm kdeconnect
```

## SDDM

SSDM configuration is available in KDE (login screen (SDDM))

## Samba shares

**smb4k** can be used to add persistent mounts of samba shares:

```bash
yay -S --noconfirm smb4k
```

Add your shares in the **Network Neighborhood** tab > **Open Mount Dialog** then bookmark your shares.
For each share, you can right click > **Add custom settings** and check the **Always remount this share** option to ensure they are mounted on startup.

Add smb4k to the autostart list of applications. Use the wrapper script in this repository's autostart folder if you want it to start minimized

## OBS

```bash
yay -S --noconfirm obs-studio obs-scene-as-transition
```

## System setup

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
# the following packages should be installed:
# egl-gbm
# egl-wayland
# egl-x11
# ffnvcodec-headers
# lib32-nvidia-utils
# libvdpau
# ibxnvctrl
# nvidia-hook
# nvidia-inst
# nvidia-open-dkms
# nvidia-settings
# nvidia-utils
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

### Fan control

```bash
yay --noconfirm -S coolercontrol
sudo modprobe nct6775
sudo sensors-detect --auto
sudo systemctl enable coolercontrold
sudo systemctl restart coolercontrold
```

**/etc/modules-load.d/nct6775.conf**:
```
# Load nct6775.ko at boot (ASUS motherboards sensor)
nct6775
```

### swapfile creation

```bash
mkswap -U clear --size 8G --file /swapfile
swapon /swapfile
```

**/etc/fstab**:

```
/swapfile none swap defaults 0 0
```

### system LEDs

```bash
yay -S openrgb
```

### Power-off USB on shutdown

Look in systemd/usboff and use install.bash

### Control monitor inputs

```bash
mkdir -p ~/.local/share/applications/
cp xg279q-control/xg279q-control.desktop ~/.local/share/applications/
```

## Plymouth

systemd-boot entries are located in **/efi/loader/entries**

```bash
yay -S --noconfirm plymouth
```

**/etc/dracut.conf.d/plymouth.conf**:

```
add_dracutmodules+=" plymouth "
```

Append to **/etc/kernel/cmdline**
```
... splash
```

Now set the theme and rebuild initramfs:

```bash
yay -S --noconfirm plymouth-theme-arch-os
sudo plymouth-set-default-theme arch-os
sudo reinstall-kernels # regenerate boot options and update initramfs
``` 

## Gaming

### Steam

```
yay -S --noconfirm steam
```

If steam window does not show on startup, install **lib32-nvidia-utils**:

```bash
yay -S --noconfirm lib32-nvidia-utils
```

If you need to run steam from CLI with logs:

```bash
steam --help
```

#### Steam spamming dmesg with x86/split lock detection messages

As described [here](https://askubuntu.com/questions/1356884/why-is-x86-split-lock-detection-spamming-my-syslog-when-steam-is-running), this is due to steam using split locks while this is discouraged by the kernel.

You can let the kernel ignore those events (old behavior) by adding the following kernel command line option in **/etc/kernel/cmdline**:

```
... split_lock_detect=off ...
```

And then rebuild your initramfs:

```bash
sudo reinstall-kernels # regenerate boot options and update initramfs
``` 

### Bottles

Bottles allow you to manage separate Wine installations and can be used for either gaming or other desktop applications.

```bash
# we use wine-staging as it provides additional patches and the codebase is rebased over the wine repo so versions are synchronized
yay -S --noconfirm wine-staging winetricks wine-mono bottles
yay -S --needed --asdeps --noconfirm giflib lib32-giflib gnutls lib32-gnutls v4l-utils lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib sqlite lib32-sqlite libxcomposite lib32-libxcomposite ocl-icd lib32-ocl-icd libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader sdl2-compat lib32-sdl2-compat lib32-gamemode
```

### system tweaks

see [this page](https://wiki.archlinux.org/title/Gaming#Starting_games_in_a_separate_X_server) for reference

#### Increase vm.max_map_count

**/etc/sysctl.d/00-gamecompatibility.conf**:

```
vm.max_map_count = 2147483642
```

### Cheat engine

```
yay -S --noconfirm gameconqueror pince
```

### FPS counter

Install **mangohud** and its UI configurator, **goverlay**:

```bash
yay -S --noconfirm mangohud goverlay
```

To launch a game with mangohud from steam, edit the launch option and set it to:

```
MANGOHUD=1 %command%
```

### Deprecated

#### Cartridges (Simple GUI to manage all games)

```bash
yay -S --noconfirm cartridges
```

#### Lutris (Epic, GOG.com, Amazon games, Ubisoft)

```bash
sudo pacman -S wine-staging
sudo pacman -S --needed --asdeps giflib lib32-giflib gnutls lib32-gnutls v4l-utils lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib sqlite lib32-sqlite libxcomposite lib32-libxcomposite ocl-icd lib32-ocl-icd libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader sdl2-compat lib32-sdl2-compat lib32-gamemode

yay -S --noconfirm lutris wine winetricks lib32-gnutls
```

#### EGS

If the EGS fails to update, you may need to manually copy update files:

```bash
yes | cp -fr ~/Games/epic-games-store/drive_c/ProgramData/Epic/EpicGamesLauncher/Data/Update/Install/* ~/Games/epic-games-store/drive_c/Program\ Files\ \(x86\)/Epic\ Games/Launcher/
```

## VirtualBox

```
yay -S --noconfirm virtualbox virtualbox-host-dkms virtualbox-guest-iso
# Guest additions ISO is in /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso
sudo gpasswd -a ${USER} vboxusers
sudo reboot
```

## Developer environment
 

### Global gitignore

```bash
touch ~/.gitignore_global
git config --global core.excludesFile '~/.gitignore_global'
```

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

### Yakuake 

- Color theme: bl1nk
- Font: Hack 14pt

### Discord

Disable updates in **~/.config/discord/settings.json**:

```json
{
 "SKIP_HOST_UPDATE": true
}
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
