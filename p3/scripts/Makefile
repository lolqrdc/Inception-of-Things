.PHONY: help start stop clean status test ssh logs install deploy validate restart argocd-ui port-forward clean-k3d clean-vbox

# Variables P3
VAGRANT_CMD = vagrant
VB_CMD = VBoxManage
HOST_IP = 192.168.56.110
VM_NAME = edetohS-p3
SCRIPTS_DIR = .
CONFS_DIR = ../confs
KUBECTL = ../kubectl

# Couleurs
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
NC = \033[0m

# Installation et démarrage P3
install:
	@echo "$(GREEN)🚀 Installation de la partie 3 (K3d + ArgoCD)...$(NC)"
	@$(MAKE) clean-k3d
	@$(MAKE) clean-vbox
	@echo "$(BLUE)📦 Installation de K3d et ArgoCD...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@./install.sh
	@echo "$(GREEN)✅ Installation P3 terminée !$(NC)"

# Démarrage complet P3
start: install
	@echo "$(GREEN)🌟 Démarrage de la partie 3...$(NC)"
	@echo "$(BLUE)🔧 Configuration de l'environnement...$(NC)"
	@./setup.sh
	@echo "$(BLUE)🚀 Déploiement des applications...$(NC)"
	@./deploy-apps.sh
	@echo "$(GREEN)✅ Partie 3 démarrée avec succès !$(NC)"
	@$(MAKE) test

# Arrêt P3
stop:
	@echo "$(RED)🛑 Arrêt de la partie 3...$(NC)"
	@./run.sh clean 2>/dev/null || true
	@$(MAKE) clean-k3d
	@$(MAKE) clean-vbox
	@echo "$(GREEN)✅ Partie 3 arrêtée et nettoyée !$(NC)"

# Déploiement des applications
deploy:
	@echo "$(BLUE)🚀 Déploiement des applications P3...$(NC)"
	@./deploy-apps.sh
	@echo "$(GREEN)✅ Applications déployées !$(NC)"

# Test P3
test:
	@echo "$(BLUE)🧪 Test de la partie 3$(NC)"
	@echo "$(YELLOW)=== Test de K3d ===$(NC)"
	@if k3d cluster list 2>/dev/null | grep -q "iot-cluster"; then \
		echo "$(GREEN)✅ Cluster K3d 'iot-cluster' opérationnel$(NC)"; \
	else \
		echo "$(RED)❌ Cluster K3d 'iot-cluster' non trouvé$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)=== Test d'ArgoCD ===$(NC)"
	@if $(KUBECTL) get pods -n argocd 2>/dev/null | grep -q "argocd-server.*Running"; then \
		echo "$(GREEN)✅ ArgoCD installé et en cours d'exécution$(NC)"; \
	else \
		echo "$(RED)❌ ArgoCD non installé ou non fonctionnel$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(YELLOW)=== Test de l'application Wil ===$(NC)"
	@if $(KUBECTL) get application -n argocd 2>/dev/null | grep -q "wil-playground"; then \
		echo "$(GREEN)✅ Application Wil déployée dans ArgoCD$(NC)"; \
	else \
		echo "$(RED)❌ Application Wil non déployée dans ArgoCD$(NC)"; \
	fi
	@if $(KUBECTL) get svc wil-playground-service -n dev >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Service wil-playground-service disponible$(NC)"; \
	else \
		echo "$(RED)❌ Service wil-playground-service non trouvé$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)=== Statut des pods ===$(NC)"
	@$(KUBECTL) get pods -A 2>/dev/null || echo "$(RED)❌ Impossible de récupérer les pods$(NC)"
	@echo ""
	@./test-app.sh 2>/dev/null || echo "$(YELLOW)⚠️  Test d'application non disponible$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Instructions de test ===$(NC)"
	@echo "$(BLUE)Pour tester wil-playground :$(NC)"
	@echo "1. $(YELLOW)make port-forward$(NC)  # Lance le port-forward"
	@echo "2. Dans un autre terminal : $(YELLOW)curl http://localhost:8889/$(NC)"
	@echo "3. Ou dans le navigateur : $(YELLOW)http://localhost:8889$(NC)"
	@echo ""
	@echo "$(GREEN)🎉 Tests P3 terminés !$(NC)"

