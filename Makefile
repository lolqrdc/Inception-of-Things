.PHONY: all up clean destroy re status ssh-server ssh-worker logs help fix-box

# Variables
VAGRANT_CMD = vagrant
PROJECT_NAME = p1-vagrant

# Couleurs pour l'affichage
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Target par défaut
all: up

# Lancer les machines virtuelles
up:
	@echo "$(GREEN)🚀 Démarrage du cluster K3s...$(NC)"
	@echo "$(BLUE)📁 Création du dossier confs si nécessaire...$(NC)"
	@mkdir -p confs
	@chmod 755 confs
	@echo "$(BLUE)⚡ Lancement des VMs avec Vagrant...$(NC)"
	$(VAGRANT_CMD) up
	@echo "$(GREEN)✅ Cluster K3s démarré avec succès !$(NC)"
	@echo "$(YELLOW)📋 Utilisez 'make status' pour voir l'état des machines$(NC)"

# Nettoyer et redémarrer complètement
re: clean up

# Alternative à 're'
remake: re

# Nettoyer complètement (destruction des VMs et nettoyage des ressources)
clean:
	@echo "$(RED)🧹 Nettoyage complet du projet...$(NC)"
	@echo "$(YELLOW)🛑 Arrêt et destruction des VMs...$(NC)"
	-$(VAGRANT_CMD) destroy -f
	@echo "$(YELLOW)🗑️  Suppression des domaines libvirt orphelins...$(NC)"
	-sudo virsh undefine $(PROJECT_NAME)_edetohS 2>/dev/null || true
	-sudo virsh undefine $(PROJECT_NAME)_edetohSW 2>/dev/null || true
	@echo "$(YELLOW)📁 Nettoyage des fichiers temporaires...$(NC)"
	-rm -f confs/node-token*
	-rm -f confs/k3s.yaml*
	@echo "$(GREEN)✅ Nettoyage terminé !$(NC)"

# Destruction des VMs seulement
destroy:
	@echo "$(RED)🛑 Destruction des machines virtuelles...$(NC)"
	$(VAGRANT_CMD) destroy -f
	@echo "$(GREEN)✅ Machines détruites !$(NC)"

# Afficher le statut des machines
status:
	@echo "$(BLUE)📊 Statut des machines Vagrant :$(NC)"
	$(VAGRANT_CMD) status
	@echo ""
	@echo "$(BLUE)📊 Statut des domaines libvirt :$(NC)"
	@sudo virsh list --all | grep -E "(edetohS|edetohSW)" || echo "Aucun domaine trouvé"

# SSH vers le serveur
ssh-server:
	@echo "$(GREEN)🔑 Connexion SSH vers le serveur (edetohS)...$(NC)"
	$(VAGRANT_CMD) ssh edetohS

# SSH vers le worker
ssh-worker:
	@echo "$(GREEN)🔑 Connexion SSH vers le worker (edetohSW)...$(NC)"
	$(VAGRANT_CMD) ssh edetohSW

# Afficher les logs des machines
logs:
	@echo "$(BLUE)📝 Logs de la dernière exécution :$(NC)"
	@echo "$(YELLOW)=== Logs du serveur (edetohS) ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "sudo journalctl -u k3s --no-pager -n 20" 2>/dev/null || echo "Pas de logs disponibles"
	@echo ""
	@echo "$(YELLOW)=== Logs du worker (edetohSW) ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohSW -c "sudo journalctl -u k3s-agent --no-pager -n 20" 2>/dev/null || echo "Pas de logs disponibles"

# Vérifier l'état du cluster K3s
cluster-info:
	@echo "$(BLUE)🔍 Informations sur le cluster K3s :$(NC)"
	@echo "$(YELLOW)=== Nœuds du cluster ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "kubectl get nodes -o wide" 2>/dev/null || echo "Cluster non accessible"
	@echo ""
	@echo "$(YELLOW)=== Pods système ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "kubectl get pods -A" 2>/dev/null || echo "Impossible de récupérer les pods"

