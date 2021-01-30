# sample-app<br>
This project is a sample open-source e-commerce platform by the name of [Spree Commerce](https://spreecommerce.org/). The application demonstrates a functional web application in a microservice architecture, which has been made to be easily deployed on a local Kubernetes cluster using a few open and free tools, such as Vagrant, Docker, KIND, Helm and Skaffold. The web application has also been pre-instrumented with Datadog's APM & RUM libraries for each of the components. The application's code has been broken intentionally in such a way to simulate what would appear to be a poor user-experience for visitors due slow load times.
<br><br><br>


## Project Overview

### Technology Stack:
* The Frontend component is a [Ruby-on-Rails](https://rubyonrails.org/) Web Server called [Puma](https://github.com/puma/puma), which serves traffic to users.
* There are two microservices that accompany the application written in Python using the Flask [Framework](https://flask.palletsprojects.com/en/1.1.x/).
  * The Discounts component serves up discount codes to users on product pages.
  * The Advertisements component displays banners on pages using weighted priorities.
* The database component is Postgres DB using the [Official Postgres Docker Image](https://hub.docker.com/_/postgres).
<br><br>


### Software & Tools Used:
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)
* [CentOS](https://www.centos.org/)
* [Docker](https://www.docker.com/)
* [KIND](https://kind.sigs.k8s.io/)
* [Skaffold](https://skaffold.dev/)
* [Helm](https://helm.sh/)
* [HashiCorp Vault](https://www.vaultproject.io/)
<br><br><br><br>


## Deployment Methods
* [Host Isolation: Provisions a CentOS VM using HashiCorp Vagrant & VirtualBox](#getting-started-with-host-isolation-method-using-hashicorp-vagrant)
* [Native Mac OSX: Deploys directly on Mac OSX system](#getting-started-with-native-mac-osx)
<br><br><br>

# Getting Started with Host Isolation Method using Hashicorp Vagrant

#### Note: This approach has been tested using Mac OSX 10.14+ with Vagrant and CentOS 7 Operating Systems.
<br>

## Prerequisites:

**Download Binaries**
* [Download](https://www.virtualbox.org/wiki/Downloads) and install the VirtualBox binary on your local system.
* [Download](https://www.vagrantup.com/downloads) and install the Vagrant binary on your local system.

<br>
<b>NOTE: Windows Users</b>
Folks looking to deploy the project using the HashiCorp Vagrant method on a Windows system, some users have experienced known compatibility issues with later versions (>0.24) of the Vagrant VirtualBox Guest Tools plugin (Ruby GEM Package). To workaround the issue, some have found installing the 0.24 version of the plugin works fine. <br>

<br>

To install the specific version of the compatible plugin, use the following:
```
vagrant plugin install vagrant-vbguest --plugin-version 0.24
```

<br><br>


## Provisioning Instructions

#### Clone Project Repository
```
git clone https://github.com/abitvolatile/sample-app ./sample-app
cd sample-app
```
<br>

#### Provision Vagrant (CentOS7) Virtual Machine
```
# Installs VirtualBox Guest Extensions
vagrant plugin install vagrant-vbguest

# Provisions Virtual Machine using Vagrantfile
vagrant up

# Connects to Virtual Machine via SSH
vagrant ssh
```
<br>

#### Deploy Kubernetes Cluster
```
# Switch to Root User
sudo -i

# Change to Project Directory
cd /sample-app

# Provisions the Kubernetes Cluster using KIND
make provision

# Prints the Kubernetes Config (Auth Token)
make kube-config
```
<br>

#### Deploy Hashicorp Vault (Optional)
```
# Change Directory to Install Vault
cd vault/

# Deploy HashiCorp Vault
./deploy-vault.sh
cd ..
```
<br>

#### Deploy Sample Application
```
export TAG="latest"
export NAMESPACE="sample-app"

kubectl create ns "${NAMESPACE}"
make dev
```
<br><br>


## Steps to Cleanup Vagrant Machine Installation

#### Shutdown Vagrant Virtual Machine (Optional)
```
vagrant halt
```
<br>

#### Destroy Vagrant Virtual Machine
```
vagrant destroy
```

<br><br><br>

# Getting Started with Native Mac OSX

#### Note: This approach has been tested using Mac OSX 10.14+ Operating System.
<br>

## Prerequisites:

**Download Binaries**
* [Docker Desktop](https://hub.docker.com/editions/community/docker-ce-desktop-mac) and install Docker Desktop on your local system.
* [KIND](https://github.com/kubernetes-sigs/kind/releases) and install the kind binary on your local system.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos) and install the kubectl binary on your local system.
* [Helm](https://helm.sh/docs/intro/install/#from-homebrew-macos) and install the helm binary on your local system.
* [Skaffold](https://skaffold.dev/docs/install/) and install the skaffold binary on your local system.
* [jq](https://stedolan.github.io/jq/download/) and install the jq binary on your local system.
<br><br>


## Provisioning Instructions

#### Clone Project Repository
```
git clone https://github.com/abitvolatile/sample-app ./sample-app
cd sample-app
```
<br>

#### Deploy Kubernetes Cluster
```
# Switch to Root User
sudo -i

# Change to Project Directory
cd /sample-app

# Provisions the Kubernetes Cluster using KIND
make provision

# Prints the Kubernetes Config (Auth Token)
make kube-config
```
<br>

#### Deploy Hashicorp Vault (Optional)
```
# Change Directory to Install Vault
cd vault/

# Deploy HashiCorp Vault
./deploy-vault.sh
cd ..
```
<br>

#### Deploy Sample Application
```
export TAG="latest"
export NAMESPACE="sample-app"

kubectl create ns "${NAMESPACE}"
make dev
```
<br><br>


## Steps to Cleanup Docker Installation

#### Delete KIND Cluster Containers
```
# Note: This Deletes the KIND Cluster Nodes running as Docker Containers
make clean-kind
```
<br>

#### Purge Docker Container Images (Optional)
```
# WARNING: This removes ALL Docker Images, Containers, Volumes and Networks
make clean-docker
```
<br>

#### Remove KIND, Docker and Skaffold Cache and Configs (Only need to use if troubleshooting...!)
```
# WARNING: This removes ANY/ALL cache and/or configs for Docker, KIND and Skaffold tools.
make clean-all
```