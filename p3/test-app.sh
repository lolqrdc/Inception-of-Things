#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

show_help() {
    echo -e "${GREEN}🧪 Test et gestion des versions - wil-playground${NC}"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  status      - Afficher le statut de l'application"
    echo "  test        - Tester l'application (avec port-forward)"
    echo "  version     - Afficher la version actuelle"
    echo ""
    echo -e "${YELLOW}⚠️  Changement de version:${NC}"
    echo "Les versions sont maintenant gérées dans le repository externe:"
    echo "https://github.com/eliamd/iot-dep.git"
    echo ""
}

show_status() {
    echo -e "${BLUE}Statut de l'application wil-playground${NC}"
    echo "============================================"

    kubectl get applications -n argocd | grep wil-playground || echo "Application non déployée"
    echo ""
    kubectl get pods -n dev 2>/dev/null || echo "Namespace dev vide"
    echo ""
    kubectl get deployment wil-playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "Déploiement non trouvé"
}

test_app() {
    echo -e "${BLUE}Test de l'application wil-playground${NC}"

    if ! kubectl get deployment wil-playground -n dev >/dev/null 2>&1; then
        echo -e "${RED}❌ Application non déployée${NC}"
        exit 1
    fi

    echo -e "${BLUE}Lancement du port-forward sur le port 8889...${NC}"
    kubectl port-forward -n dev svc/wil-playground-service 8889:8888 > /dev/null 2>&1 &
    PORT_FORWARD_PID=$!

    sleep 5
    echo -e "${BLUE}Test sur http://localhost:8889${NC}"
    
    if curl -s http://localhost:8889/ 2>/dev/null; then
        echo ""
        echo -e "${GREEN}✅ Application accessible !${NC}"
    else
        echo ""
        echo -e "${RED}❌ Non accessible${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Port-forward actif (PID: $PORT_FORWARD_PID)${NC}"
    echo -e "${BLUE}Accédez à: http://localhost:8889${NC}"
    echo "Pour arrêter: kill $PORT_FORWARD_PID"
}

show_version() {
    VERSION=$(kubectl get deployment wil-playground -n dev -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | sed 's/.*://')
    if [ -n "$VERSION" ]; then
        echo -e "${GREEN}Version: $VERSION${NC}"
    else
        echo -e "${RED}❌ Application non déployée${NC}"
    fi
}

change_version() {
    echo -e "${RED}❌ Changement de version non disponible localement${NC}"
    echo ""
    echo -e "${YELLOW}ℹ️  Les manifests sont maintenant dans le repository externe:${NC}"
    echo "https://github.com/eliamd/iot-dep.git"
    echo ""
    echo -e "${YELLOW}Pour changer la version:${NC}"
    echo "1. Cloner le repository: git clone https://github.com/eliamd/iot-dep.git"
    echo "2. Modifier le deployment.yaml"
    echo "3. git add, commit et push"
    echo "4. ArgoCD synchronisera automatiquement"
}

case "${1:-help}" in
    status) show_status ;;
    test) test_app ;;
    version) show_version ;;
    *) show_help ;;
esac
