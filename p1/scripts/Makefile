.PHONY: \
	install up clean destroy status ssh-master ssh-worker cluster-info help \
	deploy-p2 clean-p2 status-p2 test-p2 install-p3 setup-p3 deploy-p3 \
	deploy-p3-full status-p3 port-forward-p3 test-p3 clean-p3 start-all stop-all \
	clean-vbox dockerhub-secret start-p1 stop-p1 test-p1

# Variables
VAGRANT_CMD = vagrant
VB_CMD = VBoxManage
HOST_IP = 192.168.56.110
KUBECONFIG_P2 = ../confs/k3s.yaml
VM_MASTER_NAME = edetohS
VM_WORKER_NAME = edetohSW
ENV_FILE = ../../.env

ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export DOCKERHUB_USERNAME
export DOCKERHUB_TOKEN
export DOCKERHUB_EMAIL
endif
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

# Nettoyage complet
clean:
	@echo "$(RED)🧹 Nettoyage complet...$(NC)"
	@$(MAKE) clean-p2 || true
	@$(MAKE) clean-p3 || true
	@cd .. && $(VAGRANT_CMD) destroy -f || true
	@$(MAKE) clean-vbox
	@echo "$(YELLOW)📁 Suppression des fichiers temporaires...$(NC)"
	@rm -f ../confs/node-token ../confs/k3s.yaml
	@rm -rf ../.vagrant
	@echo "$(GREEN)✅ Nettoyage terminé (P1, P2, P3)!$(NC)"

# Arrêt complet (toutes les parties)
stop-all:
	@echo "$(RED)🛑 Arrêt de toutes les parties...$(NC)"
	@$(MAKE) clean
	@echo "$(GREEN)✅ Tout arrêté et nettoyé !$(NC)"

# Démarrage complet (toutes les parties)
start-all:
	@echo "$(GREEN)🚀 Démarrage complet de toutes les parties...$(NC)"
	@$(MAKE) up
	@$(MAKE) deploy-p2
	@$(MAKE) deploy-p3-full
	@echo "$(GREEN)🎉 Toutes les parties sont démarrées !$(NC)"
	@echo "$(BLUE)🌐 P1/P2: http://app1.com, http://app2.com, http://$(HOST_IP)$(NC)"
	@echo "$(BLUE)🌐 P3: ArgoCD http://localhost:8080$(NC)"
	@echo ""
	@echo "$(BLUE)⏳ Sleep 50$(NC)"
	@sleep 50
	@echo "$(YELLOW)🧪 Lancement du PF P3 (port-forward wil-playground)...$(NC)"
	@$(MAKE) test-p3

# ===============================
# Commandes spécifiques P1
# ===============================

# Démarrage P1 uniquement
start-p1:
	@echo "$(GREEN)🚀 Démarrage de la partie 1 (Cluster K3s)...$(NC)"
	@$(MAKE) up
	@echo "$(GREEN)✅ Partie 1 démarrée avec succès !$(NC)"
	@$(MAKE) test-p1

# Arrêt P1 uniquement
stop-p1:
	@echo "$(RED)🛑 Arrêt de la partie 1...$(NC)"
	@cd .. && $(VAGRANT_CMD) destroy -f || true
	@$(MAKE) clean-vbox
	@rm -f ../confs/node-token ../confs/k3s.yaml
	@rm -rf ../.vagrant
	@echo "$(GREEN)✅ Partie 1 arrêtée et nettoyée !$(NC)"

# Test P1 uniquement
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

