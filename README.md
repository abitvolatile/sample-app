# sample-app<br>
This project is a sample open-source e-commerce platform by the name of [Spree Commerce](https://spreecommerce.org/). The application demonstrates a functional web application in a microservice architecture, which has been made to be easily deployed on a local Kubernetes cluster using a few open and free tools, such as Vagrant, Docker, KIND, Helm and Skaffold. The web application has also been pre-instrumented with Datadog's APM & RUM libraries for each of the components. The application's code has been broken intentionally in such a way to simulate what would appear to be a poor user-experience for visitors due slow load times.
<br><br><br>


## Project Overview

### Technology Stack:
* The Frontend component is a [Ruby-on-Rails](https://rubyonrails.org/) Web Server called [Puma](https://github.com/puma/puma), which serves traffic to users.
* There are two microservices that accompany the application written in Python using the Flask [Framework](https://flask.palletsprojects.com/en/1.1.x/).
  * The Discounts component serves up discount codes to users on product pages.
  * The Advertisements component displays banners on page using weighted priorities for frequency.
* The database component is Postgres DB using the [Official Postgres Docker Image](https://hub.docker.com/_/postgres).
<br><br><br>


### List of Software & Tools Used:
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)
* [CentOS](https://www.centos.org/)
* [Docker](https://www.docker.com/)
* [KIND](https://kind.sigs.k8s.io/)
* [Skaffold](https://skaffold.dev/)
* [Helm](https://helm.sh/)
* [HashiCorp Vault](https://www.vaultproject.io/)
* [VS Code](https://code.visualstudio.com/)
* [Lens App Kubernetes IDE](https://k8slens.dev/)
<br><br><br><br>


## Deployment Methods
* [Virtual Machine using Hashicorp Vagrant](#getting-started-using-hashicorp-vagrant)
* [Native Mac OSX w/Docker Containers](#getting-started-on-mac-osx-1014)
<br><br><br>

# Getting Started using Hashicorp Vagrant

#### Note: This approach using Vagrant has been tested using Mac OSX 10.14+ or CentOS 7 Operating Systems.
<br>

## Prerequisites:

**Download Binaries**
* [Download](https://www.virtualbox.org/wiki/Downloads) and install the VirtualBox binary on your local system.
* [Download](https://www.vagrantup.com/downloads) and install the Vagrant binary on your local system.
<br><br><br>


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


# Getting Started on Mac OSX 10.14+

#### Note: This approach using Vagrant has been tested using Mac OSX 10.14+ Operating System.
<br>

## Prerequisites:

**Download Binaries**
* [Docker Desktop](https://hub.docker.com/editions/community/docker-ce-desktop-mac) and install Docker Desktop on your local system.
* [KIND](https://github.com/kubernetes-sigs/kind/releases) and install the kind binary on your local system.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos) and install the kubectl binary on your local system.
* [Helm](https://helm.sh/docs/intro/install/#from-homebrew-macos) and install the helm binary on your local system.
* [Skaffold](https://skaffold.dev/docs/install/) and install the skaffold binary on your local system.
* [jq](https://stedolan.github.io/jq/download/) and install the jq binary on your local system.
<br><br><br>


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