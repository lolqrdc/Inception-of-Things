.PHONY: install up clean destroy status ssh-master ssh-worker cluster-info help start-p1 stop-p1 test-p1 clean-vbox

# Variables P1
VAGRANT_CMD = vagrant
VB_CMD = VBoxManage
HOST_IP = 192.168.56.110
VM_MASTER_NAME = edetohS
VM_WORKER_NAME = edetohSW

# Couleurs
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

# Installation et configuration initiale
install:
	@echo "$(GREEN)🚀 Installation d'Inception of Things...$(NC)"
	@chmod +x install.sh
	@cd .. && ./scripts/install.sh

up:
	@echo "$(GREEN)🚀 Démarrage du cluster K3s...$(NC)"
	@mkdir -p ../confs
	@chmod +x *.sh 2>/dev/null || true
	@$(MAKE) clean-vbox
	@echo "$(BLUE)📦 Démarrage du master node...$(NC)"
	@cd .. && $(VAGRANT_CMD) up edetohS
	@echo "$(GREEN)✅ Master démarré !$(NC)"
	@echo "$(BLUE)🚀 Démarrage du worker node...$(NC)"
	@cd .. && $(VAGRANT_CMD) up edetohSW
	@echo "$(GREEN)🎉 Cluster K3s opérationnel !$(NC)"
	@$(MAKE) cluster-info

# Nettoyage complet P1
clean:
	@echo "$(RED)🧹 Nettoyage de la partie 1...$(NC)"
	@cd .. && $(VAGRANT_CMD) destroy -f || true
	@$(MAKE) clean-vbox
	@echo "$(YELLOW)📁 Suppression des fichiers temporaires P1...$(NC)"
	@rm -f ../confs/node-token ../confs/k3s.yaml
	@rm -rf ../.vagrant
	@echo "$(GREEN)✅ Nettoyage P1 terminé !$(NC)"

# ===============================
# Commandes principales P1
# ===============================

# Démarrage P1
start-p1:
	@echo "$(GREEN)🚀 Démarrage de la partie 1 (Cluster K3s)...$(NC)"
	@$(MAKE) up
	@echo "$(GREEN)✅ Partie 1 démarrée avec succès !$(NC)"
	@$(MAKE) test-p1

# Arrêt P1
stop-p1:
	@echo "$(RED)🛑 Arrêt de la partie 1...$(NC)"
	@cd .. && $(VAGRANT_CMD) destroy -f || true
	@$(MAKE) clean-vbox
	@rm -f ../confs/node-token ../confs/k3s.yaml
	@rm -rf ../.vagrant
	@echo "$(GREEN)✅ Partie 1 arrêtée et nettoyée !$(NC)"

# Test P1
test-p1:
	@echo "$(BLUE)🧪 Test de la partie 1 (Cluster K3s)$(NC)"
	@echo "$(YELLOW)=== Test de connectivité des nœuds ===$(NC)"
	@if cd .. && $(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get nodes" 2>/dev/null | grep -q "Ready"; then \
		echo "$(GREEN)✅ Cluster K3s opérationnel$(NC)"; \
	else \
		echo "$(RED)❌ Cluster K3s non fonctionnel$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)=== Test des nœuds ===$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les nœuds$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Test des pods système ===$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get pods -n kube-system" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les pods$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Vérification des IPs ===$(NC)"
	@echo "$(BLUE)Server (edetohS):$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohS -c "ip addr show eth1 | grep 'inet '" 2>/dev/null || echo "$(RED)❌ IP Server introuvable$(NC)"
	@echo "$(BLUE)Worker (edetohSW):$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohSW -c "ip addr show eth1 | grep 'inet '" 2>/dev/null || echo "$(RED)❌ IP Worker introuvable$(NC)"
	@echo ""
	@echo "$(GREEN)🎉 Tests P1 terminés !$(NC)"

# Destruction des VMs uniquement
destroy:
	@echo "$(RED)🛑 Destruction des VMs...$(NC)"
	@cd .. && $(VAGRANT_CMD) destroy -f
	@$(MAKE) clean-vbox

