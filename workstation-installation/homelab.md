
```bash

# Variables 
export APPUSER=apham

export KUBE_VERSION=v1.27.8
export K9S_VERSION=v0.29.1
export KIND_VERSION=v0.20.0

export CERTBOT_DUCKDNS_VERSION=v1.3
export DUCKDNS_TOKEN=xxxx-xxxx-xxx-xxx-xxxxx
export EMAIL=xxx@yyy.com
export WILDCARD_DOMAIN=yourowndomain.duckdns.org

export ARCH="amd64" 
export GCLOUD_HOSTED_METRICS_URL="https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push" 
export GCLOUD_HOSTED_METRICS_ID="xxx" 
export GCLOUD_SCRAPE_INTERVAL="60s" 
export GCLOUD_HOSTED_LOGS_URL="https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push" 
export GCLOUD_HOSTED_LOGS_ID="xxx" 
export GCLOUD_RW_API_KEY=XXXXX

export NGINX_INGRESS_VERSION=1.9.5
export NGINX_INGRESS_KUBE_WEBHOOK_CERTGEN_VERSION=v20231011-8b53cabe0

export MVN_VERSION=3.9.6

export DOCKER_BUILDX_VERSION=v0.12.0

export LOCAL_PATH_PROVISIONER_VERSION=v0.0.26
export METRICS_SERVER_VERSION=v0.6.4

# basics
su
apt update && apt upgrade
apt install sudo

echo "${APPUSER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/nopwd

exit

sudo bash -c 'cat > /etc/profile.d/super_aliases.sh << _EOF_
alias ll="ls -larth"
_EOF_'

# on debian fresh installs with virtual box
# The primary network interface
sudo bash -c 'cat > /etc/network/interfaces.d/hostnetwork << _EOF_
auto enp0s8
iface enp0s8 inet static
address 192.168.56.10
netmask 255.255.255.0
_EOF_'

address 172.24.247.100/20
netmask 255.255.0.0
dns 172.24.240.1 



# install essentials

sudo apt install git ansible docker.io python3-docker docker-compose skopeo tmux vim  curl rsync ncdu  dnsutils bmon wireguard-tools iptables  ntp ntpstat htop iperf3 bash-completion ffmpeg

# if network manager is installed
sudo apt install systemd-resolved

# if only simple netwoking is used
sudo apt install resolvconf 

sudo apt install openjdk-17-jdk-headless

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

# run ansible scripts to run docker containers

# add grafana agent with linux node integration

sh -c "$(curl -fsSL https://storage.googleapis.com/cloud-onboarding/agent/scripts/grafanacloud-install.sh)"




# Install kubectl

curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
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

docker run --rm --name certbot --user 1000:1000 -v "$(pwd)/sensitive/letsencrypt/data:/etc/letsencrypt" -v "$(pwd)/sensitive/letsencrypt/logs:/var/log/letsencrypt" infinityofspace/certbot_dns_duckdns:${CERTBOT_DUCKDNS_VERSION} \
   certonly \
     --non-interactive \
     --agree-tos \
     --email ${EMAIL} \
     --preferred-challenges dns \
     --authenticator dns-duckdns \
     --dns-duckdns-token ${DUCKDNS_TOKEN} \
     --dns-duckdns-propagation-seconds 15 \
     -d "${WILDCARD_DOMAIN}"

kubectl create ns ingress-nginx

sudo kubectl -n ingress-nginx create  secret tls nginx-ingress-tls  --key="$(pwd)/sensitive/letsencrypt/data/live/yourowndomain.duckdns.org/privkey.pem"   --cert="$(pwd)/sensitive/letsencrypt/data/live/yourowndomain.duckdns.org/fullchain.pem"  --dry-run=client -o yaml | kubectl apply -f -


kubectl apply -f https://raw.githubusercontent.com/alainpham/cloud_native_lab/master/playbooks/gke/ingress-hostport.yaml


# reusable certificat 

mkdir -p /home/${USER}/apps/tls/cfg /home/${USER}/apps/tls/logs

docker run --rm --name certbot  -v "/home/${USER}/apps/tls/cfg:/etc/letsencrypt" -v "/home/${USER}/apps/tls/logs:/var/log/letsencrypt" infinityofspace/certbot_dns_duckdns:${CERTBOT_DUCKDNS_VERSION} \
   certonly \
     --non-interactive \
     --agree-tos \
     --email ${EMAIL} \
     --preferred-challenges dns \
     --authenticator dns-duckdns \
     --dns-duckdns-token ${DUCKDNS_TOKEN} \
     --dns-duckdns-propagation-seconds 5 \
     -d "*.${WILDCARD_DOMAIN}"

sudo chown -R ${USER}:${USER} /home/${USER}/apps/tls/cfg

openssl pkcs12 -export -out /home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/privkey.p12  -in /home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/fullchain.pem -inkey  /home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/privkey.pem -passin pass:password -passout pass:password


# wireguard

docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE `#optional` \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=Etc/UTC \
  -e SERVERURL=euas.duckdns.org `#optional` \
  -e SERVERPORT=51820 `#optional` \
  -e PEERS=euas,awon,work,surf,iphone8PlusQuang,ipadQuang `#optional` \
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

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

sudo kubeadm init --control-plane-endpoint=master.cxw.duckdns.org  --pod-network-cidr=10.244.0.0/16

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# ingress

kubectl create ns ingress-nginx

kubectl -n ingress-nginx create secret tls nginx-ingress-tls  --key="/home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/privkey.pem"   --cert="/home/${USER}/apps/tls/cfg/live/${WILDCARD_DOMAIN}/fullchain.pem"  --dry-run=client -o yaml | kubectl apply -f -

kubectl taint node ${HOSTNAME} node-role.kubernetes.io/control-plane:NoSchedule-

wget -O /tmp/ingress.yaml https://raw.githubusercontent.com/alainpham/dev-environment/master/workstation-installation/templates/ingress-hostport-notoleration.yaml
envsubst < /tmp/ingress.yaml | kubectl -n ingress-nginx apply -f -

# storage
wget -O /tmp/local-path-provisioner.yaml https://raw.githubusercontent.com/alainpham/dev-environment/master/workstation-installation/templates/local-path-provisioner.yaml
envsubst < /tmp/local-path-provisioner.yaml | kubectl apply -f -

# metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml
```