 
- [Workstation Installs](#workstation-installs)
  - [Intitial install](#intitial-install)
  - [Graphical Desktop Preferences](#graphical-desktop-preferences)
    - [General](#general)
    - [with Trackpad](#with-trackpad)
  - [Konsole setup](#konsole-setup)
  - [Configure Dolphine](#configure-dolphine)
  - [Configure Panel](#configure-panel)
  - [Packages installed](#packages-installed)
    - [From official repo](#from-official-repo)
    - [Downloaded packages](#downloaded-packages)
  - [Add main user to groups](#add-main-user-to-groups)
  - [Configure sound](#configure-sound)
  - [Docker configuration](#docker-configuration)
  - [Configure JAVA_HOME](#configure-java_home)
  - [Install raw packages](#install-raw-packages)
    - [VSCode](#vscode)
    - [Maven](#maven)
  - [Install snaps](#install-snaps)

# Workstation Installs

## Intitial install

* Install Kubuntu Ubuntu LTS 22.04
  * Minimal Install
  * choose Graphics
  * KDE Plasma
  * SSH server
  * Standard utils


## Graphical Desktop Preferences

### General

Go to system settings

* Appearance -> Global Theme
  * Choose Breeze Dark
* Workspace Behavior -> Virtual Desktop
  * 2 rows, 4 Desktops
* Workspace Behavior -> General Behavior
  *  Double-click to open files and folders
*  Start up and shutdown -> Login Screen
   *  Choose Chilli for Plasma
*  Start up and shutdown -> Desktop Session
   *  Start with an empty
*  Display and Monitor -> Compositor
   *  disable "enable compositor on startup"
*  (optional )Application Style -> Windows Decorations
   *  Uncheck Use themes default border size
   *  normal size
*  Input Devices -> Keyboard
   *  Numlock on Plasma startup = Turn On

### with Trackpad

* Input Devices -> Touchpad
  * Mouse Click Emulation

## Konsole setup

* create default profile
  * General
    * /bin/bash
    * start in sale directory as current session
    * size 150 30
  * Appearance
    * Green on Black
    * Font Hack 12
  * Scrolling
    * Unlimited

## Configure Dolphine

* Startup
  * Show on startup
    * /home/apham
  * Check Show full path inside location bar
  * Uncheck Open new folders in tabs
* Switch to detailed view
* Add type column
* Show terminal
* Show infos

## Configure Panel

* Switch to task manger rather than icon only
* height 60
* always 2 rows


## Packages installed

### From official repo


```
ncdu git ansible docker.io docker-compose apparmor tmux vim openjdk-11-jdk prometheus-node-exporter htop curl lshw rsync mediainfo ffmpeg python3-mutagen iperf dnsmasq qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system bridge-utils libosinfo-bin jackd2 qjackctl pulseaudio-module-jack lsp-plugins-lv2 calf-plugins ardour v4l-utils flatpak snapd virt-manager mediainfo-gui v4l2loopback-utils easytag gimp avldrums.lv2 libreoffice-plasma libreoffice openssh-server linux-tools-common linux-tools-generic freeplane
```

### Downloaded packages


```
google-chrome-stable_current_amd64.deb zoom_amd64.deb slack-desktop-4.25.0-amd64.deb noise-repellent_0.1.5-1kxstudio2_amd64.deb
```

## Add main user to groups

```
sudo adduser apham libvirt
sudo adduser apham docker
sudo adduser apham audio
```

## Configure sound

List usb sound card devices and fix their names

```
udevadm info -ap /sys/class/sound/card<number>

ls /devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6.2/3-6.2.4/3-6.2.4:1.0/sound/
```

Create file with following content

```
ACTION=="add", SUBSYSTEM=="sound", DEVPATH=="/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6.2/3-6.2.3/3-6.2.3:1.0/sound/card?", ATTR{id}="dock"

ACTION=="add", SUBSYSTEM=="sound", DEVPATH=="/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/sound/card?", ATTR{id}="s2i2"
```

Copy to rules folders and reload reboot

```
sudo cp 70-my-sound-cards.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo reboot now
```

Configure qjackctl

```
SETTINGS

Interface : hw:s2i2
Sample Rate : 48000
Frames/Period : 2048
Periods/Buffer : 4


OPTIONS

Execute script on Startup : pacmd suspend true
Execute script after Startup : /home/workdrive/tazone/dev-environment/qjackctl-scripts/qjacktctl-after-startup.sh
Execute script after Shutdown : pacmd suspend false
```

## Docker configuration

```
sudo bash -c 'cat > /etc/docker/daemon.json << _EOF_
{
    "insecure-registries" : ["registry.hpel.lan" ,"registry.work.lan"],
    "dns": ["192.168.8.254", "8.8.8.8"]
}
_EOF_'

sudo systemctl restart docker

```

```
docker network create --driver=bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 primenet
```

```
sudo bash -c 'cat > /etc/NetworkManager/conf.d/00-use-dnsmasq.conf << _EOF_
# /etc/NetworkManager/conf.d/00-use-dnsmasq.conf
#
# This enabled the dnsmasq plugin.
[main]
dns=dnsmasq
_EOF_'


sudo bash -c 'cat > /etc/NetworkManager/dnsmasq.d/dev.conf << _EOF_
#/etc/NetworkManager/dnsmasq.d/dev.conf
address=/${HOSTNAME}.lan/127.0.0.1
_EOF_'

```

disable running dnsmasq

```
sudo systemctl stop dnsmasq
sudo systemctl disable dnsmasq

```

disable systemd-resolved

```
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo rm /etc/resolv.conf
sudo touch /etc/resolv.conf
```

restart network manager

```
sudo systemctl restart NetworkManager
```

## Configure JAVA_HOME

```
sudo bash -c 'cat > /etc/profile.d/java_home.sh << _EOF_
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
_EOF_'

```


## Install raw packages

### VSCode

version 1.57.1

install settings sync and sync with gist

### Maven

```
curl -L -o /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz
sudo tar xzvf /tmp/maven.tar.gz  -C /opt/appimages/
sudo ln -s /opt/appimages/apache-maven-3.8.5/bin/mvn /usr/local/bin/mvn
```

Think about customizing settings.xml if needed


## Install snaps

```
sudo snap install obs-studio
sudo snap install dbeaver-ce postman sweethome3d-homedesign 
```

