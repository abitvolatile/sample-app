Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
    
  # NOTE: You must install VirtualBox Guest Extensions by running: `$ vagrant plugin install vagrant-vbguest`
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.synced_folder ".", "/sample-app"
  config.vm.network "forwarded_port", guest: 33052, host: 33052
  config.vm.provider "virtualbox" do |v|
    v.memory = "8092"
    v.cpus = "4"
  end

  config.vm.provision "shell", inline: <<-SHELL
    
    # Install/Configure Dependencies for CentOS via Script
    cd /sample-app/
    ./install-centos.sh
    
    chown vagrant:vagrant /usr/bin/helm
  
  SHELL

end