
```bash

# Variables 
export APPUSER=apham

export KUBE_VERSION=v1.27.13
# https://github.com/derailed/k9s/releases
export K9S_VERSION=v0.32.4
export KIND_VERSION=v0.22.0

export WILDCARD_DOMAIN=${HOSTNAME}.duckdns.org
# https://github.com/infinityofspace/certbot_dns_duckdns
export CERTBOT_DUCKDNS_VERSION=v1.3

# https://metallb.universe.tf/installation/
export METALLB_VERSION=v0.14.3

# https://github.com/kubernetes/ingress-nginx/blob/main/deploy/static/provider/baremetal/deploy.yaml
export NGINX_INGRESS_VERSION=1.10.1
export NGINX_INGRESS_KUBE_WEBHOOK_CERTGEN_VERSION=v1.4.1

# https://maven.apache.org/docs/history.html
export MVN_VERSION=3.9.6

# https://github.com/docker/buildx
export DOCKER_BUILDX_VERSION=v0.14.0

# https://github.com/rancher/local-path-provisioner
export LOCAL_PATH_PROVISIONER_VERSION=v0.0.26

# https://github.com/kubernetes-sigs/metrics-server
export METRICS_SERVER_VERSION=v0.7.1

# Sensitive
export DUCKDNS_TOKEN=xxxx-xxxx-xxx-xxx-xxxxx
export EMAIL=xxx@yyy.com


# basics
su
apt update && apt upgrade
apt install sudo

echo "apham ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/nopwd
echo "${APPUSER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/nopwd

exit

sudo bash -c 'cat > /etc/profile.d/super_aliases.sh << _EOF_
alias ll="ls -larth"
_EOF_'

# remember to remove dns-search section on vms with static ips
sudo vi /etc/network/interfaces


# on debian fresh installs with virtual box
# The primary network interface
sudo bash -c 'cat > /etc/network/interfaces.d/hostnetwork << _EOF_
auto enp0s8
iface enp0s8 inet static
address 192.168.56.10
netmask 255.255.255.0
_EOF_'



# grub quickstart
sudo vi /etc/default/grub
GRUB_TIMEOUT=0
sudo update-grub

# minimal host
sudo apt install git tmux vim curl rsync ncdu dnsutils bmon ntp ntpstat htop bash-completion


# minimal docker host
sudo apt install docker.io python3-docker docker-compose skopeo

# install essentials
sudo apt install ansible openjdk-17-jdk-headless iperf3 ntfs-3g

# install desktop
sudo apt install ffmpeg lm-sensors mediainfo imagemagick gimp ifuse libimobiledevice-utils xournal inkscape obs-studio haruna handbrake

sudo apt install software-properties-common

sudo apt-get install libdvd-pkg

sudo dpkg-reconfigure libdvd-pkg

sudo mkdir /opt/debs
cd /opt/debs
sudo curl -Lo chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

sudo apt install /opt/debs/chrome.deb

sudo curl -Lo vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
"

sudo apt install /opt/debs/vscode.deb

# virtualization

sudo apt install qemu-system qemu-utils virtinst libvirt-clients libvirt-daemon-system libguestfs-tools bridge-utils libosinfo-bin virt-manager genisoimage

sudo curl -Lo /usr/local/bin/vmcreate https://raw.githubusercontent.com/alainpham/dev-environment/master/kvm-scripts/vmcreate
sudo curl -Lo /usr/local/bin/vmdl https://raw.githubusercontent.com/alainpham/dev-environment/master/kvm-scripts/vmdl
sudo curl -Lo /usr/local/bin/vmls https://raw.githubusercontent.com/alainpham/dev-environment/master/kvm-scripts/vmls
sudo curl -Lo /usr/local/bin/vmsh https://raw.githubusercontent.com/alainpham/dev-environment/master/kvm-scripts/vmsh

sudo chmod 755 /usr/local/bin/vmcreate /usr/local/bin/vmdl /usr/local/bin/vmls /usr/local/bin/vmsh 



# wireguard
sudo apt install wireguard-tools iptables

# install wsl

sudo apt install git ansible docker.io python3-docker docker-compose skopeo tmux vim  curl rsync ncdu  dnsutils bmon ntp ntpstat htop iperf3 bash-completion ffmpeg 

# if network manager is installed actually not needed
sudo apt install systemd-resolved

# if only simple netwoking is used
sudo apt install resolvconf 

sudo reboot now

sudo adduser $USER docker

# configure basic folder mapping
mkdir -p /home/${USER}/apps
sudo mkdir -p /mnt/extdrv01
sudo mkdir -p /mnt/extdrv02

# add following line to /etc/fstab for automount
sudo blkid
sudo vi /etc/fstab
UUID=bc86dbce-e2c8-4628-b516-91db86acc8ca /mnt/extdrv01 ext4 rw,relatime,nofail,user 0 2

ln -s /mnt/extdrv01/apps /home/${USER}/apps

docker network create --opt com.docker.network.bridge.name=primenet --driver=bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 primenet

# minimalistic logs

sudo bash -c 'cat > /etc/docker/daemon.json << _EOF_
{
  "log-opts": {
    "max-size": "10m",
    "max-file": "2" 
  }
}
_EOF_'

sudo mkdir -p /usr/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64 -o /usr/lib/docker/cli-plugins/docker-buildx

sudo curl -SL https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-arm-v7 -o /usr/lib/docker/cli-plugins/docker-buildx

sudo chmod 755 /usr/lib/docker/cli-plugins/docker-buildx

sudo systemctl restart docker

docker buildx create --name multibuilder --platform linux/amd64,linux/arm/v7,linux/arm64/v8 --use

# Journal size limit

sudo vi /etc/systemd/journald.conf
SystemMaxUse=100M

sudo systemctl restart systemd-journald.service

# configure apt cacher ng only on one server awon.lan
sudo apt install apt-cacher-ng

sudo chown -R apt-cacher-ng:apt-cacher-ng /mnt/extdrv01/apt-cacher-ng

#edit content of apt-cacher-ng config
sudo vi /etc/apt-cacher-ng/acng.conf
CacheDir: /mnt/extdrv01/apt-cacher-ng/cache
LogDir: /mnt/extdrv01/apt-cacher-ng/log

sudo vi /lib/systemd/system/apt-cacher-ng.service
RequiresMountsFor=/mnt/extdrv01/apt-cacher-ng/cache

sudo chown -R 

sudo systemctl daemon-reload
sudo systemctl restart apt-cacher-ng.service


# Configure client
sudo bash -c 'cat > /etc/apt/apt.conf.d/proxy << _EOF_
Acquire::http::Proxy "http://192.168.8.100:3142";
_EOF_'


# install maven

sudo bash -c 'cat > /etc/profile.d/java_home.sh << _EOF_
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
_EOF_'

sudo mkdir /opt/appimages/

curl -L -o /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz
sudo tar xzvf /tmp/maven.tar.gz  -C /opt/appimages/
sudo ln -s /opt/appimages/apache-maven-${MVN_VERSION}/bin/mvn /usr/local/bin/mvn

mkdir -p /home/${USER}/.m2/
echo "<settings><localRepository>/mnt/extdrv01/apps/maven/repository/</localRepository></settings>" > /home/${USER}/.m2/settings.xml

# ssh keygen and copy to github

ssh-keygen

# reusable certificat 

mkdir -p /home/${USER}/apps/tls/cfg /home/${USER}/apps/tls/logs

# do the sensitive thing

docker run --rm --name certbot  -v "/home/${USER}/apps/tls/cfg:/etc/letsencrypt" -v "/home/${USER}/apps/tls/logs:/var/log/letsencrypt" infinityofspace/certbot_dns_duckdns:${CERTBOT_DUCKDNS_VERSION} \
   certonly \
     --non-interactive \
     --agree-tos \
     --email ${EMAIL} \
     --preferred-challenges dns \
     --authenticator dns-duckdns \
     --dns-duckdns-token ${DUCKDNS_TOKEN} \
     --dns-duckdns-propagation-seconds 10 \
     -d "*.${WILDCARD_DOMAIN}"

sudo chown -R ${USER}:${USER} /home/${USER}/apps/tls/cfg

openssl pkcs12 -export -out /home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/privkey.p12  -in /home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/fullchain.pem -inkey  /home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/privkey.pem -passin pass:password -passout pass:password


# run ansible scripts to run docker containers

# do integrations in grafana cloud

# Install kubectl optional

curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
sudo cp kubectl /usr/local/bin/kubectl
sudo chmod 755 /usr/local/bin/kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
rm kubectl

# Install k9s

curl -LO https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
sudo tar -xzvf k9s_Linux_amd64.tar.gz  -C /usr/local/bin/ k9s
rm k9s_Linux_amd64.tar.gz

# install kind 

# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


# Create kind cluster with ingress

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
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

kubectl apply -f https://raw.githubusercontent.com/alainpham/cloud_native_lab/master/playbooks/gke/ingress-hostport.yaml


# wireguard vpnup.sh

docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE `#optional` \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=Etc/UTC \
  -e SERVERURL=euas.duckdns.org `#optional` \
  -e SERVERPORT=51820 `#optional` \
  -e PEERS=euas,awon,work,surf,iphone8PlusQuang,ipadQuang,cipi,iphone8PlusDong,iphone8PlusHuyen,iphoneHoa,iPadMax,iphoneHang,iphoneHuyenAnh,iphoneDavid,surfHuyen,bbee,tvPoissy,tvCPoissy,arev,leno `#optional` \
  -e PEERDNS="no" \
  -e INTERNAL_SUBNET=10.13.13.0 `#optional` \
  -e ALLOWEDIPS=10.13.13.0/24 `#optional` \
  -e PERSISTENTKEEPALIVE_PEERS=all `#optional` \
  -e LOG_CONFS=true `#optional` \
  -p 51820:51820/udp \
  -v /home/${USER}/wg/config:/config \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --restart unless-stopped \
  linuxserver/wireguard:1.0.20210914

