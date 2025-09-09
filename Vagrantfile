Vagrant.configure("2") do |config|

  config.vm.define "edetohS" do |master|
    master.vm.box = "generic/alpine312"
    master.vm.network "private_network", ip: "192.168.56.110"
    master.vm.hostname = "edetohS"

    master.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
      vb.name = "edetohS"
    end

    master.vm.provider "libvirt" do |lv|
      lv.memory = "1024"
      lv.cpus = 1
      lv.driver = "kvm"
    end

    master.vm.provision "shell", path: "scripts/install_k3s_server.sh"
  end

  config.vm.define "edetohSW" do |node1|
    node1.vm.box = "generic/alpine312"
    node1.vm.hostname = "edetohSW"
    node1.vm.network "private_network", ip: "192.168.56.111"

    node1.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
      vb.name = "edetohSW"
    end

    node1.vm.provider "libvirt" do |lv|
      lv.memory = "1024"
      lv.cpus = 1
      lv.driver = "kvm"
    end

    # Le worker ne démarre qu'après le serveur
    node1.vm.provision "shell", path: "scripts/install_k3s_worker.sh"
  end

end
