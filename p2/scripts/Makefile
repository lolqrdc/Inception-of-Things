.PHONY: help start stop clean status test ssh logs

# Variables P2
VAGRANT_CMD = vagrant
VB_CMD = VBoxManage
HOST_IP = 192.168.56.110
VM_NAME = edetohS-p2
VAGRANTFILE_DIR = ..

# Couleurs
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

# Démarrage P2
start:
	@echo "$(GREEN)🚀 Démarrage de la partie 2 (K3s + 3 applications)...$(NC)"
	@$(MAKE) clean-vbox
	@echo "$(BLUE)📦 Démarrage du serveur P2...$(NC)"
	@cd $(VAGRANTFILE_DIR) && $(VAGRANT_CMD) up
	@echo "$(GREEN)✅ Partie 2 démarrée avec succès !$(NC)"
	@$(MAKE) test

# Arrêt P2
stop:
	@echo "$(RED)🛑 Arrêt de la partie 2...$(NC)"
	@cd $(VAGRANTFILE_DIR) && $(VAGRANT_CMD) destroy -f || true
	@$(MAKE) clean-vbox
	@cd $(VAGRANTFILE_DIR) && rm -f k3s.yaml
	@cd $(VAGRANTFILE_DIR) && rm -rf .vagrant
	@echo "$(GREEN)✅ Partie 2 arrêtée et nettoyée !$(NC)"

# Test P2
test:
	@echo "$(BLUE)🧪 Test de la partie 2$(NC)"
	@echo "$(YELLOW)=== Test de connectivité K3s ===$(NC)"
	@if cd $(VAGRANTFILE_DIR) && $(VAGRANT_CMD) ssh -c "sudo k3s kubectl get nodes" 2>/dev/null | grep -q "Ready"; then \
		echo "$(GREEN)✅ Serveur K3s opérationnel$(NC)"; \
	else \
		echo "$(RED)❌ Serveur K3s non fonctionnel$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)=== Test des applications ===$(NC)"
	@cd $(VAGRANTFILE_DIR) && $(VAGRANT_CMD) ssh -c "sudo k3s kubectl get pods -o wide" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les pods$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Test des services ===$(NC)"
	@cd $(VAGRANTFILE_DIR) && $(VAGRANT_CMD) ssh -c "sudo k3s kubectl get services" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les services$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Test de l'ingress ===$(NC)"
	@cd $(VAGRANTFILE_DIR) && $(VAGRANT_CMD) ssh -c "sudo k3s kubectl get ingress" 2>/dev/null || echo "$(RED)❌ Impossible de récupérer l'ingress$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Instructions de test ===$(NC)"
	@echo "$(BLUE)Pour tester les applications, ajoutez à votre /etc/hosts :$(NC)"
	@echo "$(HOST_IP) app1.com app2.com"
	@echo ""
	@echo "$(BLUE)Puis testez :$(NC)"
	@echo "• curl -H \"Host: app1.com\" http://$(HOST_IP)"
	@echo "• curl -H \"Host: app2.com\" http://$(HOST_IP)"
	@echo "• curl http://$(HOST_IP)  # app3 par défaut"
	@echo ""
	@echo "$(GREEN)🎉 Tests P2 terminés !$(NC)"

# Statut P2
status:
	@echo "$(BLUE)📊 Statut de la partie 2$(NC)"
	@echo "$(YELLOW)=== Statut de la VM ===$(NC)"
	@$(VAGRANT_CMD) status
	@echo ""
	@if $(VAGRANT_CMD) status | grep -q "running"; then \
		echo "$(YELLOW)=== Statut du cluster K3s ===$(NC)"; \
		$(VAGRANT_CMD) ssh -c "sudo k3s kubectl get nodes -o wide" 2>/dev/null || echo "$(RED)❌ K3s non accessible$(NC)"; \
		echo ""; \
		echo "$(YELLOW)=== Statut des applications ===$(NC)"; \
		$(VAGRANT_CMD) ssh -c "sudo k3s kubectl get pods,services,ingress" 2>/dev/null || echo "$(RED)❌ Applications non accessibles$(NC)"; \
	fi

# SSH vers le serveur
ssh:
	@echo "$(GREEN)🔑 Connexion SSH vers le serveur P2...$(NC)"
	@$(VAGRANT_CMD) ssh

# Logs des applications
logs:
	@echo "$(BLUE)📋 Logs des applications P2$(NC)"
	@echo "$(YELLOW)=== Logs app1 ===$(NC)"
	@$(VAGRANT_CMD) ssh -c "sudo k3s kubectl logs -l app=app1 --tail=10" 2>/dev/null || echo "$(RED)❌ Pas de logs app1$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Logs app2 ===$(NC)"
	@$(VAGRANT_CMD) ssh -c "sudo k3s kubectl logs -l app=app2 --tail=10" 2>/dev/null || echo "$(RED)❌ Pas de logs app2$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Logs app3 ===$(NC)"
	@$(VAGRANT_CMD) ssh -c "sudo k3s kubectl logs -l app=app3 --tail=10" 2>/dev/null || echo "$(RED)❌ Pas de logs app3$(NC)"

# Nettoyage des VMs VirtualBox résiduelles
clean-vbox:
	@if command -v $(VB_CMD) >/dev/null 2>&1; then \
		if $(VB_CMD) list vms | grep -q "\"$(VM_NAME)\""; then \
			echo "$(YELLOW)⚠️  Suppression de la VM résiduelle $(VM_NAME)...$(NC)"; \
			$(VB_CMD) controlvm "$(VM_NAME)" poweroff 2>/dev/null || true; \
			$(VB_CMD) unregistervm "$(VM_NAME)" --delete >/dev/null 2>&1 || true; \
		fi; \
	else \
		echo "$(YELLOW)⚠️  VBoxManage non disponible, saut du nettoyage VirtualBox$(NC)"; \
	fi

# Nettoyage complet
clean: stop

# Aide
help:
	@echo "$(BLUE)📖 Inception of Things - Partie 2$(NC)"
	@echo ""
	@echo "$(GREEN)🚀 Commandes disponibles :$(NC)"
	@echo "  $(YELLOW)make start$(NC)    - Démarrer P2 (K3s + 3 applications)"
	@echo "  $(YELLOW)make stop$(NC)     - Arrêter et nettoyer P2"
	@echo "  $(YELLOW)make test$(NC)     - Tester P2 (cluster + applications)"
	@echo "  $(YELLOW)make status$(NC)   - Afficher le statut de P2"
	@echo "  $(YELLOW)make ssh$(NC)      - Se connecter en SSH au serveur"
	@echo "  $(YELLOW)make logs$(NC)     - Afficher les logs des applications"
	@echo "  $(YELLOW)make clean$(NC)    - Nettoyage complet (= stop)"
	@echo ""
	@echo "$(GREEN)🎯 Workflow recommandé :$(NC)"
	@echo "  1. $(YELLOW)make start$(NC)   # Démarre P2 + test automatique"
	@echo "  2. $(YELLOW)make test$(NC)    # Tests supplémentaires si besoin"
	@echo "  3. $(YELLOW)make stop$(NC)    # Arrêt et nettoyage"
	@echo ""
	@echo "$(GREEN)🌐 Applications P2 :$(NC)"
	@echo "  • Serveur unique : $(HOST_IP)"
	@echo "  • app1.com → app1"
	@echo "  • app2.com → app2 (3 replicas)"
	@echo "  • default  → app3"
	@echo ""
	@echo "$(BLUE)💡 Configuration /etc/hosts :$(NC)"
	@echo "  $(HOST_IP) app1.com app2.com"