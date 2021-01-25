#!/bin/bash

### Purpose: Script Installs and Configures Dependencies for Deploying Repository on a CentOS 7 system




# Configures SSH Timeouts
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
systemctl restart sshd.service




### Docker Daemon

# Install Docker Community Edition
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker Service
systemctl start docker.service && systemctl enable docker.service




### Download/Install Binary Dependencies

yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
yum install -y epel-release
yum install -y jq git

# Download Kubectl
curl -sLo ./kubectl https://storage.googleapis.com/kubernetes-release/release/v1.18.4/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/bin/kubectl

# Download KIND
curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/bin/kind

# Download Skaffold
curl -sLo ./skaffold https://storage.googleapis.com/skaffold/releases/v1.13.1/skaffold-linux-amd64
chmod +x ./skaffold
mv ./skaffold /usr/bin/skaffold

# Download Helm
export HELM_INSTALL_DIR='/usr/bin' 
curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -- --version v3.2.4
unset HELM_INSTALL_DIR




### KIND - Kubernetes in Docker

# Set Kubernetes API Interface Address
KUBE_IP=$(hostname -I | awk '{print $1}')  # Use when deploying on a remote system

# Render Custom KIND Config File
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "$KUBE_IP"
  apiServerPort: 33052
nodes:
- role: control-plane
  image: kindest/node:v1.18.4
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
- role: worker
  image: kindest/node:v1.18.4
- role: worker
  image: kindest/node:v1.18.4
- role: worker
  image: kindest/node:v1.18.4
EOF




### Configure Firewalld Service (OPTIONAL - Used for CentOS Remote System)

if [[ $(firewall-cmd --state) = 'running' ]]
then
  # Configure Firewall Service
  firewall-cmd --zone=public --add-port=33052/tcp --permanent
  
  # Validation/Debugging
  firewall-cmd --reload
  firewall-cmd --list-all
fi