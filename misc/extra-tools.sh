#!/bin/bash

### Homebrew ###

# Installs Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Configures Homebrew
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> /home/vagrant/.bash_profile
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)



### Kubernetes Tools ###

brew install kube-ps1
sudo cp /home/linuxbrew/.linuxbrew/opt/kube-ps1/share/kube-ps1.sh /usr/bin/
source "/usr/bin/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1


brew install kubectx
sudo cp /home/linuxbrew/.linuxbrew/opt/kubectx/bin/kubectx /usr/bin/