# Validation complète
validate:
	@echo "$(PURPLE)🔍 Validation complète de la partie 3$(NC)"
	@./validate.sh
	@echo "$(GREEN)✅ Validation terminée !$(NC)"

# Statut P3
status:
	@echo "$(BLUE)📊 Statut de la partie 3$(NC)"
	@echo "$(YELLOW)=== Statut K3d ===$(NC)"
	@k3d cluster list 2>/dev/null || echo "$(RED)❌ K3d non disponible$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Statut ArgoCD ===$(NC)"
	@$(KUBECTL) get pods -n argocd 2>/dev/null || echo "$(RED)❌ ArgoCD non accessible$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Applications ArgoCD ===$(NC)"
	@$(KUBECTL) get applications -n argocd 2>/dev/null || echo "$(RED)❌ Applications non accessibles$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Statut des namespaces ===$(NC)"
	@$(KUBECTL) get namespaces 2>/dev/null || echo "$(RED)❌ Kubectl non accessible$(NC)"

# Port-forward pour l'application wil-playground
port-forward:
	@echo "$(GREEN)🌐 Port-forward vers wil-playground...$(NC)"
	@if ! $(KUBECTL) get svc wil-playground-service -n dev >/dev/null 2>&1; then \
		echo "$(RED)❌ Service wil-playground-service non trouvé dans le namespace dev$(NC)"; \
		echo "$(YELLOW)💡 Lancez d'abord 'make start' pour déployer l'application$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🌐 Application accessible sur: http://localhost:8889$(NC)"
	@echo "$(YELLOW)🚀 Port-forward en cours (Ctrl+C pour arrêter)...$(NC)"
	@$(KUBECTL) port-forward svc/wil-playground-service -n dev 8889:8888

# Accès ArgoCD UI
argocd-ui:
	@echo "$(GREEN)🌐 Accès à ArgoCD UI$(NC)"
	@echo "$(BLUE)💡 URL: https://localhost:8080$(NC)"
	@echo "$(BLUE)💡 Username: admin$(NC)"
	@echo "$(BLUE)💡 Password: Récupération du mot de passe...$(NC)"
	@./kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "$(RED)❌ Impossible de récupérer le mot de passe$(NC)"
	@echo ""
	@echo "$(YELLOW)🚀 Port-forward en cours...$(NC)"
	@./kubectl port-forward svc/argocd-server -n argocd 8080:443 &
	@echo "$(GREEN)✅ ArgoCD accessible sur https://localhost:8080$(NC)"

# Logs
logs:
	@echo "$(BLUE)📋 Logs de la partie 3$(NC)"
	@echo "$(YELLOW)=== Logs ArgoCD Server ===$(NC)"
	@./kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=10 2>/dev/null || echo "$(RED)❌ Pas de logs ArgoCD server$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Logs Application Wil ===$(NC)"
	@./kubectl logs -n dev -l app=wil-playground --tail=10 2>/dev/null || echo "$(RED)❌ Pas de logs application Wil$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Logs ArgoCD Application Controller ===$(NC)"
	@./kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=10 2>/dev/null || echo "$(RED)❌ Pas de logs controller$(NC)"

# Redémarrage des services
restart:
	@echo "$(YELLOW)🔄 Redémarrage des services P3...$(NC)"
	@./$(SCRIPTS_DIR)/run.sh restart 2>/dev/null || echo "$(YELLOW)⚠️  Script restart non disponible$(NC)"
	@echo "$(GREEN)✅ Services redémarrés !$(NC)"

