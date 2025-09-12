#!/bin/bash
set -e

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction d'aide
show_help() {
    echo -e "${GREEN}🚀 Inception of Things - Partie 3 (ArgoCD)${NC}"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  install     - Installer K3d, Docker, kubectl et créer le cluster"
    echo "  setup       - Installer et configurer ArgoCD"
    echo "  deploy      - Déployer l'application wil-playground"
    echo "  status      - Afficher le statut du cluster et de l'application"
    echo "  clean       - Nettoyer complètement (supprimer le cluster)"
    echo "  help        - Afficher cette aide"
    echo ""
}

# Installation
install_environment() {
    echo -e "${BLUE}Installation de l'environnement K3d...${NC}"
    chmod +x scripts/install.sh
    ./scripts/install.sh
    echo -e "${GREEN}✅ Environnement installé avec succès!${NC}"
    echo -e "${YELLOW}⚠️  Reconnectez-vous à votre session pour utiliser Docker${NC}"
}

# Configuration ArgoCD
setup_argocd() {
    echo -e "${BLUE}Configuration d'ArgoCD...${NC}"

    if ! k3d cluster list | grep -q iot-cluster; then
        echo -e "${RED}❌ Cluster iot-cluster non trouvé. Lancez d'abord: $0 install${NC}"
        exit 1
    fi

    chmod +x scripts/setup.sh
    ./scripts/setup.sh
    echo -e "${GREEN}✅ ArgoCD configuré avec succès!${NC}"
}

# Déploiement
deploy_app() {
    echo -e "${BLUE}Déploiement de l'application wil-playground...${NC}"
    chmod +x scripts/deploy-apps.sh
    ./scripts/deploy-apps.sh
    echo -e "${GREEN}✅ Application déployée avec succès!${NC}"
}

# Nettoyage
clean_all() {
    echo -e "${YELLOW}Suppression du cluster K3d...${NC}"
    k3d cluster delete iot-cluster 2>/dev/null || true
    pkill -f 'kubectl port-forward svc/argocd-server' 2>/dev/null || true
    echo -e "${GREEN}✅ Nettoyage terminé!${NC}"
}

# Statut
show_status() {
    echo -e "${BLUE}📊 Statut du cluster et de l'application${NC}"
    echo "============================================="

    if k3d cluster list | grep -q iot-cluster; then
        echo -e "${GREEN}✅ Cluster iot-cluster actif${NC}"

        if kubectl get namespace argocd >/dev/null 2>&1; then
            echo -e "${GREEN}✅ ArgoCD installé${NC}"

            echo -e "\n${YELLOW}Application ArgoCD:${NC}"
            kubectl get applications -n argocd 2>/dev/null || echo "Aucune application"

            echo -e "\n${YELLOW}Pods dans dev:${NC}"
            kubectl get pods -n dev 2>/dev/null || echo "Namespace dev vide"

            # Mot de passe ArgoCD
            echo -e "\n${YELLOW}Mot de passe ArgoCD admin:${NC}"
            kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d && echo

        else
            echo -e "${RED}❌ ArgoCD non installé${NC}"
        fi

    else
        echo -e "${RED}❌ Cluster iot-cluster non trouvé${NC}"
    fi

    echo ""
    echo -e "${GREEN}🌐 ArgoCD:${NC} https://localhost:8080 (admin)"
    echo -e "${GREEN}🧪 Test app:${NC} ./test-app.sh test"
}

# Script principal
case "${1:-help}" in
    install)
        install_environment
        ;;
    setup)
        setup_argocd
        ;;
    deploy)
        deploy_app
        ;;
    status)
        show_status
        ;;
    clean)
        clean_all
        ;;
    help|*)
        show_help
        ;;
esac