# Statut des machines
status:
	@echo "$(BLUE)📊 Statut des machines :$(NC)"
	@cd .. && $(VAGRANT_CMD) status

# SSH vers le master
ssh-master:
	@echo "$(GREEN)🔑 Connexion SSH vers le master...$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohS

# SSH vers le worker
ssh-worker:
	@echo "$(GREEN)🔑 Connexion SSH vers le worker...$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohSW

# Informations sur le cluster
cluster-info:
	@echo "$(BLUE)🔍 Informations sur le cluster K3s :$(NC)"
	@echo "$(YELLOW)=== Nœuds du cluster ===$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null || echo "$(RED)❌ Cluster non accessible$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Pods système ===$(NC)"
	@cd .. && $(VAGRANT_CMD) ssh edetohS -c "sudo k3s kubectl get pods -A" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les pods$(NC)"

# Nettoyage des VMs VirtualBox résiduelles
clean-vbox:
	@if command -v $(VB_CMD) >/dev/null 2>&1; then \
		for vm in $(VM_MASTER_NAME) $(VM_WORKER_NAME); do \
			if $(VB_CMD) list vms | grep -q "\"$${vm}\""; then \
				echo "$(YELLOW)⚠️  Suppression de la VM résiduelle $${vm}...$(NC)"; \
				$(VB_CMD) controlvm "$${vm}" poweroff 2>/dev/null || true; \
				$(VB_CMD) unregistervm "$${vm}" --delete >/dev/null 2>&1 || true; \
			fi; \
		done; \
	else \
		echo "$(YELLOW)⚠️  VBoxManage non disponible, saut du nettoyage VirtualBox$(NC)"; \
	fi

# Aide P1
help:
	@echo "$(BLUE)📖 Inception of Things - Partie 1$(NC)"
	@echo ""
	@echo "$(GREEN)🚀 Commandes principales :$(NC)"
	@echo "  $(YELLOW)make install$(NC)      - Installer les dépendances"
	@echo "  $(YELLOW)make start-p1$(NC)     - Démarrer P1 (cluster K3s + test)"
	@echo "  $(YELLOW)make stop-p1$(NC)      - Arrêter et nettoyer P1"
	@echo "  $(YELLOW)make test-p1$(NC)      - Tester P1 (cluster + nœuds)"
	@echo ""
	@echo "$(GREEN)� Commandes utilitaires :$(NC)"
	@echo "  $(YELLOW)make up$(NC)           - Démarrer le cluster K3s"
	@echo "  $(YELLOW)make clean$(NC)        - Nettoyer P1"
	@echo "  $(YELLOW)make destroy$(NC)      - Détruire les VMs uniquement"
	@echo "  $(YELLOW)make status$(NC)       - Statut des VMs"
	@echo "  $(YELLOW)make cluster-info$(NC) - Informations cluster K3s"
	@echo "  $(YELLOW)make ssh-master$(NC)   - SSH vers le master (edetohS)"
	@echo "  $(YELLOW)make ssh-worker$(NC)   - SSH vers le worker (edetohSW)"
	@echo ""
	@echo "$(GREEN)🎯 Workflow recommandé :$(NC)"
	@echo "  1. $(YELLOW)make install$(NC)     # Installation initiale"
	@echo "  2. $(YELLOW)make start-p1$(NC)    # Démarrer et tester P1"
	@echo "  3. $(YELLOW)make stop-p1$(NC)     # Arrêter P1"
	@echo ""
	@echo "$(GREEN)�️ Architecture P1 :$(NC)"
	@echo "  • Master (edetohS): 192.168.56.110 - K3s server"
	@echo "  • Worker (edetohSW): 192.168.56.111 - K3s agent"
	@echo "  • Interface: eth1 (host-only network)"
	@echo ""
	@echo "$(BLUE)💡 Autres parties :$(NC)"
	@echo "  • P2: cd ../p2 && make help"
	@echo "  • P3: cd ../p3 && make help"