# coredns file

. {
    loop
    health
    forward . /etc/resolv.conf
}

vlan {
    file /config/coredns/internal.conf
    log
    errors 
}

awon.cpss.duckdns.org {
    file /config/coredns/internal.conf
    log
    errors
}

bbee.cpss.duckdns.org {
    file /config/coredns/internal.conf
    log
    errors
}

cipi.pssy.duckdns.org {
    file /config/coredns/internal.conf
    log
    errors
}

arev.pssy.duckdns.org {
    file /config/coredns/internal.conf
    log
    errors
}

# internal.conf
vlan. IN SOA dns.vlan. admin.vlan. 1986112600 7200 3600 1209600 3600


# c poissy
cpss.duckdns.org. IN SOA dns.cpss.duckdns.org. admin.cpss.duckdns.org. 1986112600 7200 3600 1209600 3600
awon.cpss.duckdns.org. IN A 10.13.13.3
*.awon.cpss.duckdns.org. IN A 10.13.13.3
awon.vlan. IN CNAME awon.cpss.duckdns.org.
*.awon.vlan. IN CNAME awon.cpss.duckdns.org.

bbee.cpss.duckdns.org. IN A 10.13.13.17
*.bbee.cpss.duckdns.org. IN A 10.13.13.17
bbee.vlan. IN CNAME bbee.cpss.duckdns.org.
*.bbee.vlan. IN CNAME bbee.cpss.duckdns.org.

