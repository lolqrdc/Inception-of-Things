.PHONY: all install up clean destroy status ssh-master ssh-worker cluster-info help

# Variables
VAGRANT_CMD = vagrant
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

# Installation et configuration initiale
install:
	@echo "$(GREEN)🚀 Installation d'Inception of Things...$(NC)"
	@chmod +x install.sh
	@./install.sh

# Démarrage du cluster K3s complet
all: up
up:
	@echo "$(GREEN)� Démarrage du cluster K3s...$(NC)"
	@mkdir -p confs
	@chmod +x scripts/*.sh 2>/dev/null || true
	@echo "$(BLUE)📦 Démarrage du master node...$(NC)"
	$(VAGRANT_CMD) up edetohS
	@echo "$(GREEN)✅ Master démarré !$(NC)"
	@echo "$(BLUE)� Démarrage du worker node...$(NC)"
	$(VAGRANT_CMD) up edetohSW
	@echo "$(GREEN)🎉 Cluster K3s opérationnel !$(NC)"
	@$(MAKE) cluster-info

# Nettoyage complet
clean:
	@echo "$(RED)🧹 Nettoyage complet...$(NC)"
	-$(VAGRANT_CMD) destroy -f
	@echo "$(YELLOW)📁 Suppression des fichiers temporaires...$(NC)"
	-rm -f confs/node-token confs/k3s.yaml
	-rm -rf .vagrant
	@echo "$(GREEN)✅ Nettoyage terminé !$(NC)"

# Destruction des VMs uniquement
destroy:
	@echo "$(RED)🛑 Destruction des VMs...$(NC)"
	$(VAGRANT_CMD) destroy -f

# Statut des machines
status:
	@echo "$(BLUE)📊 Statut des machines :$(NC)"
	$(VAGRANT_CMD) status

# SSH vers le master
ssh-master:
	@echo "$(GREEN)🔑 Connexion SSH vers le master...$(NC)"
	$(VAGRANT_CMD) ssh edetohS

# SSH vers le worker
ssh-worker:
	@echo "$(GREEN)🔑 Connexion SSH vers le worker...$(NC)"
	$(VAGRANT_CMD) ssh edetohSW

# Informations sur le cluster
cluster-info:
	@echo "$(BLUE)🔍 Informations sur le cluster K3s :$(NC)"
	@echo "$(YELLOW)=== Nœuds du cluster ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null || echo "$(RED)❌ Cluster non accessible$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Pods système ===$(NC)"
	-$(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get pods -A" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les pods$(NC)"

# Aide
help:
	@echo "$(BLUE)� Aide - Makefile pour Inception of Things$(NC)"
	@echo ""
	@echo "$(GREEN)Commandes principales :$(NC)"
	@echo "  $(YELLOW)make install$(NC)      - Installer toutes les dépendances"
	@echo "  $(YELLOW)make up$(NC)           - Créer et démarrer le cluster K3s"
	@echo "  $(YELLOW)make clean$(NC)        - Nettoyer complètement"
	@echo "  $(YELLOW)make destroy$(NC)      - Détruire les VMs uniquement"
	@echo ""
	@echo "$(GREEN)Commandes d'information :$(NC)"
	@echo "  $(YELLOW)make status$(NC)       - Statut des machines"
	@echo "  $(YELLOW)make cluster-info$(NC) - Informations sur le cluster"
	@echo ""
	@echo "$(GREEN)Commandes de connexion :$(NC)"
	@echo "  $(YELLOW)make ssh-master$(NC)   - SSH vers le master"
	@echo "  $(YELLOW)make ssh-worker$(NC)   - SSH vers le worker"
	@echo ""
	@echo "$(BLUE)🚀 Démarrage rapide:$(NC)"
	@echo "  1. $(YELLOW)make install$(NC)  # Une seule fois"
	@echo "  2. $(YELLOW)make up$(NC)       # Démarrer le cluster"
