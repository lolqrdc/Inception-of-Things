Vagrant.configure("2") do |config|

	config.vm.define "edetohS" do |master|
		master.vm.box = "generic/alpine312"
		master.vm.network "private_network", ip: "192.168.56.110"
		master.vm.hostname = "edetohS"
		master.vm.synced_folder "./confs", "/vagrant", type: "9p", disabled: false, accessmode: "squash", mount: true
		master.vm.provider "libvirt" do |lv|
			lv.memory = "1024"
			lv.cpus = "1"
			lv.title = "edetohS"
		end

		master.vm.provision "shell", inline: <<-SHELL
		curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -
		sleep 10
		sudo chmod 644 /etc/rancher/k3s/k3s.yaml
		
		# Attendre que le token soit créé
		NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"
		while [ ! -e ${NODE_TOKEN} ]
		do
			sleep 2
		done
		
		# Afficher le token pour debug
		sudo cat ${NODE_TOKEN}
		
		# Créer les fichiers dans /tmp puis les copier
		sudo cat ${NODE_TOKEN} > /tmp/node-token
		sudo chmod 644 /tmp/node-token
		
		KUBE_CONFIG="/etc/rancher/k3s/k3s.yaml"
		sudo cat ${KUBE_CONFIG} > /tmp/k3s.yaml
		sudo chmod 644 /tmp/k3s.yaml
		
		echo "Token et config créés dans /tmp/"
		echo "Token: $(cat /tmp/node-token)"
		SHELL
	end

	config.vm.define "edetohSW", autostart: false do |node1|
		node1.vm.box = "generic/alpine312"
		node1.vm.hostname = "edetohSW"
		node1.vm.synced_folder "./confs", "/vagrant", type: "9p", disabled: false, accessmode: "squash", mount: true
		node1.vm.network "private_network", ip: "192.168.56.111"
		node1.vm.provider "libvirt" do |lv|
			lv.memory = "1024"
			lv.cpus = "1"
			lv.title = "edetohSW"
		end

		node1.vm.provision "shell", inline: <<-SHELL
		# Attendre que le token soit disponible
		while [ ! -f /vagrant/node-token ]; do
			echo "En attente du token du master node..."
			sleep 5
		done
		curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$(sudo cat /vagrant/node-token) sh -
		sleep 10
		SHELL
	end

end