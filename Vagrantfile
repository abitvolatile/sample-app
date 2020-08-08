Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network "forwarded_port", guest: 33052, host: 33052
  config.vm.provider "virtualbox" do |v|
    v.memory = "8092"
    v.cpus = "4"
  end
end
