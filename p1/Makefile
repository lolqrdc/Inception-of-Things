.PHONY: install up clean destroy status ssh-master ssh-worker cluster-info help deploy-p2 clean-p2 status-p2 test-p2 full-deploy install-p3 setup-p3 deploy-p3 status-p3 port-forward-p3 test-p3 clean-p3 full-deploy-p3 full-deploy-all

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

# Démarrage du cluster K3s
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

# Déployer P2 sur ce cluster
deploy-p2:
	@echo "$(GREEN)🚀 Déploiement des applications P2 sur ce cluster K3s$(NC)"
	@if [ ! -f confs/k3s.yaml ]; then \
		echo "$(RED)❌ Cluster K3s non démarré$(NC)"; \
		echo "$(YELLOW)   Démarrez le cluster d'abord: make up$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)ℹ️  Correction de l'adresse du serveur dans kubeconfig...$(NC)"
	@sed -i 's|server: https://127.0.0.1:6443|server: https://192.168.56.110:6443|g' confs/k3s.yaml
	@echo "$(BLUE)ℹ️  Vérification de la connectivité...$(NC)"
	@if ! nc -z 192.168.56.110 6443 2>/dev/null; then \
		echo "$(RED)❌ Cluster non accessible$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📦 Déploiement de app1...$(NC)"
	@export KUBECONFIG=confs/k3s.yaml && kubectl apply -f ../p2/confs/app1-deployment.yaml --validate=false
	@export KUBECONFIG=confs/k3s.yaml && kubectl rollout status deployment/app1-deployment --timeout=120s
	@echo "$(BLUE)📦 Déploiement de app2...$(NC)"
	@export KUBECONFIG=confs/k3s.yaml && kubectl apply -f ../p2/confs/app2-deployment.yaml --validate=false
	@export KUBECONFIG=confs/k3s.yaml && kubectl rollout status deployment/app2-deployment --timeout=120s
	@echo "$(BLUE)📦 Déploiement de app3...$(NC)"
	@export KUBECONFIG=confs/k3s.yaml && kubectl apply -f ../p2/confs/app3-deployment.yaml --validate=false
	@export KUBECONFIG=confs/k3s.yaml && kubectl rollout status deployment/app3-deployment --timeout=120s
	@echo "$(BLUE)🌐 Configuration de l'Ingress...$(NC)"
	@export KUBECONFIG=confs/k3s.yaml && kubectl apply -f ../p2/confs/ingress.yaml --validate=false
	@echo "$(GREEN)✅ Applications P2 déployées avec succès!$(NC)"
	@echo ""
	@echo "$(BLUE)🌐 Applications accessibles via:$(NC)"
	@echo "  • http://app1.com (ajoutez '192.168.56.110 app1.com' à /etc/hosts)"
	@echo "  • http://app2.com (ajoutez '192.168.56.110 app2.com' à /etc/hosts)"
	@echo "  • http://192.168.56.110 (app3 par défaut)"

# Supprimer les applications P2
clean-p2:
	@echo "$(YELLOW)🧹 Suppression des applications P2$(NC)"
	@if [ -f confs/k3s.yaml ]; then \
		export KUBECONFIG=confs/k3s.yaml && \
		kubectl delete -f ../p2/confs/ingress.yaml --ignore-not-found=true && \
		kubectl delete -f ../p2/confs/app1-deployment.yaml --ignore-not-found=true && \
		kubectl delete -f ../p2/confs/app2-deployment.yaml --ignore-not-found=true && \
		kubectl delete -f ../p2/confs/app3-deployment.yaml --ignore-not-found=true; \
		echo "$(GREEN)✅ Applications P2 supprimées$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Cluster non accessible$(NC)"; \
	fi

# Statut des applications P2
status-p2:
	@echo "$(BLUE)📊 Statut des applications P2$(NC)"
	@if [ -f confs/k3s.yaml ]; then \
		export KUBECONFIG=confs/k3s.yaml && \
		echo "$(YELLOW)=== Pods P2 ===$(NC)" && \
		kubectl get pods -l 'app in (app1,app2,app3)' -o wide 2>/dev/null || echo "$(RED)❌ Aucun pod P2$(NC)"; \
		echo "" && \
		echo "$(YELLOW)=== Services P2 ===$(NC)" && \
		kubectl get services -l 'app in (app1,app2,app3)' 2>/dev/null || echo "$(RED)❌ Aucun service P2$(NC)"; \
		echo "" && \
		echo "$(YELLOW)=== Ingress P2 ===$(NC)" && \
		kubectl get ingress 2>/dev/null || echo "$(RED)❌ Aucun ingress$(NC)"; \
	else \
		echo "$(RED)❌ Cluster non accessible$(NC)"; \
	fi

