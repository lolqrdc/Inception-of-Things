.PHONY: all up clean destroy re status ssh-server ssh-worker logs help fix-box cluster-info get-kubeconfig restart-k3s test-automation cleanup-orphans deploy

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
	@echo "$(GREEN)🚀 Démarrage du cluster K3s automatique...$(NC)"
	@echo "$(BLUE)🧹 Vérification et nettoyage préalable...$(NC)"
	@$(MAKE) -s cleanup-orphans || true
	@echo "$(BLUE)📁 Création du dossier confs si nécessaire...$(NC)"
	@mkdir -p confs
	@chmod 755 confs
	@echo "$(BLUE)🔧 Vérification que le script d'automatisation est exécutable...$(NC)"
	@chmod +x scripts/fetch_k3s_files.sh
	@echo "$(BLUE)⚡ Lancement des VMs avec Vagrant (100% automatique)...$(NC)"
	$(VAGRANT_CMD) up
	@echo "$(GREEN)✅ Cluster K3s déployé automatiquement avec succès !$(NC)"
	@echo "$(YELLOW)📋 Vérification de l'état du cluster...$(NC)"
	@sleep 5
	@$(MAKE) cluster-info
	@echo "$(GREEN)🎉 Déploiement 100% automatique terminé !$(NC)"

# Nettoyer et redémarrer complètement
re: clean up

# Alternative à 're'
remake: re

# Nettoyer complètement (destruction des VMs et nettoyage des ressources)
clean:
	@echo "$(RED)🧹 Nettoyage complet du projet...$(NC)"
	@echo "$(YELLOW)🛑 Arrêt et destruction des VMs...$(NC)"
	-$(VAGRANT_CMD) destroy -f
	@$(MAKE) -s cleanup-orphans
	@echo "$(YELLOW)📁 Nettoyage des fichiers temporaires...$(NC)"
	-rm -f confs/node-token*
	-rm -f confs/k3s.yaml*
	-rm -rf .vagrant
	@echo "$(GREEN)✅ Nettoyage complet terminé !$(NC)"