# Nettoyage des clusters K3d résiduels
clean-k3d:
	@if command -v k3d >/dev/null 2>&1; then \
		echo "$(YELLOW)🧹 Nettoyage des clusters K3d existants...$(NC)"; \
		k3d cluster list 2>/dev/null | grep -E "iot-cluster|wil" | awk '{print $$1}' | xargs -r k3d cluster delete 2>/dev/null || true; \
		echo "$(GREEN)✅ Clusters K3d nettoyés$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  K3d non disponible, saut du nettoyage$(NC)"; \
	fi

# Nettoyage VirtualBox (au cas où)
clean-vbox:
	@if command -v $(VB_CMD) >/dev/null 2>&1; then \
		if $(VB_CMD) list vms | grep -q "\"$(VM_NAME)\""; then \
			echo "$(YELLOW)⚠️  Suppression de la VM résiduelle $(VM_NAME)...$(NC)"; \
			$(VB_CMD) controlvm "$(VM_NAME)" poweroff 2>/dev/null || true; \
			$(VB_CMD) unregistervm "$(VM_NAME)" --delete >/dev/null 2>&1 || true; \
		fi; \
	fi

# Nettoyage complet
clean: stop clean-k3d clean-vbox
	@echo "$(GREEN)✅ Nettoyage complet P3 terminé !$(NC)"

# Aide
help:
	@echo "$(BLUE)📖 Inception of Things - Partie 3$(NC)"
	@echo ""
	@echo "$(GREEN)🚀 Commandes principales :$(NC)"
	@echo "  $(YELLOW)make install$(NC)     - Installer K3d et ArgoCD"
	@echo "  $(YELLOW)make start$(NC)       - Démarrage complet P3 (install + setup + deploy + test)"
	@echo "  $(YELLOW)make stop$(NC)        - Arrêter et nettoyer P3"
	@echo "  $(YELLOW)make deploy$(NC)      - Déployer les applications"
	@echo "  $(YELLOW)make test$(NC)        - Tester P3 (cluster + ArgoCD + apps)"
	@echo "  $(YELLOW)make validate$(NC)    - Validation complète"
	@echo ""
	@echo "$(GREEN)🔧 Commandes utilitaires :$(NC)"
	@echo "  $(YELLOW)make status$(NC)      - Afficher le statut de P3"
	@echo "  $(YELLOW)make logs$(NC)        - Afficher les logs"
	@echo "  $(YELLOW)make restart$(NC)     - Redémarrer les services"
	@echo "  $(YELLOW)make argocd-ui$(NC)   - Accéder à ArgoCD UI"
	@echo "  $(YELLOW)make port-forward$(NC) - Port-forward vers wil-playground"
	@echo "  $(YELLOW)make clean$(NC)       - Nettoyage complet"
	@echo ""
	@echo "$(GREEN)🎯 Workflow recommandé :$(NC)"
	@echo "  1. $(YELLOW)make start$(NC)        # Installation + démarrage + test automatique"
	@echo "  2. $(YELLOW)make argocd-ui$(NC)    # Accès à l'interface ArgoCD"
	@echo "  3. $(YELLOW)make port-forward$(NC) # Port-forward vers wil-playground"
	@echo "  4. $(YELLOW)make validate$(NC)     # Validation complète"
	@echo "  5. $(YELLOW)make stop$(NC)         # Arrêt et nettoyage"
	@echo ""
	@echo "$(GREEN)🌟 Technologies P3 :$(NC)"
	@echo "  • K3d : Cluster Kubernetes dans Docker"
	@echo "  • ArgoCD : GitOps et déploiement continu"
	@echo "  • Application Wil : Déployée via GitOps"
	@echo ""
	@echo "$(BLUE)💡 ArgoCD UI :$(NC)"
	@echo "  • URL: https://localhost:8080"
	@echo "  • Username: admin"
	@echo "  • Password: voir 'make argocd-ui'"