# Test des applications P2
test-p2:
	@echo "$(BLUE)🧪 Test des applications P2$(NC)"
	@echo "$(YELLOW)Ajout des entrées /etc/hosts si nécessaire...$(NC)"
	@if ! grep -q "192.168.56.110 app1.com" /etc/hosts; then \
		echo "echo '192.168.56.110 app1.com' | sudo tee -a /etc/hosts"; \
	fi
	@if ! grep -q "192.168.56.110 app2.com" /etc/hosts; then \
		echo "echo '192.168.56.110 app2.com' | sudo tee -a /etc/hosts"; \
	fi
	@echo ""
	@echo "$(BLUE)Test app1:$(NC)"
	@curl -s -w "HTTP %{http_code}\n" http://app1.com -o /dev/null || echo "❌ app1 non accessible"
	@echo "$(BLUE)Test app2:$(NC)"
	@curl -s -w "HTTP %{http_code}\n" http://app2.com -o /dev/null || echo "❌ app2 non accessible"
	@echo "$(BLUE)Test app3:$(NC)"
	@curl -s -w "HTTP %{http_code}\n" http://192.168.56.110 -o /dev/null || echo "❌ app3 non accessible"

# Installer l'environnement P3 (K3d)
install-p3:
	@echo "$(GREEN)🚀 Installation de l'environnement P3 (K3d + ArgoCD)$(NC)"
	@cd ../p3 && chmod +x run.sh && ./run.sh install
	@echo "$(GREEN)✅ Environnement P3 installé !$(NC)"
	@echo "$(YELLOW)⚠️  Reconnectez-vous à votre session pour utiliser Docker$(NC)"

# Configurer ArgoCD
setup-p3:
	@echo "$(GREEN)🔧 Configuration d'ArgoCD...$(NC)"
	@cd ../p3 && ./run.sh setup
	@echo "$(GREEN)✅ ArgoCD configuré !$(NC)"

# Déployer l'application wil-playground
deploy-p3:
	@echo "$(GREEN)📦 Déploiement de l'application wil-playground...$(NC)"
	@cd ../p3 && ./run.sh deploy
	@echo "$(GREEN)✅ Application P3 déployée !$(NC)"

# Statut de P3
status-p3:
	@echo "$(BLUE)📊 Statut de la partie 3 (ArgoCD)$(NC)"
	@cd ../p3 && ./run.sh status

# Lancer le port-forward pour ArgoCD
port-forward-p3:
	@echo "$(BLUE)🌐 Lancement du port-forward ArgoCD...$(NC)"
	@echo "$(YELLOW)ArgoCD sera accessible sur: http://localhost:8080$(NC)"
	@echo "$(YELLOW)Mot de passe admin: $(NC)"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d && echo
	@echo ""
	@kubectl port-forward -n argocd pod/$$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}') 8080:8080

# Test de l'application P3
test-p3:
	@echo "$(BLUE)🧪 Test de l'application P3$(NC)"
	@cd ../p3 && chmod +x test-app.sh && ./test-app.sh test

# Nettoyage P3
clean-p3:
	@echo "$(YELLOW)🧹 Nettoyage de P3 (suppression du cluster K3d)$(NC)"
	@cd ../p3 && ./run.sh clean
	@echo "$(GREEN)✅ P3 nettoyé !$(NC)"

# Déploiement complet P3 (install + setup + deploy)
full-deploy-p3: install-p3 setup-p3 deploy-p3
	@echo "$(GREEN)🎉 P3 déployé complètement !$(NC)"
	@echo ""
	@echo "$(BLUE)🌐 ArgoCD accessible via:$(NC) https://localhost:8080"
	@echo "$(BLUE)🧪 Testez l'application avec:$(NC) make test-p3"

# Déploiement complet P1 + P2
full-deploy: up deploy-p2

# Déploiement complet de toutes les parties
full-deploy-all: full-deploy full-deploy-p3
	@echo "$(GREEN)🎉 Toutes les parties déployées !$(NC)"
	@echo ""
	@echo "$(BLUE)🌐 Applications disponibles :$(NC)"
	@echo "  • P1/P2: http://app1.com, http://app2.com, http://192.168.56.110"
	@echo "  • P3: ArgoCD https://localhost:8080"