# Déployer P2 sur ce cluster
deploy-p2:
	@echo "$(GREEN)🚀 Déploiement des applications P2 sur ce cluster K3s$(NC)"
	@if [ ! -f $(KUBECONFIG_P2) ]; then \
		echo "$(RED)❌ Cluster K3s non démarré$(NC)"; \
		echo "$(YELLOW)   Démarrez le cluster d'abord: make up$(NC)"; \
		exit 1; \
	fi
	@$(MAKE) dockerhub-secret
	@echo "$(BLUE)ℹ️  Correction de l'adresse du serveur dans kubeconfig...$(NC)"
	@sed -i 's|server: https://127.0.0.1:6443|server: https://$(HOST_IP):6443|g' $(KUBECONFIG_P2)
	@echo "$(BLUE)ℹ️  Vérification de la connectivité...$(NC)"
	@if ! nc -z $(HOST_IP) 6443 2>/dev/null; then \
		echo "$(RED)❌ Cluster non accessible$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📦 Déploiement de app1...$(NC)"
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl apply -f ../../p2/confs/app1-deployment.yaml --validate=false
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl rollout status deployment/app1-deployment --timeout=120s
	@echo "$(BLUE)📦 Déploiement de app2...$(NC)"
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl apply -f ../../p2/confs/app2-deployment.yaml --validate=false
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl rollout status deployment/app2-deployment --timeout=120s
	@echo "$(BLUE)📦 Déploiement de app3...$(NC)"
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl apply -f ../../p2/confs/app3-deployment.yaml --validate=false
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl rollout status deployment/app3-deployment --timeout=120s
	@echo "$(BLUE)🌐 Configuration de l'Ingress...$(NC)"
	@KUBECONFIG=$(KUBECONFIG_P2) kubectl apply -f ../../p2/confs/ingress.yaml --validate=false
	@echo "$(GREEN)✅ Applications P2 déployées avec succès!$(NC)"
	@echo ""
	@echo "$(BLUE)🌐 Applications accessibles via:$(NC)"
	@echo "  • http://app1.com (ajoutez '$(HOST_IP) app1.com' à /etc/hosts)"
	@echo "  • http://app2.com (ajoutez '$(HOST_IP) app2.com' à /etc/hosts)"
	@echo "  • http://$(HOST_IP) (app3 par défaut)"

# Supprimer les applications P2
clean-p2:
	@echo "$(YELLOW)🧹 Suppression des applications P2$(NC)"
	@if [ -f $(KUBECONFIG_P2) ]; then \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl delete -f ../../p2/confs/ingress.yaml --ignore-not-found=true; \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl delete -f ../../p2/confs/app1-deployment.yaml --ignore-not-found=true; \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl delete -f ../../p2/confs/app2-deployment.yaml --ignore-not-found=true; \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl delete -f ../../p2/confs/app3-deployment.yaml --ignore-not-found=true; \
		echo "$(GREEN)✅ Applications P2 supprimées$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Cluster non accessible$(NC)"; \
	fi

# Statut des applications P2
status-p2:
	@echo "$(BLUE)📊 Statut des applications P2$(NC)"
	@if [ -f $(KUBECONFIG_P2) ]; then \
		echo "$(YELLOW)=== Pods P2 ===$(NC)"; \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl get pods -l 'app in (app1,app2,app3)' -o wide 2>/dev/null || echo "$(RED)❌ Aucun pod P2$(NC)"; \
		echo ""; \
		echo "$(YELLOW)=== Services P2 ===$(NC)"; \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl get services -l 'app in (app1,app2,app3)' 2>/dev/null || echo "$(RED)❌ Aucun service P2$(NC)"; \
		echo ""; \
		echo "$(YELLOW)=== Ingress P2 ===$(NC)"; \
		KUBECONFIG=$(KUBECONFIG_P2) kubectl get ingress 2>/dev/null || echo "$(RED)❌ Aucun ingress$(NC)"; \
	else \
		echo "$(RED)❌ Cluster non accessible$(NC)"; \
	fi

# Test des applications P2
test-p2:
	@echo "$(BLUE)🧪 Test des applications P2$(NC)"
	@echo "$(YELLOW)Ajout des entrées /etc/hosts si nécessaire...$(NC)"
	@if ! grep -q "$(HOST_IP) app1.com" /etc/hosts; then \
		echo "echo '$(HOST_IP) app1.com' | sudo tee -a /etc/hosts"; \
	fi
	@if ! grep -q "$(HOST_IP) app2.com" /etc/hosts; then \
		echo "echo '$(HOST_IP) app2.com' | sudo tee -a /etc/hosts"; \
	fi
	@echo ""
	@echo "$(BLUE)Test app1:$(NC)"
	@curl -s -w "HTTP %{http_code}\n" http://app1.com -o /dev/null || echo "❌ app1 non accessible"
	@echo "$(BLUE)Test app2:$(NC)"
	@curl -s -w "HTTP %{http_code}\n" http://app2.com -o /dev/null || echo "❌ app2 non accessible"
	@echo "$(BLUE)Test app3:$(NC)"
	@curl -s -w "HTTP %{http_code}\n" http://$(HOST_IP) -o /dev/null || echo "❌ app3 non accessible"

