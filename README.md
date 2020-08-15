# sample-app<br> 
This project is a sample open-source e-commerce platform by the name of [Spree Commerce](https://spreecommerce.org/).
The application demonstrates a functional web application in a microservice architecture, which has been make to easily be deployed on a Kubernetes cluster using a few tools, such as Vagrant, Docker, KIND, Helm and Skaffold.
The web application has also been pre-instrumented with the Datadog APM & RUM libraries for each of the compnents. The application's code has been broken intentionally in such a way to simulate what is a poor user-experience for visitors.

<br><br>

## Project Overview 

#### Technology Stack:
* The FrontEnd component is a [Ruby-on-Rails](https://rubyonrails.org/) Web Server called [Puma](https://github.com/puma/puma), which serves traffic to users.
* There are two microservices that accompany the application written in Python using the Flask [Framework](https://flask.palletsprojects.com/en/1.1.x/)
  * The Discounts component serves up discount codes to users on product pages.
  * The Advertisements component displays banners on the page with weighted values.
* The Database component is Postgres Database using the [Official Postgres Docker Image](https://hub.docker.com/_/postgres)
<br><br><br>


## Technology Overview
* VirtualBox [Link](https://www.virtualbox.org/)
* Vagrant [Link](https://www.vagrantup.com/)
* CentOS [Link](https://www.centos.org/)
* Docker [Link](https://www.docker.com/)
* KIND [Link](https://kind.sigs.k8s.io/)
* Skaffold [Link](https://skaffold.dev/)
* Helm [Link](https://helm.sh/)
* Kortena LENS IDE for Kubernetes [Link](https://k8slens.dev/)
<br><br><br>


## Getting Started

#### Note: This project has been tested using Mac OSX 10.14+ or CentOS 7 Operating Systems.
<br>

### Prerequisites

**Download and Binaries**
* [Download](https://www.virtualbox.org/wiki/Downloads) and install the VirtualBox binary on local system
* [Download](https://www.vagrantup.com/downloads) and install the Vagrant binary on local system
<br><br><br>


### Steps to Begin

#### Clone Project Repository
```
git clone https://github.com/abitvolatile/sample-app ./sample-app
cd sample-app
```

#### Provision Vagrant (CentOS7) Virtual Machine
```
# Installs VirtualBox Guest Extensions
vagrant plugin install vagrant-vbguest

# Provisions Virtual Machine using Vagrantfile
vagrant up

# Connects to Virtual Machine via SSH
vagrant ssh
```

#### Deploy Kubernetes Cluster, any supporting services and the Sample Web Application
```
# Switch user to Root User
sudo -i

# Change Directory to Project Directory
cd /sample-app

# Provisions the Kubernetes Cluster using Kind
make provision

# Prints the Kubernetes Config (Auth Token)
make kube-config

# Deploy HashiCorp Vault Installation Directory (Optional)
cd vault/
./deploy-vault.sh
cd ..

# Set 
export TAG="latest"
make dev
```

#### Stop/Shutdown Vagrant Virtual Machine
```
vagrant halt
```

#### Cleaning Up Resources
```
vagrant destroy
```