# Aide
help:
	@echo "$(BLUE)📖 Aide - Makefile pour Inception of Things (P1 + P2)$(NC)"
	@echo ""
	@echo "$(GREEN)🏗️  Commandes P1 (Cluster K3s) :$(NC)"
	@echo "  $(YELLOW)make install$(NC)      - Installer les dépendances"
	@echo "  $(YELLOW)make up$(NC)           - Démarrer le cluster K3s"
	@echo "  $(YELLOW)make clean$(NC)        - Nettoyer P1 + P2 complètement"
	@echo "  $(YELLOW)make destroy$(NC)      - Détruire les VMs uniquement"
	@echo ""
	@echo "$(GREEN)📦 Commandes P2 (Applications) :$(NC)"
	@echo "  $(YELLOW)make deploy-p2$(NC)    - Déployer les applications P2"
	@echo "  $(YELLOW)make clean-p2$(NC)     - Supprimer les applications P2"
	@echo "  $(YELLOW)make status-p2$(NC)    - Statut des applications P2"
	@echo "  $(YELLOW)make test-p2$(NC)      - Tester les applications P2"
	@echo ""
	@echo "$(GREEN)🚀 Commandes P3 (ArgoCD) :$(NC)"
	@echo "  $(YELLOW)make install-p3$(NC)   - Installer l'environnement P3 (K3d)"
	@echo "  $(YELLOW)make setup-p3$(NC)     - Configurer ArgoCD"
	@echo "  $(YELLOW)make deploy-p3$(NC)    - Déployer l'application wil-playground"
	@echo "  $(YELLOW)make status-p3$(NC)    - Statut de P3"
	@echo "  $(YELLOW)make port-forward-p3$(NC) - Lancer le port-forward ArgoCD"
	@echo "  $(YELLOW)make test-p3$(NC)      - Tester l'application P3"
	@echo "  $(YELLOW)make clean-p3$(NC)     - Nettoyer P3 (supprimer le cluster K3d)"
	@echo ""
	@echo "$(GREEN)🚀 Commandes combinées :$(NC)"
	@echo "  $(YELLOW)make full-deploy$(NC)  - P1 + P2 en une commande"
	@echo "  $(YELLOW)make full-deploy-p3$(NC) - P3 complet en une commande"
	@echo "  $(YELLOW)make full-deploy-all$(NC) - P1 + P2 + P3 en une commande"
	@echo ""
	@echo "$(GREEN)ℹ️  Commandes d'information :$(NC)"
	@echo "  $(YELLOW)make status$(NC)       - Statut des VMs P1"
	@echo "  $(YELLOW)make cluster-info$(NC) - Informations cluster K3s"
	@echo "  $(YELLOW)make ssh-master$(NC)   - SSH vers le master"
	@echo "  $(YELLOW)make ssh-worker$(NC)   - SSH vers le worker"
	@echo ""
	@echo "$(BLUE)🎯 Workflows recommandés :$(NC)"
	@echo ""
	@echo "$(YELLOW)🚀 Démarrage rapide complet :$(NC)"
	@echo "  1. $(YELLOW)make install$(NC)     # Une seule fois"
	@echo "  2. $(YELLOW)make full-deploy$(NC) # P1 + P2 en une fois"
	@echo "  3. $(YELLOW)make test-p2$(NC)     # Tester les apps"
	@echo ""
	@echo "$(YELLOW)🔧 Démarrage étape par étape :$(NC)"
	@echo "  1. $(YELLOW)make up$(NC)          # Cluster K3s"
	@echo "  2. $(YELLOW)make deploy-p2$(NC)   # Applications"
	@echo "  3. $(YELLOW)make status-p2$(NC)   # Vérifier"
	@echo ""
	@echo "$(YELLOW)🚀 Démarrage P3 (ArgoCD) :$(NC)"
	@echo "  1. $(YELLOW)make install-p3$(NC)  # Installer K3d (reconnexion requise)"
	@echo "  2. $(YELLOW)make setup-p3$(NC)    # Configurer ArgoCD"
	@echo "  3. $(YELLOW)make deploy-p3$(NC)   # Déployer l'application"
	@echo "  4. $(YELLOW)make test-p3$(NC)     # Tester"
	@echo ""
	@echo "$(YELLOW)🌟 Démarrage complet (toutes les parties) :$(NC)"
	@echo "  1. $(YELLOW)make install$(NC)     # Une seule fois"
	@echo "  2. $(YELLOW)make full-deploy-all$(NC) # P1 + P2 + P3"
	@echo ""
	@echo "$(GREEN)🌐 Applications P2 déployées :$(NC)"
	@echo "  • http://app1.com"
	@echo "  • http://app2.com"
	@echo "  • http://192.168.56.110 (app3)"
	@echo ""
	@echo "$(GREEN)🌐 Applications P3 déployées :$(NC)"
	@echo "  • ArgoCD: https://localhost:8080"
	@echo "  • Test application: make test-p3"