# Copier la configuration kubectl vers l'hôte
get-kubeconfig:
	@echo "$(BLUE)📋 Récupération de la configuration kubectl...$(NC)"
	@mkdir -p ~/.kube
	@if [ -f confs/k3s.yaml ]; then \
		cp confs/k3s.yaml ~/.kube/config-p1; \
		sed -i 's/127.0.0.1/192.168.56.110/g' ~/.kube/config-p1; \
		chmod 600 ~/.kube/config-p1; \
		echo "$(GREEN)✅ Configuration copiée vers ~/.kube/config-p1$(NC)"; \
		echo "$(YELLOW)💡 Utilisez: export KUBECONFIG=~/.kube/config-p1$(NC)"; \
	else \
		echo "$(RED)❌ Fichier k3s.yaml non trouvé dans confs/$(NC)"; \
	fi

# Redémarrer les services K3s
restart-k3s:
	@echo "$(YELLOW)🔄 Redémarrage des services K3s...$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "sudo rc-service k3s restart"
	-$(VAGRANT_CMD) ssh edetohSW -c "sudo rc-service k3s-agent restart"
	@echo "$(GREEN)✅ Services redémarrés !$(NC)"

# Afficher l'aide
help:
	@echo "$(BLUE)📖 Aide - Makefile pour le cluster K3s$(NC)"
	@echo ""
	@echo "$(GREEN)Commandes principales :$(NC)"
	@echo "  $(YELLOW)make$(NC) ou $(YELLOW)make up$(NC)     - Créer et démarrer le cluster K3s"
	@echo "  $(YELLOW)make re$(NC)             - Nettoyer et redémarrer complètement"
	@echo "  $(YELLOW)make clean$(NC)          - Nettoyer complètement (VMs + ressources)"
	@echo "  $(YELLOW)make destroy$(NC)        - Détruire seulement les VMs"
	@echo ""
	@echo "$(GREEN)Commandes d'information :$(NC)"
	@echo "  $(YELLOW)make status$(NC)         - Afficher le statut des machines"
	@echo "  $(YELLOW)make cluster-info$(NC)   - Informations sur le cluster K3s"
	@echo "  $(YELLOW)make logs$(NC)           - Afficher les logs des services"
	@echo ""
	@echo "$(GREEN)Commandes de connexion :$(NC)"
	@echo "  $(YELLOW)make ssh-server$(NC)     - SSH vers le serveur K3s"
	@echo "  $(YELLOW)make ssh-worker$(NC)     - SSH vers le worker K3s"
	@echo ""
	@echo "$(GREEN)Commandes utiles :$(NC)"
	@echo "  $(YELLOW)make get-kubeconfig$(NC) - Copier la config kubectl vers l'hôte"
	@echo "  $(YELLOW)make restart-k3s$(NC)    - Redémarrer les services K3s"
	@echo "  $(YELLOW)make fix-box$(NC)        - Réparer les problèmes de box Vagrant"
	@echo "  $(YELLOW)make help$(NC)           - Afficher cette aide"
	@echo ""
	@echo "$(BLUE)💡 Astuce: Après 'make up', utilisez 'make get-kubeconfig' pour accéder au cluster depuis l'hôte$(NC)"

# Réparer les problèmes de box Vagrant corrompue
fix-box:
	@echo "$(RED)🔧 Réparation des problèmes de box Vagrant...$(NC)"
	@echo "$(YELLOW)🛑 Nettoyage des métadonnées Vagrant...$(NC)"
	-sudo rm -rf .vagrant
	@echo "$(YELLOW)🗑️  Suppression de la box Alpine corrompue...$(NC)"
	-vagrant box remove generic/alpine312 --force
	@echo "$(YELLOW)🧹 Nettoyage des volumes libvirt orphelins...$(NC)"
	-sudo virsh vol-delete generic-VAGRANTSLASH-alpine312_vagrant_box_image_4.3.12_box.img default 2>/dev/null || true
	@echo "$(YELLOW)📦 Retéléchargement de la box Alpine...$(NC)"
	vagrant box add generic/alpine312 --provider libvirt
	@echo "$(GREEN)✅ Réparation terminée ! Vous pouvez maintenant utiliser 'make up'$(NC)"
