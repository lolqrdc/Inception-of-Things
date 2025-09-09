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
		# Installation K3s master
		curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -
		sleep 15
		sudo chmod 644 /etc/rancher/k3s/k3s.yaml

		# Attendre que le token soit créé
		NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"
		while [ ! -e ${NODE_TOKEN} ]
		do
			echo "Attente du token..."
			sleep 3
		done

		# Nettoyer le token des caractères parasites et le copier proprement
		sudo cat ${NODE_TOKEN} | tr -d '\\r\\n' > /tmp/node-token-clean
		echo >> /tmp/node-token-clean  # Ajouter un seul newline à la fin
		sudo chmod 644 /tmp/node-token-clean

		# Copier la configuration K3s
		KUBE_CONFIG="/etc/rancher/k3s/k3s.yaml"
		sudo cat ${KUBE_CONFIG} > /tmp/k3s.yaml
		sudo chmod 644 /tmp/k3s.yaml

		echo "Master K3s installé avec succès"
		echo "Token: $(cat /tmp/node-token-clean)"

		# Copier automatiquement les fichiers vers le dossier partagé via SSH
		echo "Copie automatique des fichiers..."
		sleep 5  # Attendre que le système soit stable
		SHELL

		# Trigger pour récupérer automatiquement les fichiers après l'installation
		master.trigger.after :provision do |trigger|
			trigger.name = "Récupération automatique des fichiers K3s"
			trigger.run = {inline: "./scripts/fetch_k3s_files.sh"}
		end
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
		echo "Démarrage du worker node..."

		# Attendre que le token soit disponible (avec timeout)
		TIMEOUT=300  # 5 minutes maximum
		ELAPSED=0
		while [ ! -f /vagrant/node-token ] && [ $ELAPSED -lt $TIMEOUT ]; do
			echo "En attente du token du master node... ($ELAPSED/$TIMEOUT secondes)"
			sleep 5
			ELAPSED=$((ELAPSED + 5))
		done

		if [ ! -f /vagrant/node-token ]; then
			echo "ERREUR: Token non disponible après $TIMEOUT secondes"
			exit 1
		fi

		# Nettoyer le token des caractères parasites
		TOKEN=$(cat /vagrant/node-token | tr -d '\\r\\n' | tr -d '\\0')
		if [ -z "$TOKEN" ]; then
			echo "ERREUR: Token vide après nettoyage"
			exit 1
		fi

		echo "Token récupéré: $TOKEN"

		# Installer K3s en mode agent avec variables d'environnement propres
		curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$TOKEN" sh -

		echo "Worker K3s installé avec succès"
		sleep 10
		SHELL
	end

end