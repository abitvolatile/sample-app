#!/bin/bash

# Note: Uncomment the below line when using a remote machine that is a Linux OS. Leave commented when running KIND locally on MacOSx.

# Sets Kubernetes API using the Remote Systems Interface Address on *nix
#KUBE_IP=$(hostname -I | awk '{print $1}')  # Use when deploying on a remote system


# Deploy KIND Cluster 
cat <<EOF | kind create cluster --config=-
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
