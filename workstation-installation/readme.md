 
- [Workstation Installs](#workstation-installs)
  - [Intitial install](#intitial-install)
  - [Graphical Desktop Preferences](#graphical-desktop-preferences)
    - [General](#general)
    - [with Trackpad](#with-trackpad)
  - [Konsole setup](#konsole-setup)
  - [Configure Dolphine](#configure-dolphine)
  - [Configure Panel](#configure-panel)
  - [Configure apt-cacher-ng server](#configure-apt-cacher-ng-server)
  - [Passwordless sudo](#passwordless-sudo)
  - [apt cacher ng client config](#apt-cacher-ng-client-config)
  - [Packages installed](#packages-installed)
    - [From official repo](#from-official-repo)
  - [Add main user to groups](#add-main-user-to-groups)
  - [Docker configuration](#docker-configuration)
  - [DNS resolution](#dns-resolution)
    - [Ubuntu](#ubuntu)
    - [Debian/Raspbian](#debianraspbian)
    - [Restart services](#restart-services)
    - [Configure IPV6 disabled](#configure-ipv6-disabled)
  - [DNS/DHCP server for local homellab on RPI](#dnsdhcp-server-for-local-homellab-on-rpi)
  - [Additional packages](#additional-packages)
    - [Fonts](#fonts)
    - [Downloaded packages](#downloaded-packages)
  - [Configure sound](#configure-sound)
  - [Configure JAVA_HOME](#configure-java_home)
  - [Install raw packages](#install-raw-packages)
    - [VSCode](#vscode)
    - [Maven](#maven)
  - [Install snaps](#install-snaps)
  - [Setup Kubernetes on vms](#setup-kubernetes-on-vms)
    - [Current env](#current-env)
    - [Delete vms example](#delete-vms-example)
    - [Simple approach with microk8s](#simple-approach-with-microk8s)
    - [TLS Setyp](#tls-setyp)
      - [Generate Certificates Root CA](#generate-certificates-root-ca)
      - [Generate Key Pair and others](#generate-key-pair-and-others)
  - [Archived steps](#archived-steps)
    - [dnsmasq with Network Manager](#dnsmasq-with-network-manager)

# Workstation Installs

## Intitial install

* Install Kubuntu Ubuntu LTS 22.04
  * Minimal Install
  * Install thirdparty
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



## Configure apt-cacher-ng server

add at the end of
/etc/apt-cacher-ng/acng.conf

```
PassThroughPattern: ^(.*):443$
```


## Passwordless sudo

```
echo 'apham ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/nopwd
```

## apt cacher ng client config

/etc/apt/apt.conf.d/proxy

```
sudo bash -c 'cat > /etc/apt/apt.conf.d/proxy << _EOF_
Acquire::http::Proxy "http://192.168.8.100:3142";
_EOF_'

or

sudo bash -c 'cat > /etc/apt/apt.conf.d/proxy << _EOF_
Acquire::http::Proxy "http://work.lan:3142";
_EOF_'

```

optional
/etc/apt/apt.conf.d/no-cache

```
sudo bash -c 'cat > /etc/apt/apt.conf.d/no-cache << _EOF_
Acquire::http {No-Cache=True;};
_EOF_'
```

## Packages installed

### From official repo


```
sudo apt install ncdu git ansible docker.io python3-docker docker-compose apparmor tmux vim openjdk-17-jdk prometheus-node-exporter htop curl lshw rsync mediainfo ffmpeg python3-mutagen iperf dnsmasq imagemagick qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system libguestfs-tools bridge-utils libosinfo-bin jackd2 qjackctl pulseaudio-module-jack lsp-plugins-lv2 calf-plugins ardour v4l-utils flatpak snapd virt-manager mediainfo-gui v4l2loopback-utils easytag gimp avldrums.lv2 libreoffice-plasma libreoffice openssh-server linux-tools-common linux-tools-generic freeplane ifuse libimobiledevice-utils xournal inkscape npm rpi-imager apt-cacher-ng skopeo golang-go dnsutils bmon lm-sensors psensor
```

ubuntu 22.10

```
sudo apt install ncdu git ansible docker.io python3-docker docker-compose apparmor tmux vim openjdk-17-jdk prometheus-node-exporter htop curl lshw rsync mediainfo ffmpeg python3-mutagen iperf dnsmasq imagemagick qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system libguestfs-tools bridge-utils libosinfo-bin lsp-plugins-lv2 calf-plugins ardour v4l-utils flatpak virt-manager mediainfo-gui v4l2loopback-utils easytag gimp avldrums.lv2 openssh-server linux-tools-common linux-tools-generic freeplane ifuse libimobiledevice-utils xournal inkscape npm rpi-imager apt-cacher-ng skopeo golang-go dnsutils bmon lm-sensors psensor qpwgraph
```

minimalistic micro server
```
sudo apt install git ansible docker.io python3-docker apparmor tmux vim openjdk-17-jdk-headless prometheus-node-exporter curl rsync dnsmasq ncdu  dnsutils bmon lm-sensors
```

minimalistic micro server on kvm
```
sudo apt install git ansible docker.io python3-docker apparmor tmux vim openjdk-17-jdk-headless prometheus-node-exporter curl rsync ncdu  dnsutils bmon lm-sensors

```

## Add main user to groups

```
sudo adduser apham libvirt
sudo adduser apham docker
sudo adduser apham audio
```


## Docker configuration

```
sudo bash -c 'cat > /etc/docker/daemon.json << _EOF_
{
    "insecure-registries" : ["registry.work.lan", "registry.awon.lan"],
    "dns": ["172.17.0.1"]
}
_EOF_'

sudo systemctl restart docker

```

```
docker network create --driver=bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 primenet
```

on raspberry pu

```
sudo vi /boot/cmdline.txt
// add at the end of the line:
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

## DNS resolution

Configure dnsmasq

```
sudo bash -c 'cat > /etc/dnsmasq.d/dev.conf << _EOF_
# /etc/dnsmasq.d/dev.conf
listen-address=127.0.0.1,172.17.0.1

address=/${HOSTNAME}.lan/172.17.0.1
address=/${HOSTNAME}.lan/172.18.0.1
address=/${HOSTNAME}.lan/192.168.122.1
address=/kube.loc/192.168.122.10
address=/sandbox.lan/192.168.122.30

#server=/lan/192.168.8.254
_EOF_'
```

make dnsmasq start after docker

```
[Unit]
Description=dnsmasq - A lightweight DHCP and caching DNS server
Requires=network.target
Wants=nss-lookup.target
Before=nss-lookup.target
After=network.target docker.service

[Service]
Type=forking
PIDFile=/run/dnsmasq/dnsmasq.pid

# Test the config file and refuse starting if it is not valid.
ExecStartPre=/etc/init.d/dnsmasq checkconfig

# We run dnsmasq via the /etc/init.d/dnsmasq script which acts as a
# wrapper picking up extra configuration files and then execs dnsmasq
# itself, when called with the "systemd-exec" function.
ExecStart=/etc/init.d/dnsmasq systemd-exec

# The systemd-*-resolvconf functions configure (and deconfigure)
# resolvconf to work with the dnsmasq DNS server. They're called like
# this to get correct error handling (ie don't start-resolvconf if the
# dnsmasq daemon fails to start).
ExecStartPost=/etc/init.d/dnsmasq systemd-start-resolvconf
ExecStop=/etc/init.d/dnsmasq systemd-stop-resolvconf


ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target

```

```
sudo systemctl reload  dnsmasq.service 
sudo systemctl restart dnsmasq.service
```

### Ubuntu

On Ubuntu : configure systemd-resolved, set dns as  to point to 127.0.0.1 as dns server & use dnsmasq

```
sudo bash -c 'cat > /etc/systemd/resolved.conf << _EOF_
# /etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
_EOF_'

```

### Debian/Raspbian

On Raspbian or Debian : configure dhcpd/dhclient to prepend 127.0.0.1 & use dnsmasq

```
#/etc/dhcp/dhclient.conf

prepend domain-name-servers 127.0.0.1;
```

### Restart services

```
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

sudo systemctl enable systemd-resolved 
sudo systemctl restart systemd-resolved 

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq
```

### Configure IPV6 disabled

```
sudo bash -c 'cat > /etc/sysctl.d/10-noipv6.conf << _EOF_
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
_EOF_'

```

alternative with grub

```
sudo vi /etc/default/grub

GRUB_CMDLINE_LINUX='ipv6.disable=1'

sudo update-grub
```

## DNS/DHCP server for local homellab on RPI

```
sudo vi /etc/dhcpcd.conf

# Example static IP configuration:
interface eth0
static ip_address=192.168.8.254/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
static routers=192.168.8.1
static domain_name_servers=192.168.8.1

sudo vi /etc/dnsmasq.conf

#range for dhcp
dhcp-range=192.168.8.8,192.168.8.253,255.255.255.0,12h

#dns server to publish we use the internet boxes by default for better relability
dhcp-option=option:dns-server,192.168.8.1

#fixed dhcp reservation
dhcp-host=9c:8e:99:e6:f3:3b,awon.lan,192.168.8.100,infinite

```


## Additional packages

### Fonts

Copy fonts to `/usr/local/share/fonts/`

- https://dtinth.github.io/comic-mono-font/
- https://github.com/gidole/Gidole-Typefaces/blob/master/gidole.zip
- https://github.com/RedHatOfficial/Overpass/releases

### Downloaded packages

```
google-chrome-stable_current_amd64.deb slack-desktop-4.25.0-amd64.deb noise-repellent_0.1.5-1kxstudio2_amd64.deb
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

ACTION=="add", SUBSYSTEM=="sound", DEVPATH=="/devices/pci0000:00/0000:00:14.0/usb?/?-1/?-1:1.0/sound/card?", ATTR{id}="s2i2"
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
curl -L -o /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
sudo tar xzvf /tmp/maven.tar.gz  -C /opt/appimages/
sudo ln -s /opt/appimages/apache-maven-3.8.6/bin/mvn /usr/local/bin/mvn
```

Think about customizing settings.xml if needed


## Install snaps

```
sudo snap install obs-studio
sudo snap install dbeaver-ce postman sweethome3d-homedesign blender helm
sudo snap install drawio
sudo snap install teams zoom-client
sudo snap install firefox
```

## Setup Kubernetes on vms

### Current env

```

ssh-keygen -f ~/.ssh/vm

```

```

debianimage=debian-10-genericcloud-amd64-20220911-1135

vmcreate master 4096 4 $debianimage 10 40G 40G debian10
vmcreate node01 4096 4 $debianimage 11 40G 40G debian10
vmcreate node02 4096 4 $debianimage 12 40G 40G debian10
vmcreate node03 4096 4 $debianimage 13 40G 40G debian10





vmcreate master 4096 4 ubuntu-22.04-server-cloudimg-amd64 10 40G 40G ubuntu22.04
vmcreate node01 4096 4 ubuntu-22.04-server-cloudimg-amd64 11 40G 40G ubuntu22.04
vmcreate node02 4096 4 ubuntu-22.04-server-cloudimg-amd64 12 40G 40G ubuntu22.04
vmcreate node03 4096 4 ubuntu-22.04-server-cloudimg-amd64 13 40G 40G ubuntu22.04


vmcreate sandbox 4096 4 ubuntu-22.04-server-cloudimg-amd64-20221018 30 40G 10G ubuntu22.04


```


### Delete vms example

```
dvm master
dvm node01
dvm node02
dvm node03

dvm sandbox

```

### Simple approach with microk8s

```

sudo snap install microk8s --channel=1.24/stable --classic
sudo usermod -a -G microk8s apham

```

### TLS Setyp

#### Generate Certificates Root CA

```

rootcakeyfile=/home/apham/apps/tls/work.lan-root-ca.key
rootcacertfile=/home/apham/apps/tls/work.lan-root-ca.pem

cahostname=work.lan

tagethostname=cipi.lan
keystorefile=/home/apham/apps/tls/${tagethostname}.p12
keyfile=/home/apham/apps/tls/${tagethostname}.key
certfile=/home/apham/apps/tls/${tagethostname}.pem
signreqfile=/home/apham/apps/tls/${tagethostname}.csr
signconffile=/home/apham/apps/tls/${tagethostname}.cnf
truststorefile=/home/apham/apps/tls/${tagethostname}-truststore.p12

openssl genrsa -out ${rootcakeyfile} 4096

openssl req -x509 -new -nodes \
  -key $rootcakeyfile \
  -sha256 \
  -days 365000 \
  -subj "/CN=*.${targethostname}" \
  -out $rootcacertfile

```

#### Generate Key Pair and others

```

keytool -genkey \
  -alias $tagethostname  \
  -storepass password \
  -keyalg RSA \
  -keysize 4096 \
  -storetype PKCS12 \
  -dname "cn=*.${tagethostname}" \
  -ext "SAN=dns:${tagethostname},dns:*.${tagethostname}" \
  -validity 365000 \
  -keystore ${keystorefile}

openssl pkcs12 \
  -in ${keystorefile} \
  -nodes \
  -password pass:password -nocerts \
  -out $keyfile

keytool -certreq \
  -alias $tagethostname \
  -storepass password \
  -storetype PKCS12 \
  -noprompt \
  -keystore ${keystorefile} \
  > $signreqfile

cat > ${signconffile} << _EOF_
# Extensions to add to a certificate request
basicConstraints       = CA:FALSE
authorityKeyIdentifier = keyid:always, issuer:always
keyUsage               = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
subjectAltName         = @alt_names
[ alt_names ]
DNS.1 = *.${tagethostname}
_EOF_

openssl x509 -req \
  -in $signreqfile \
  -CA $rootcacertfile \
  -CAkey $rootcakeyfile  \
  -CAcreateserial \
  -days 365000 -sha256  \
  -extfile $signconffile \
  -out $certfile

keytool -import \
  -alias ${tagethostname}-root-ca \
  -storepass password \
  -storetype PKCS12 \
  -noprompt \
  -keystore $keystorefile \
  -file $rootcacertfile

  keytool -import \
    -alias ${tagethostname} \
    -storepass password \
    -storetype PKCS12 \
    -noprompt \
    -keystore $keystorefile \
    -file $certfile

  keytool -import \
    -alias ${tagethostname}-root-ca \
    -storepass password \
    -storetype PKCS12 \
    -noprompt \
    -keystore $truststorefile \
    -file $rootcacertfile

```



## Archived steps

### dnsmasq with Network Manager

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
listen-address=127.0.0.1,172.17.0.1,172.18.0.1
address=/${HOSTNAME}.lan/172.17.0.1
address=/${HOSTNAME}.lan/172.18.0.1
address=/${HOSTNAME}.lan/192.168.122.1
address=/kube.loc/192.168.122.10
address=/sandbox.lan/192.168.122.30

server=/lan/192.168.8.254
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
/!\ END Archived steps