# Installer l'environnement P3 (K3d)
install-p3:
	@echo "$(GREEN)🚀 Installation de l'environnement P3 (K3d + ArgoCD)$(NC)"
	@cd ../../p3 && chmod +x scripts/run.sh && ./scripts/run.sh install
	@echo "$(GREEN)✅ Environnement P3 installé !$(NC)"
	@echo "$(YELLOW)⚠️  Reconnectez-vous à votre session pour utiliser Docker$(NC)"

# Configurer ArgoCD
setup-p3:
	@echo "$(GREEN)🔧 Configuration d'ArgoCD...$(NC)"
	@cd ../../p3 && ./scripts/run.sh setup
	@echo "$(GREEN)✅ ArgoCD configuré !$(NC)"

# Déployer l'application wil-playground
deploy-p3:
	@echo "$(GREEN)📦 Déploiement de l'application wil-playground...$(NC)"
	@cd ../../p3 && ./scripts/run.sh deploy
	@echo "$(GREEN)✅ Application P3 déployée !$(NC)"

# Statut de P3
status-p3:
	@echo "$(BLUE)📊 Statut de la partie 3 (ArgoCD)$(NC)"
	@cd ../../p3 && ./scripts/run.sh status

# Lancer le port-forward pour ArgoCD
port-forward-p3:
	@echo "$(BLUE)🌐 Lancement du port-forward ArgoCD...$(NC)"
	@if ! kubectl get namespace argocd >/dev/null 2>&1; then \
		echo "$(YELLOW)⚠️  Namespace argocd introuvable. Lancez d'abord 'make setup-p3'.$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)ArgoCD sera accessible sur: http://localhost:8080$(NC)"
	@echo "$(YELLOW)Mot de passe admin: $(NC)"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d && echo
	@echo ""
	@kubectl port-forward -n argocd pod/$$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}') 8080:8080

# Test de l'application P3
test-p3:
	@echo "$(BLUE)🧪 Test de l'application P3$(NC)"
	@cd ../../p3/scripts && chmod +x test-app.sh && ./test-app.sh test

# Nettoyage P3
clean-p3:
	@echo "$(YELLOW)🧹 Nettoyage de P3 (suppression du cluster K3d)$(NC)"
	@cd ../../p3 && ./scripts/run.sh clean
	@echo "$(GREEN)✅ P3 nettoyé !$(NC)"

# Nettoyage d'éventuelles VM VirtualBox résiduelles
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

dockerhub-secret:
	@if [ -z "$(DOCKERHUB_USERNAME)" ] || [ -z "$(DOCKERHUB_TOKEN)" ]; then \
		echo "$(YELLOW)⚠️  Variables DOCKERHUB_USERNAME/DOCKERHUB_TOKEN absentes. Ajoutez-les dans $(ENV_FILE).$(NC)"; \
		exit 1; \
	fi
	@for ns in default dev; do \
		if KUBECONFIG=$(KUBECONFIG_P2) kubectl get namespace $$ns >/dev/null 2>&1; then \
			if ! KUBECONFIG=$(KUBECONFIG_P2) kubectl get secret dockerhub-cred -n $$ns >/dev/null 2>&1; then \
				echo "$(BLUE)🔐 Création du secret dockerhub-cred dans le namespace $$ns...$(NC)"; \
				KUBECONFIG=$(KUBECONFIG_P2) kubectl create secret docker-registry dockerhub-cred -n $$ns \
					--docker-server=https://index.docker.io/v1/ \
					--docker-username="$(DOCKERHUB_USERNAME)" \
					--docker-password="$(DOCKERHUB_TOKEN)" \
					--docker-email="$(DOCKERHUB_EMAIL)" >/dev/null; \
			else \
				echo "$(GREEN)✅ Secret dockerhub-cred déjà présent dans $$ns$(NC)"; \
			fi; \
			echo "$(BLUE)🔧 Mise à jour du serviceaccount default dans $$ns...$(NC)"; \
			KUBECONFIG=$(KUBECONFIG_P2) kubectl patch serviceaccount default -n $$ns --type merge \
				-p '{"imagePullSecrets":[{"name":"dockerhub-cred"}]}' >/dev/null 2>&1 || true; \
		else \
			echo "$(YELLOW)⚠️  Namespace $$ns indisponible, secret non créé$(NC)"; \
		fi; \
	done