# poissy
pssy.duckdns.org. IN SOA dns.pssy.duckdns.org. admin.pssy.duckdns.org. 1986112600 7200 3600 1209600 3600

cipi.pssy.duckdns.org. IN A 10.13.13.8
*.cipi.pssy.duckdns.org. IN A 10.13.13.8
cipi.vlan. IN CNAME cipi.pssy.duckdns.org.
*.cipi.vlan. IN CNAME cipi.pssy.duckdns.org.

arev.pssy.duckdns.org. IN A 10.13.13.20
*.arev.pssy.duckdns.org. IN A 10.13.13.20
arev.vlan. IN CNAME arev.pssy.duckdns.org.
*.arev.vlan. IN CNAME arev.pssy.duckdns.org.


# showpeer.sh
docker exec -it wireguard /app/show-peer $1
cat wg/config/peer_$1/peer_$1.conf

# list config
cat wg/config/peer_*/peer*.conf
# client

sudo vi /etc/wireguard/wg0.conf

sudo systemctl enable wg-quick@wg0

```

# Creating virtual machines

```

sudo virsh net-autostart default
sudo virsh net-start default

sudo mkdir -p /home/workdrive/virt/images
sudo mkdir -p /home/workdrive/virt/runtime
sudo chown -R apham:apham /home/workdrive/

