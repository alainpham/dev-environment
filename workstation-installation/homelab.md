
```bash

# Variables 
export APPUSER=apham

export KUBE_VERSION=v1.27.3
export K9S_VERSION=v0.29.1
export KIND_VERSION=v0.20.0

export CERTBOT_DUCKDNS_VERSION=v1.3
export DUCKDNS_TOKEN=xxxx-xxxx-xxx-xxx-xxxxx
export EMAIL=xxx@yyy.com
export WILDCARD_DOMAIN=*.yourowndomain.duckdns.org

export ARCH="amd64" 
export GCLOUD_HOSTED_METRICS_URL="https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push" 
export GCLOUD_HOSTED_METRICS_ID="xxx" 
export GCLOUD_SCRAPE_INTERVAL="60s" 
export GCLOUD_HOSTED_LOGS_URL="https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push" 
export GCLOUD_HOSTED_LOGS_ID="xxx" 
export GCLOUD_RW_API_KEY=XXXXX

export NGINX_INGRESS_VERSION=1.9.4
export NGINX_INGRESS_KUBE_WEBHOOK_CERTGEN_VERSION=v20231011-8b53cabe0

export MVN_VERSION=3.9.6

export DOCKER_BUILDX_VERSION=v0.12.0

# basics
su
apt update && apt upgrade
apt install sudo

echo "${APPUSER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/nopwd

exit

# install essentials

sudo apt install git ansible docker.io python3-docker docker-compose skopeo tmux vim openjdk-17-jdk-headless curl rsync ncdu  dnsutils bmon wireguard-tools iptables resolvconf ntp ntpstat htop iperf3 bash-completion ffmpeg

sudo adduser $USER docker

# configure basic folder mapping
mkdir -p /home/${USER}/apps
sudo mkdir -p /mnt/extdrv01

# add following line to /etc/fstab for automount
sudo blkid
sudo vi /etc/fstab
UUID=bc86dbce-e2c8-4628-b516-91db86acc8ca /mnt/extdrv01 ext4 rw,relatime,nofail,user 0 2

ln -s /mnt/extdrv01/apps /home/${USER}/apps

docker network create --driver=bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 primenet

# minimalistic logs

sudo bash -c 'cat > /etc/docker/daemon.json << _EOF_
{
  "log-opts": {
    "max-size": "20m",
    "max-file": "2" 
  }
}
_EOF_'

sudo mkdir -p /usr/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64 -o /usr/lib/docker/cli-plugins/docker-buildx
sudo chmod 755 /usr/lib/docker/cli-plugins/docker-buildx

sudo systemctl restart docker


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

docker run --rm --name certbot -v "$(pwd)/sensitive/letsencrypt/data:/etc/letsencrypt" -v "$(pwd)/sensitive/letsencrypt/logs:/var/log/letsencrypt" infinityofspace/certbot_dns_duckdns:${CERTBOT_DUCKDNS_VERSION} \
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