# Nettoyage des domaines orphelins (commande interne)
cleanup-orphans:
	@echo "$(YELLOW)🗑️  Suppression des domaines libvirt orphelins...$(NC)"
	-sudo virsh destroy $(PROJECT_NAME)_edetohS 2>/dev/null || true
	-sudo virsh destroy $(PROJECT_NAME)_edetohSW 2>/dev/null || true
	-sudo virsh destroy $(PROJECT_NAME)_agloriosS 2>/dev/null || true
	-sudo virsh destroy $(PROJECT_NAME)_agloriosSW 2>/dev/null || true
	-sudo virsh undefine $(PROJECT_NAME)_edetohS --remove-all-storage 2>/dev/null || true
	-sudo virsh undefine $(PROJECT_NAME)_edetohSW --remove-all-storage 2>/dev/null || true
	-sudo virsh undefine $(PROJECT_NAME)_agloriosS --remove-all-storage 2>/dev/null || true
	-sudo virsh undefine $(PROJECT_NAME)_agloriosSW --remove-all-storage 2>/dev/null || true
	@echo "$(YELLOW)🧹 Nettoyage des volumes orphelins...$(NC)"
	-sudo virsh vol-delete $(PROJECT_NAME)_edetohS.img default 2>/dev/null || true
	-sudo virsh vol-delete $(PROJECT_NAME)_edetohSW.img default 2>/dev/null || true
	-sudo virsh vol-delete $(PROJECT_NAME)_agloriosS.img default 2>/dev/null || true
	-sudo virsh vol-delete $(PROJECT_NAME)_agloriosSW.img default 2>/dev/null || true

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
	-$(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null || echo "$(RED)❌ Cluster non accessible$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Pods système ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get pods -A" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les pods$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Fichiers d'automatisation ===$(NC)"
	@if [ -f confs/node-token ] && [ -f confs/k3s.yaml ]; then \
		echo "$(GREEN)✅ Token et configuration K3s présents$(NC)"; \
		echo "$(BLUE)📄 Token: $$(wc -c < confs/node-token) bytes$(NC)"; \
		echo "$(BLUE)📄 Config: $$(wc -c < confs/k3s.yaml) bytes$(NC)"; \
	else \
		echo "$(RED)❌ Fichiers de configuration manquants$(NC)"; \
	fi

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

# Tester l'automatisation complète
test-automation:
	@echo "$(BLUE)🧪 Test de l'automatisation 100% automatique...$(NC)"
	@echo "$(YELLOW)⚠️  Ce test va détruire et recréer complètement le cluster !$(NC)"
	@read -p "Continuer ? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@$(MAKE) clean
	@echo "$(BLUE)⏳ Attente de 3 secondes...$(NC)"
	@sleep 3
	@$(MAKE) up
	@echo "$(GREEN)🎉 Test d'automatisation terminé avec succès !$(NC)"

# Surveillance en temps réel du cluster
monitor:
	@echo "$(BLUE)👀 Surveillance en temps réel du cluster K3s...$(NC)"
	@echo "$(YELLOW)Appuyez sur Ctrl+C pour arrêter$(NC)"
	@echo ""
	@while true; do \
		clear; \
		echo "$(GREEN)=== CLUSTER K3S - $$(date) ===$(NC)"; \
		echo ""; \
		$(MAKE) cluster-info 2>/dev/null; \
		echo ""; \
		echo "$(BLUE)Rafraîchissement dans 10 secondes...$(NC)"; \
		sleep 10; \
	done

# Validation rapide du cluster
validate:
	@echo "$(BLUE)✅ Validation rapide du cluster...$(NC)"
	@echo "$(YELLOW)=== Test de connectivité ===$(NC)"
	@$(VAGRANT_CMD) ssh edetohS -c "ping -c 3 192.168.56.111" >/dev/null 2>&1 && echo "$(GREEN)✅ Connectivité master → worker OK$(NC)" || echo "$(RED)❌ Problème de connectivité$(NC)"
	@echo "$(YELLOW)=== Test des services K3s ===$(NC)"
	@$(VAGRANT_CMD) ssh edetohS -c "sudo rc-service k3s status" >/dev/null 2>&1 && echo "$(GREEN)✅ Service K3s master OK$(NC)" || echo "$(RED)❌ Service K3s master en échec$(NC)"
	@$(VAGRANT_CMD) ssh edetohSW -c "sudo rc-service k3s-agent status" >/dev/null 2>&1 && echo "$(GREEN)✅ Service K3s worker OK$(NC)" || echo "$(RED)❌ Service K3s worker en échec$(NC)"
	@echo "$(YELLOW)=== Test des nœuds ===$(NC)"
	@if $(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get nodes --no-headers 2>/dev/null | grep -c Ready" 2>/dev/null | grep -q "2"; then \
		echo "$(GREEN)✅ Cluster avec 2 nœuds opérationnels$(NC)"; \
	else \
		echo "$(RED)❌ Cluster incomplet ou nœuds non prêts$(NC)"; \
	fi

# Déploiement complet automatisé (alternative qui force la récupération des fichiers)
deploy:
	@echo "$(GREEN)🚀 Déploiement complet du cluster K3s...$(NC)"
	@$(MAKE) up
	@echo "$(BLUE)📥 Récupération automatique des fichiers...$(NC)"
	@sleep 15
	@./scripts/fetch_k3s_files.sh
	@echo "$(BLUE)🔧 Déploiement du worker node...$(NC)"
	@$(VAGRANT_CMD) up edetohSW
	@echo "$(GREEN)🎉 Validation finale...$(NC)"
	@$(MAKE) validate
	@echo "$(GREEN)✅ Cluster K3s complètement déployé !$(NC)"

# Afficher l'aide
help:
	@echo "$(BLUE)📖 Aide - Makefile pour le cluster K3s$(NC)"
	@echo ""
	@echo "$(GREEN)Commandes principales :$(NC)"
	@echo "  $(YELLOW)make$(NC) ou $(YELLOW)make up$(NC)     - Créer et démarrer le master K3s"
	@echo "  $(YELLOW)make deploy$(NC)         - Déploiement complet automatisé (master + worker)"
	@echo "  $(YELLOW)make re$(NC)             - Nettoyer et redémarrer complètement"
	@echo "  $(YELLOW)make clean$(NC)          - Nettoyer complètement (VMs + ressources)"
	@echo "  $(YELLOW)make destroy$(NC)        - Détruire seulement les VMs"
	@echo ""
	@echo "$(GREEN)Commandes d'information :$(NC)"
	@echo "  $(YELLOW)make status$(NC)         - Afficher le statut des machines"
	@echo "  $(YELLOW)make cluster-info$(NC)   - Informations sur le cluster K3s"
	@echo "  $(YELLOW)make logs$(NC)           - Afficher les logs des services"
	@echo "  $(YELLOW)make validate$(NC)       - Validation rapide du cluster"
	@echo ""
	@echo "$(GREEN)Commandes de connexion :$(NC)"
	@echo "  $(YELLOW)make ssh-server$(NC)     - SSH vers le serveur K3s"
	@echo "  $(YELLOW)make ssh-worker$(NC)     - SSH vers le worker K3s"
	@echo ""
	@echo "$(GREEN)Commandes avancées :$(NC)"
	@echo "  $(YELLOW)make get-kubeconfig$(NC) - Copier la config kubectl vers l'hôte"
	@echo "  $(YELLOW)make restart-k3s$(NC)    - Redémarrer les services K3s"
	@echo "  $(YELLOW)make test-automation$(NC) - Tester l'automatisation complète"
	@echo "  $(YELLOW)make monitor$(NC)        - Surveillance en temps réel du cluster"
	@echo "  $(YELLOW)make fix-box$(NC)        - Réparer les problèmes de box Vagrant"
	@echo "  $(YELLOW)make help$(NC)           - Afficher cette aide"
	@echo ""
	@echo "$(BLUE)🚀 Démarrage rapide: $(YELLOW)make deploy$(NC) pour un cluster complet en une commande$(NC)"
	@echo "$(BLUE)💡 Astuce: Après 'make deploy', utilisez 'make get-kubeconfig' pour accéder au cluster depuis l'hôte$(NC)"

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