# Déploiement P3 complet (install + setup + deploy)
deploy-p3-full: install-p3 setup-p3 deploy-p3
	@echo "$(GREEN)🎉 P3 déployé complètement !$(NC)"
	@echo "$(BLUE)🌐 ArgoCD: http://localhost:8080 | App: make test-p3$(NC)"

# Aide
help:
	@echo "$(BLUE)📖 Inception of Things - Guide d'utilisation$(NC)"
	@echo ""
	@echo "$(GREEN)🏗️  Commandes P1 (Cluster K3s) :$(NC)"
	@echo "  $(YELLOW)make install$(NC)      - Installer les dépendances"
	@echo "  $(YELLOW)make start-p1$(NC)     - Démarrer P1 uniquement"
	@echo "  $(YELLOW)make stop-p1$(NC)      - Arrêter P1 uniquement"
	@echo "  $(YELLOW)make test-p1$(NC)      - Tester P1 uniquement"
	@echo "  $(YELLOW)make up$(NC)           - Démarrer le cluster K3s"
	@echo "  $(YELLOW)make clean$(NC)        - Nettoyer tout (P1+P2+P3)"
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
	@echo "$(GREEN)🚀 Commandes principales :$(NC)"
	@echo "  $(YELLOW)make start-all$(NC)   - Démarrer toutes les parties (P1+P2+P3) + test P3"
	@echo "  $(YELLOW)make stop-all$(NC)    - Arrêter et nettoyer tout"
	@echo "  $(YELLOW)make deploy-p3-full$(NC) - P3 complet uniquement"
	@echo ""
	@echo "$(GREEN)ℹ️  Commandes d'information :$(NC)"
	@echo "  $(YELLOW)make status$(NC)       - Statut des VMs P1"
	@echo "  $(YELLOW)make cluster-info$(NC) - Informations cluster K3s"
	@echo "  $(YELLOW)make ssh-master$(NC)   - SSH vers le master"
	@echo "  $(YELLOW)make ssh-worker$(NC)   - SSH vers le worker"
	@echo ""
	@echo "$(BLUE)🎯 Workflows recommandés :$(NC)"
	@echo ""
	@echo "$(YELLOW)🌟 P1 uniquement :$(NC)"
	@echo "  1. $(YELLOW)make install$(NC)     # Installation initiale"
	@echo "  2. $(YELLOW)make start-p1$(NC)    # Démarrer et tester P1"
	@echo "  3. $(YELLOW)make stop-p1$(NC)     # Arrêter P1"
	@echo ""
	@echo "$(YELLOW)🌟 Démarrage rapide complet :$(NC)"
	@echo "  1. $(YELLOW)make install$(NC)     # Installation initiale"
	@echo "  2. $(YELLOW)make start-all$(NC)   # Tout démarrer + test P3"
	@echo "  3. $(YELLOW)make test-p2$(NC)     # Tester P2"
	@echo "     $(BLUE)→ P3 déjà testé automatiquement$(NC)"
	@echo ""
	@echo "$(YELLOW)🛑 Nettoyage :$(NC)"
	@echo "  • $(YELLOW)make stop-all$(NC)     # Tout arrêter et nettoyer"
	@echo "  • $(YELLOW)make stop-p1$(NC)      # Arrêter P1 uniquement"
	@echo "  • $(YELLOW)make clean-p2$(NC)     # Nettoyer P2 uniquement"
	@echo "  • $(YELLOW)make clean-p3$(NC)     # Nettoyer P3 uniquement"
	@echo ""
	@echo "$(GREEN)🌐 Applications déployées :$(NC)"
	@echo "  • P1: Cluster K3s avec 2 nœuds"
	@echo "  • P2: http://app1.com, http://app2.com, http://$(HOST_IP)"
	@echo "  • P3: ArgoCD http://localhost:8080, wil-playground http://localhost:8889"