curl -Lo /home/workdrive/virt/images/debian-12-genericcloud-amd64.qcow2  https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

virt-install --os-variant list

ssh-keygen -f ~/.ssh/vm

vmcreate <node-name> <ram-MB> <vcpus> <source-image> <mac-ip-suffix> <disk-size> <data-size> <os-variant>

vmcreate master 1024 2 debian-12-genericcloud-amd64 10 40G 1G debiantesting

vmsh master

vmdl master

```
# Kubernetes

```bash
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf 
overlay 
br_netfilter
EOF

sudo modprobe overlay 
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
net.bridge.bridge-nf-call-ip6tables = 1 
EOF

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

sudo vi /etc/containerd/config.toml
SystemdCgroup = true
sudo systemctl restart containerd
sudo systemctl enable containerd

sudo apt install -y apt-transport-https ca-certificates

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

# helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install helm
helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null


sudo kubeadm init --control-plane-endpoint=${WILDCARD_DOMAIN}  --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# copy to local machine 
ssh cxw "cat ~/.kube/config" > ~/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl taint node ${HOSTNAME} node-role.kubernetes.io/control-plane:NoSchedule-

# or

# kubectl create ns kube-flannel
# kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

# helm repo add flannel https://flannel-io.github.io/flannel/
# helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel


# calico
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml


# storage
wget -O /tmp/local-path-provisioner.yaml https://raw.githubusercontent.com/alainpham/dev-environment/master/workstation-installation/templates/local-path-provisioner.yaml
envsubst '${LOCAL_PATH_PROVISIONER_VERSION}'  < /tmp/local-path-provisioner.yaml | kubectl apply -f -

# metal LB

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: standard-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.199.110-192.168.199.240
EOF


# ingress
kubectl create ns ingress-nginx

kubectl -n ingress-nginx create secret tls nginx-ingress-tls  --key="/home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/privkey.pem"   --cert="/home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/fullchain.pem"  --dry-run=client -o yaml | kubectl apply -f -

wget -O /tmp/ingress.yaml https://raw.githubusercontent.com/alainpham/dev-environment/master/workstation-installation/templates/ingress-hostport-notoleration.yaml
envsubst < /tmp/ingress.yaml | kubectl -n ingress-nginx apply -f -

# or ingress LB

wget -O /tmp/ingresslb.yaml https://raw.githubusercontent.com/alainpham/dev-environment/master/workstation-installation/templates/ingress-loadbalancer-notoleration.yaml
envsubst < /tmp/ingresslb.yaml | kubectl -n ingress-nginx apply -f -

# metrics
wget -O /tmp/metrics-server.yaml https://raw.githubusercontent.com/alainpham/dev-environment/master/workstation-installation/templates/metrics-server.yaml
envsubst < /tmp/metrics-server.yaml | kubectl apply -f -



# Grafana Cloud Kubernetes integrations

helm repo add grafana https://grafana.github.io/helm-charts &&
  helm repo update &&
  helm upgrade --install --atomic --timeout 120s grafana-k8s-monitoring grafana/k8s-monitoring \
    --namespace "agents" --create-namespace --values - <<EOF
cluster:
  name: ${HOSTNAME}
externalServices:
  prometheus:
    host: ${MIMIR_HOST}
    basicAuth:
      username: "${MIMIR_USR}"
      password: ${key}
  loki:
    host: ${LOKI_HOST}
    basicAuth:
      username: "${LOKI_USR}"
      password: ${key}
  tempo:
    host: ${TEMPO_URL}
    basicAuth:
      username: "${TEMPO_USR}"
      password: ${key}
metrics:
  cost:
    enabled: false
opencost:
  enabled: false
traces:
  enabled: true
EOF

# uninstall
helm uninstall grafana-k8s-monitoring -n agents


# test pings and network things

kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot

# test metal LB
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25.4-alpine
        ports:
        - containerPort: 80
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    metallb.universe.tf/loadBalancerIPs: 192.168.199.240
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
EOF

```


sshfs

 net use X: \\sshfs\apham@awon.cpss.duckdns.org:22123