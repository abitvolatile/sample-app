#!/bin/bash

### Homebrew Installation

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> $HOME/.bash_profile
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)



### Tool Installations

brew install kube-ps1
sudo ln -s /home/linuxbrew/.linuxbrew/opt/kube-ps1/share/kube-ps1.sh /usr/bin/kube-ps1.sh
echo 'source /usr/bin/kube-ps1.sh' | sudo tee -a /etc/bashrc
echo -e "PS1='"'$(kube_ps1)'"'\$PS1" | sudo tee -a /etc/bashrc


brew install kubectx
sudo ln -s /home/linuxbrew/.linuxbrew/bin/kubectx /usr/bin/kubectx
sudo ln -s /home/linuxbrew/.linuxbrew/bin/kubens /usr/bin/kubens
