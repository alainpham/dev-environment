 
- [Workstation Installs](#workstation-installs)
  - [Intitial install](#intitial-install)
  - [Sound](#sound)
  - [Graphical Desktop Preferences](#graphical-desktop-preferences)
    - [General](#general)
    - [with Trackpad](#with-trackpad)
  - [Konsole setup](#konsole-setup)
  - [Configure Dolphine](#configure-dolphine)
  - [Configure Panel](#configure-panel)
  - [Configure apt-cacher-ng server](#configure-apt-cacher-ng-server)
  - [Passwordless sudo](#passwordless-sudo)
  - [Redirect ssh keys to non default folder](#redirect-ssh-keys-to-non-default-folder)
  - [apt cacher ng client config](#apt-cacher-ng-client-config)
  - [Packages installed](#packages-installed)
    - [From official repo](#from-official-repo)
  - [Add main user to groups](#add-main-user-to-groups)
  - [Start virsh network](#start-virsh-network)
  - [Revert back to pulse + jack](#revert-back-to-pulse--jack)
  - [Docker configuration](#docker-configuration)
  - [DNS resolution](#dns-resolution)
    - [Debian/Raspbian](#debianraspbian)
    - [Restart services if on ubuntu with systemd](#restart-services-if-on-ubuntu-with-systemd)
  - [Git config](#git-config)
  - [KVM scripts](#kvm-scripts)
  - [Additional packages](#additional-packages)
    - [Fonts](#fonts)
    - [Downloaded packages](#downloaded-packages)
  - [Configure JAVA\_HOME](#configure-java_home)
  - [Install raw packages](#install-raw-packages)
    - [VSCode](#vscode)
    - [Maven](#maven)
  - [Some optional packages](#some-optional-packages)
  - [Install snaps (snaps don't work great ignore this...)](#install-snaps-snaps-dont-work-great-ignore-this)
  - [Setup Kubernetes on vms](#setup-kubernetes-on-vms)
    - [Current env](#current-env)
    - [Delete vms example](#delete-vms-example)
    - [Simple approach with microk8s](#simple-approach-with-microk8s)
  - [TLS Setyp](#tls-setyp)
    - [Generate Certificates Root CA](#generate-certificates-root-ca)
    - [Generate Key Pair and others](#generate-key-pair-and-others)
  - [Predownload docker images](#predownload-docker-images)
  - [Pipewire virtual sinks](#pipewire-virtual-sinks)
- [audio sink from desktop](#audio-sink-from-desktop)
- [audio sink from caller](#audio-sink-from-caller)
- [audio sink mix to caller](#audio-sink-mix-to-caller)
- [connect from-desktop to to-caller-sink](#connect-from-desktop-to-to-caller-sink)
    - [CONNECT PHYSICAL DEVICES](#connect-physical-devices)
- [connect from-desktop to speakers](#connect-from-desktop-to-speakers)
- [connect from-caller to speakers](#connect-from-caller-to-speakers)
- [split mic into 2](#split-mic-into-2)
- [connect microphone to to-caller-sink](#connect-microphone-to-to-caller-sink)
- [set proper mic volume](#set-proper-mic-volume)
- [/etc/NetworkManager/conf.d/00-use-dnsmasq.conf](#etcnetworkmanagerconfd00-use-dnsmasqconf)
- [](#)
- [This enabled the dnsmasq plugin.](#this-enabled-the-dnsmasq-plugin)
- [Example static IP configuration:](#example-static-ip-configuration)

# Workstation Installs

## Intitial install

* Install Kubuntu Ubuntu LTS 22.04
  * Minimal Install
  * Install thirdparty
  * choose Graphics
  * KDE Plasma
  * SSH server
  * Standard utils

## Sound

disable powersave on sound chich procuces  crackling does not apply to ubuntu studio 23.04

```

cat /sys/module/snd_hda_intel/parameters/power_save

sudo bash -c 'cat > /etc/modprobe.d/audio_disable_powersave.conf << _EOF_
options snd_hda_intel power_save=0
_EOF_'
```

## Graphical Desktop Preferences

### General

Go to system settings

* Appearance -> Global Theme
  * Choose Breeze Dark
* Workspace Behavior -> Virtual Desktop
  * 2 rows, 4 Desktops
* Workspace Behavior -> General Behavior
  * Clicking files selects them
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
  * Tap to click

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
* height 80
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

echo 'apham ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo -f /etc/customsudo/nopwd


```

## Redirect ssh keys to non default folder

```
bash -c 'cat > ~/.ssh/config << _EOF_
Host *
IdentityFile ~/.sshvm/id_rsa
_EOF_'
```


## apt cacher ng client config

/etc/apt/apt.conf.d/proxy

```
sudo bash -c 'cat > /etc/apt/apt.conf.d/proxy << _EOF_
Acquire::http::Proxy "http://192.168.8.100:3142";
_EOF_'

or for virtual machines on kvm

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


sound


debian 12

```
sudo apt install ncdu git ansible docker.io python3-docker docker-compose apparmor tmux vim openjdk-17-jdk prometheus-node-exporter htop curl lshw rsync mediainfo ffmpeg python3-mutagen iperf3 dnsmasq imagemagick qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system libguestfs-tools bridge-utils libosinfo-bin lsp-plugins-lv2 calf-plugins ardour v4l-utils flatpak virt-manager mediainfo-gui v4l2loopback-utils easytag gimp avldrums.lv2 openssh-server freeplane ifuse libimobiledevice-utils xournal inkscape npm apt-cacher-ng skopeo golang-go dnsutils bmon lm-sensors psensor apt-transport-https genisoimage obs-studio haruna snapd 

sudo apt install pulseaudio-module-jack jackd qjackctl kdenlive pulsemixer pulseeffects linux-cpupower

sudo apt install nvidia-detect 
sudo apt install nvidia-driver 


```

Windows wsl ubuntu

```
sudo apt install ncdu docker.io ansible docker-compose openjdk-17-jdk prometheus-node-exporter ffmpeg python3-mutagen iperf3 imagemagick skopeo bmon


 /etc/profile.d/keep_wsl_running.sh
eval $(keychain -q)
```



ubuntu 22.04 dekstop

```
sudo apt install ncdu git ansible docker.io python3-docker docker-compose apparmor tmux vim openjdk-17-jdk prometheus-node-exporter htop curl lshw rsync mediainfo ffmpeg python3-mutagen iperf3 dnsmasq imagemagick qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system libguestfs-tools bridge-utils libosinfo-bin lsp-plugins-lv2 calf-plugins ardour v4l-utils flatpak virt-manager mediainfo-gui v4l2loopback-utils easytag gimp avldrums.lv2 openssh-server linux-tools-common linux-tools-generic freeplane ifuse libimobiledevice-utils xournal inkscape npm rpi-imager apt-cacher-ng skopeo golang-go dnsutils bmon lm-sensors psensor apt-transport-https genisoimage obs-studio
```

kubuntu  23.04 dekstop + ubnuntu studio jack pulse

```
sudo apt install ncdu git ansible docker.io python3-docker docker-compose apparmor tmux vim openjdk-17-jdk prometheus-node-exporter htop curl lshw rsync mediainfo ffmpeg python3-mutagen iperf3 dnsmasq imagemagick qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system libguestfs-tools bridge-utils libosinfo-bin lsp-plugins-lv2 calf-plugins ardour v4l-utils flatpak virt-manager mediainfo-gui v4l2loopback-utils easytag gimp avldrums.lv2 openssh-server linux-tools-common linux-tools-generic freeplane ifuse libimobiledevice-utils xournal inkscape npm rpi-imager apt-cacher-ng skopeo golang-go dnsutils bmon lm-sensors psensor qpwgraph apt-transport-https genisoimage obs-studio
```


minimalistic micro server on ubuntu or debian physical machines
```
sudo apt install git ansible docker.io python3-docker docker-compose skopeo apparmor tmux vim openjdk-17-jdk-headless prometheus-node-exporter curl rsync dnsmasq ncdu dnsutils bmon lm-sensors
```

minimalistic micro server on kvm ubuntu or debian

```
sudo apt install git ansible docker.io python3-docker docker-compose skopeo apparmor tmux vim openjdk-17-jdk-headless prometheus-node-exporter curl rsync ncdu  dnsutils bmon lm-sensors
```

minimal debian 11 kubernetes host
```console
apt install sudo
```

## Add main user to groups

```
sudo adduser $USER libvirt
sudo adduser $USER docker
sudo adduser $USER audio
sudo adduser $USER pipewire
```

## Start virsh network

```
sudo virsh net-autostart default
sudo virsh net-start default
```

## Revert back to pulse + jack

```
sudo apt install pulseaudio pulseaudio-module-jack jackd qjackctl

sudo systemctl --global --now disable pipewire-pulse.service pipewire-pulse.socket wireplumber.service pipewire.service pipewire.socket
```

## Docker configuration

```
sudo bash -c 'cat > /etc/docker/daemon.json << _EOF_
{
  "log-opts": {
    "max-size": "50m",
    "max-file": "2" 
  }
}
_EOF_'

sudo systemctl restart docker
```

```
docker network create --driver=bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 primenet

docker plugin install grafana/loki-docker-driver:2.7.1 --alias loki --grant-all-permissions && sudo systemctl restart docker
```

on raspberry pi for getting cpu metrics in docker
```
sudo vi /boot/cmdline.txt
// add at the end of the line:
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

## DNS resolution




Configure dnsmasq


network manager

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
local=/aphm.duckdns.org/
local=/kebx.duckdns.org/
local=/vrbx.duckdns.org/

address=/aphm.duckdns.org/172.17.0.1
address=/aphm.duckdns.org/172.18.0.1
address=/aphm.duckdns.org/192.168.122.1
address=/kebx.duckdns.org/192.168.122.10
address=/vrbx.duckdns.org/192.168.122.30
_EOF_'

sudo systemctl disable systemd-resolved.service # not needed on debian12
sudo systemctl disable dnsmasq.service

sudo rm /etc/resolv.conf
sudo ln -s /run/NetworkManager/resolv.conf /etc/resolv.conf

sudo systemctl restart NetworkManager

```

certbot

```

sudo snap install --classic certbot

sudo cp ./../duckdns-scripts/duckdns.sh /usr/local/bin

mkdir -p /home/${USER}/apps

rm -rf /home/workdrive/apps/tls
mkdir -p /home/workdrive/apps/tls
ln -s /home/workdrive/apps/tls /home/${USER}/apps/tls




export duckdomain=vrbx.duckdns.org

export duckdomain=aphm.duckdns.org
export duckdomainraw=aphm.duckdns.org

export duckdomain=kebx.duckdns.org

export duckdomain=awon.cpss.duckdns.org

export duckdomain=bbee.cpss.duckdns.org
export duckdomainraw=cpss.duckdns.org

certbot certonly \
  --non-interactive \
  --agree-tos \
  --manual \
  --manual-auth-hook duckdns.sh \
  --email "$email" \
  --preferred-challenges dns \
  --config-dir /home/workdrive/apps/tls/cfg \
  --work-dir /home/workdrive/apps/tls/ \
  --logs-dir /home/workdrive/apps/tls/logs \
  -d "*.${duckdomain}"  -v



openssl pkcs12 -export -out /home/workdrive/apps/tls/cfg/live/${duckdomain}/privkey.p12  -in /home/workdrive/apps/tls/cfg/live/${duckdomain}/fullchain.pem -inkey /home/workdrive/apps/tls/cfg/live/${duckdomain}/privkey.pem -passin pass:password -passout pass:password


```




with docker host on ubuntu with resolved
```
sudo bash -c 'cat > /etc/dnsmasq.d/dev.conf << _EOF_
# /etc/dnsmasq.d/dev.conf
listen-address=127.0.0.1,172.17.0.1

address=/${HOSTNAME}.lan/172.17.0.1
address=/${HOSTNAME}.lan/172.18.0.1
address=/${HOSTNAME}.lan/192.168.122.1
address=/kube.loc/192.168.122.10
address=/sandbox.loc/192.168.122.30

_EOF_'

sudo bash -c 'cat > /etc/dnsmasq.d/res.conf << _EOF_
# /etc/dnsmasq.d/res.conf
resolv-file=/run/NetworkManager/no-stub-resolv.conf
_EOF_'

sudo bash -c 'cat > /etc/systemd/resolved.conf << _EOF_
# /etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
_EOF_'
```

for minimal kube host
```
sudo bash -c 'cat > /etc/dnsmasq.d/dev.conf << _EOF_
# /etc/dnsmasq.d/dev.conf
listen-address=127.0.0.1
_EOF_'
```

make dnsmasq start after docker and disable systemd command

```

sudo vi /lib/systemd/system/dnsmasq.service

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
# ExecStartPost=/etc/init.d/dnsmasq systemd-start-resolvconf
# ExecStop=/etc/init.d/dnsmasq systemd-stop-resolvconf


ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target

```

```
sudo systemctl daemon-reload
sudo systemctl restart dnsmasq.service
```

### Debian/Raspbian

On Raspbian or Debian : configure dhcpd/dhclient to prepend 127.0.0.1 & use dnsmasq
append to dhclient file
```
#/etc/dhcp/dhclient.conf

prepend domain-name-servers 127.0.0.1;
```

### Restart services if on ubuntu with systemd

```
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

sudo systemctl enable systemd-resolved 
sudo systemctl restart systemd-resolved 

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq
```

## Git config
```
git config --global user.email
git config --global core.editor "vim"
git config --global core.sshCommand "ssh -i ~/.sshvm/id_rsa"
```

## KVM scripts

```
sudo cp kvm-scripts/* /usr/local/bin/

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

## Configure JAVA_HOME

```
sudo bash -c 'cat > /etc/profile.d/java_home.sh << _EOF_
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
_EOF_'

```
## Install raw packages

### VSCode

sudo cp code-stable-x64-1678818101.tar.gz /opt/appimages/
cd /opt/appimages/
sudo tar xzvf code-stable-x64-1678818101.tar.gz
sudo ln -sf /opt/appimages/VSCode-linux-x64/code /usr/local/bin/code

version 1.57.1
version 1.74.3
install settings sync and sync with gist

List of plugins to install

* eclipse keymap
* extension pack for java
* markdown all in one
* language support for Apache Camel
* XML language support
* Yaml language support
* c/c++ extension pack
* golang

### Maven

```
sudo mkdir /opt/appimages/
mvnversion=3.9.5
curl -L -o /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/${mvnversion}/binaries/apache-maven-${mvnversion}-bin.tar.gz
sudo tar xzvf /tmp/maven.tar.gz  -C /opt/appimages/
sudo ln -s /opt/appimages/apache-maven-${mvnversion}/bin/mvn /usr/local/bin/mvn

```

Think about customizing settings.xml if needed


## Some optional packages

dbeaver and helm

```console
sudo snap install dbeaver-ce
sudo snap install helm --classic
sudo snap install blender --classic



or this for helm

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null

```


k9s
https://github.com/derailed/k9s/releases

```console
curl -LO https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
sudo tar -xzvf k9s_Linux_amd64.tar.gz  -C /usr/local/bin/ k9s
```

kubectl

```
curl -LO "https://dl.k8s.io/release/v1.27.6/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
```

rpi-imager

```

sudo snap install rpi-imager

```

yt-dlp

```

sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp

alias yt='yt-dlp -f "bestvideo[ext=mp4][vcodec^=avc1][height<=?1080][fps<=?30]+bestaudio[ext=m4a]" --embed-thumbnail -o "%(title)s.%(ext)s"'
```

google cloud

```

sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt-get update && sudo apt-get install google-cloud-cli


sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```

MLV APP

```

appname=mlvapp
appimageurl="https://github.com/ilia3101/MLV-App/releases/download/QTv1.14/MLV.App.v1.14.Linux.x86_64.AppImage"
appiconurl="https://github.com/alainpham/appp/raw/master/mlvapp/icon.png"

appimagefolder="/opt/appimages"
appimagepath=${appimagefolder}/${appname}/${appname}.AppImage
appiconpath=${appimagefolder}/${appname}/${appname}.png
appshortcutpath=/usr/share/applications/${appname}.desktop

echo "appname = $appname"
echo "appimageurl = $appimageurl"


echo "creating folder.."
sudo mkdir -p ${appimagefolder}/${appname}
echo "Downloading.."
sudo curl -L -o ${appimagepath} ${appimageurl}
sudo curl -L -o ${appiconpath} ${appiconurl}
sudo chmod 755 ${appimagepath}

echo "Creating link.."
sudo bash -c "cat > ${appshortcutpath} << _EOF_
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=${appname}
Comment=${appname}
Exec=${appimagepath}
Icon=${appiconpath}
Terminal=false
_EOF_"

```

kind kubernetes 

```console
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.18.0/kind-$(uname)-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
rm kind

kind completion bash | sudo tee /etc/bash_completion.d/kind > /dev/null


cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: localcloud

nodes:
- role: control-plane
  image: kindest/node:v1.25.8
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

## Install snaps (snaps don't work great ignore this...)

```
sudo snap install obs-studio
sudo snap install dbeaver-ce postman sweethome3d-homedesign blender helm
sudo snap install drawio
sudo snap install firefox
sudo snap install plex-htpc

```

## Setup Kubernetes on vms

### Current env

```
ssh-keygen -f ~/.ssh/vm
```

```

ubuntuimage=jammy-server-cloudimg-amd64
variant=ubuntujammy

image=debian-12-genericcloud-amd64-20230802-1460
variant=debiantesting

vmcreate master 3072 4 $image 10 40G 1G $variant
vmcreate node01 2048 4 $image 11 40G 1G $variant
vmcreate node02 2048 4 $image 12 40G 1G $variant
vmcreate node03 2048 4 $image 13 40G 1G $variant

vmcreate splunk 6144 4  $image 40 40G 1G $variant
vmcreate vrbx 6144 4  $image 30 40G 1G $variant



```


### Delete vms example

```
vmdl master
vmdl node01
vmdl node02
vmdl node03

vmdl splunk


vmdl vrbx

```

### Simple approach with microk8s

```

sudo snap install microk8s --channel=1.24/stable --classic
sudo usermod -a -G microk8s apham

```

## TLS Setyp

### Generate Certificates Root CA

```

rootcakeyfile=/home/apham/apps/tls/work.lan-root-ca.key
rootcacertfile=/home/apham/apps/tls/work.lan-root-ca.pem

cahostname=work.lan

tagethostname=cipi.lan
keystorefile=/home/apham/apps/tls/${tagethostname}.p12
keyfile=/home/apham/apps/tls/${tagethostname}.key
certfile=/home/apham/apps/tls/${tagethostname}.pem
certfilecrt=/home/apham/apps/tls/${tagethostname}.crt
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

### Generate Key Pair and others

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

cp $certfile $certfilecrt
```

## Predownload docker images

```
images=(
    # Kube
    registry.k8s.io/kube-apiserver:v1.25.6
    registry.k8s.io/kube-controller-manager:v1.25.6
    registry.k8s.io/kube-scheduler:v1.25.6
    registry.k8s.io/kube-proxy:v1.25.6
    registry.k8s.io/pause:3.8
    registry.k8s.io/etcd:3.5.6-0
    registry.k8s.io/coredns/coredns:v1.9.3

    # metrics server
    "k8s.gcr.io/metrics-server/metrics-server:v0.6.2"

    # Flannel
    "flannelcni/flannel-cni-plugin:v1.1.0"
    "flannelcni/flannel:v0.20.2"

    # ingress nginx
    "registry.k8s.io/ingress-nginx/controller:v1.5.1"
    "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20220916-gd32f8c343"

    # kube ui
    "kubernetesui/metrics-scraper:v1.0.8"
    "kubernetesui/dashboard:v2.7.0"

    # storage
    "rancher/local-path-provisioner:v0.0.23"

    # Minio
    "minio/minio:RELEASE.2023-02-09T05-16-53Z"
    "docker.io/busybox:1.36.0"
    "curlimages/curl:7.87.0"

    # Grafana stack observability
    "grafana/enterprise-metrics:v2.5.1"
    "grafana/mimir:2.5.0"
    "docker.io/memcached:1.6.18-alpine"
    "prom/memcached-exporter:v0.10.0"

    "grafana/enterprise-logs:v1.6.0"
    "grafana/loki:2.7.1"
    "grafana/promtail:2.7.1"
    
    "grafana/enterprise-traces:v1.3.0"
    "grafana/tempo:1.5.0"

    "grafana/grafana:9.3.4"
    "grafana/grafana-enterprise:9.3.4"
      
    "grafana/grafana-oss-dev:9.4.0-97680pre"

    "grafana/agent:v0.30.2"
    "grafana/agent:v0.28.1"
    
    "prom/prometheus:v2.41.0"
    "prom/node-exporter:v1.5.0"
    "gcr.io/cadvisor/cadvisor:v0.47.1"
    "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.7.0"

    # Databases
    "docker.io/mariadb:10.9.4"
    "docker.io/mysql:8.0.32"
    "docker.io/postgres:15.1"
    "docker.io/elasticsearch:8.6.0"
    "docker.io/adminer:4.8.1"

    # messaging
    "confluentinc/cp-kafka:7.3.0"
    "confluentinc/cp-zookeeper:7.3.0"
    "confluentinc/cp-server:7.3.0"
    
    "quay.io/strimzi/kafka:0.32.0-kafka-3.2.1"
    "obsidiandynamics/kafdrop:3.30.0"


    # platform essentials
    "portainer/portainer-ce:2.16.2"
    "sonatype/nexus3:3.43.0"
    "docker.io/registry:2.8.1"
    "joxit/docker-registry-ui:2.3.3"
    "docker.io/traefik:2.9.6"
    "quay.io/keycloak/keycloak:20.0.3-0"
    "dzikoysk/reposilite:3.2.6"

    # Demo Applications
    "alainpham/web-shop:1.8"
    "alainpham/shopping-cart:1.3"
    "alainpham/products:otel-1.3"

    "alainpham/smoke-test-app:1.2"
    "philippgille/serve:0.3.0"
)


images=(
  "minio/minio:RELEASE.2023-02-09T05-16-53Z"

)

test="minio:RELEASE.2023-02-09T05-16-53Z"
echo $test |  awk  -F  ':' '{ print $1 }'
echo "$test"| grep -o '.*[^:]'

localrepo=registry.awon.lan

for item in "${images[@]}"
do
   localnameversion=`echo "$item"| grep -o '[^/]*$' `
   localname=`echo $localnameversion |  awk  -F  ':' '{ print $1 }'`
   version=`echo "$item"| grep -o '[^:]*$' `
   
   echo "- $localname"
done

cat /tmp/txt


for item in "${images[@]}"
do
   localname=`echo "$item"| grep -o '[^/]*$' `
   echo ${localrepo}/${localname}
   skopeo copy docker://"$item" docker://${localrepo}/${localname}
done


for item in "${images[@]}"
do
   docker pull $item
done

for item in "${images[@]}"
do
   localname=`echo "$item"| grep -o '[^/]*$' `
   echo ${localrepo}/${localname}
   docker tag $item ${localrepo}/${localname}
done

for item in "${images[@]}"
do
   localname=`echo "$item"| grep -o '[^/]*$' `
   echo ${localrepo}/${localname}
   docker push ${localrepo}/${localname}
done



```



## Pipewire virtual sinks

```


sudo apt install pipewire-audio-client-libraries libspa-0.2-bluetooth libspa-0.2-jack
sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/



sudo mkdir -p /etc/pipewire/pipewire.conf.d/
sudo cp 10-virtual-sinks.conf /etc/pipewire/pipewire.conf.d/

sudo vi /etc/security/limits.d/95-pipewire.conf

# Default limits for users of pipewire
@pipewire - rtprio 95
@pipewire - nice -19
@pipewire - memlock unlimited



pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX0 mic01-processed:input_FL
pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX0 mic01-processed:input_FR

pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX1 mic02-processed:input_FL
pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX1 mic02-processed:input_FR

pw-link mic01-processed:capture_FL to-caller:input_FL
pw-link mic01-processed:capture_FR to-caller:input_FR

pw-link mic02-processed:capture_FL to-caller:input_FL
pw-link mic02-processed:capture_FR to-caller:input_FR



pw-link from-caller:monitor_FL alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX0
pw-link from-caller:monitor_FR alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX1

pw-link from-desktop:monitor_FL alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX0
pw-link from-desktop:monitor_FR alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX1


pw-link from-desktop:monitor_FL to-caller:input_FL
pw-link from-desktop:monitor_FR to-caller:input_FR




minimal

pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX0 mic01-processed:input_FL
pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX0 mic01-processed:input_FR

pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX1 mic02-processed:input_FL
pw-link alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-input-0:capture_AUX1 mic02-processed:input_FR

pw-link mic01-processed:capture_FL to-caller:input_FL
pw-link mic01-processed:capture_FR to-caller:input_FR

pw-link mic02-processed:capture_FL to-caller:input_FL
pw-link mic02-processed:capture_FR to-caller:input_FR

pw-link from-caller:monitor_FL alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX0
pw-link from-caller:monitor_FR alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX1

pw-link from-desktop:monitor_FL alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX0
pw-link from-desktop:monitor_FR alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.pro-output-0:playback_AUX1


## Pure jack

```
#before start
pacmd suspend true

pactl load-module module-jack-source source_name=mic01-processed client_name=mic01-processed channels=2 connect=0
pactl load-module module-jack-source source_name=mic02-processed client_name=mic02-processed channels=2 connect=0
pactl load-module module-jack-source source_name=to-caller client_name=to-caller channels=2 connect=0
pactl load-module module-jack-source source_name=mics-raw client_name=mics-raw channels=2 connect=0

pactl load-module module-jack-sink sink_name=from-caller client_name=from-caller channels=2 connect=0
pactl load-module module-jack-sink sink_name=from-desktop client_name=from-desktop channels=2 connect=0

pacmd set-default-sink from-desktop
pacmd set-default-source to-caller




#after stop
pacmd suspend false



avoid stutter

/etc/pulse/default.pa

put to 

load-module module-udev-detect tsched=0


echo governor | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```
## Pure pulse audio

setup virtual devices

```
sudo bash -c 'cat > /etc/modules-load.d/snd_aloop.conf << _EOF_
snd_aloop
_EOF_'

sudo cp ./../pipewire-conf/pulsesetup.sh /usr/local/bin/
sudo cp ./../pipewire-conf/pulsesetup-alsa.sh /usr/local/bin/pulsesetup.sh

```

put this in /etc/pulse/default.pa
```
load-module module-alsa-sink sink_name=to-caller-alsa-sink sink_properties=device.description="to-caller-alsa-sink"  device=hw:Loopback,1
load-module module-alsa-source source_name=to-caller source_properties=device.description="to-caller"  device=hw:Loopback,0
set-default-source to-caller
```


```
pacmd list-sinks
pacmd list-sources

rm /tmp/pulsemodule.log


speaker="alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.analog-stereo"
speaker="bluez_sink.04_52_C7_09_DC_69.a2dp_sink"

mic="alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y8QWAQ69B26B58-00.analog-stereo"

pulseaudio -k
# audio sink from desktop
pactl load-module module-null-sink sink_name=from-desktop sink_properties=device.description="from-desktop">>/tmp/pulsemodule.log
pacmd set-default-sink from-desktop

# audio sink from caller
pactl load-module module-null-sink sink_name=from-caller sink_properties=device.description="from-caller">>/tmp/pulsemodule.log

# audio sink mix to caller
pactl load-module module-null-sink sink_name=to-caller-sink sink_properties=device.description="to-caller-sink">>/tmp/pulsemodule.log
pactl load-module module-remap-source  source_name=to-caller master=to-caller-sink.monitor source_properties=device.description="to-caller"

pacmd set-default-source to-caller-src

# connect from-desktop to to-caller-sink
pactl load-module module-loopback source=from-desktop.monitor sink=to-caller-sink latency_msec=1 source_dont_move=true sink_dont_move=true >> /tmp/pulsemodule.log

### CONNECT PHYSICAL DEVICES

# connect from-desktop to speakers
pactl load-module module-loopback source="from-desktop.monitor" sink="${speaker}" latency_msec=1 >>/tmp/pulsemodule.log

# connect from-caller to speakers
pactl load-module module-loopback source="from-caller.monitor" sink="${speaker}" latency_msec=1>>/tmp/pulsemodule.log

# split mic into 2
pactl load-module module-remap-source source_name=mic01-processed master=${mic} master_channel_map="front-left" channel_map="mono" source_properties=device.description="mic01-processed"
pactl load-module module-remap-source source_name=mic02-processed master=${mic} master_channel_map="front-right" channel_map="mono" source_properties=device.description="mic02-processed"
pactl load-module module-remap-source source_name=mics-raw master=${mic} source_properties=device.description="mics-raw"

# connect microphone to to-caller-sink

pactl load-module module-loopback source="mic01-processed" sink=to-caller-sink latency_msec=1 source_dont_move=true sink_dont_move=true  >> /tmp/pulsemodule.log
pactl load-module module-loopback source="mic02-processed" sink=to-caller-sink latency_msec=1 source_dont_move=true sink_dont_move=true  >> /tmp/pulsemodule.log

# set proper mic volume
pactl set-source-volume mic01-processed 120%
pactl set-source-volume mic02-processed 0%
pactl set-sink-volume from-desktop 95%
pactl set-sink-volume from-caller 95%

```

## Davinci Resolve

```
sudo apt install fakeroot xorriso
sudo apt install nvidia-opencl-icd libcuda1 libnvidia-encode1

./makeresolvedeb_1.6.4_multi.sh DaVinci_Resolve_18.5_Linux.run
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


Docker file

optional if dns is well configured
```
sudo bash -c 'cat > /etc/docker/daemon.json << _EOF_
{
    "insecure-registries" : ["registry.work.lan", "registry.awon.lan"],
    "dns": ["172.17.0.1"]
}
_EOF_'

sudo systemctl restart docker
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
/!\ END Archived steps
