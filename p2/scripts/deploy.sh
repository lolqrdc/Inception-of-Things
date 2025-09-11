#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🚀 Deploying P2 apps on K3s cluster"

# Check prerequisites
P1_DIR="../p1"
KUBECONFIG_FILE="$P1_DIR/confs/k3s.yaml"
CONFS_DIR="./confs"

# Vérifications préalables
log_info "Vérification des prérequis..."

# Vérifier que P1 existe et est démarré
if [ ! -d "$P1_DIR" ]; then
    log_error "Dossier P1 non trouvé: $P1_DIR"
    exit 1
fi

if [ ! -f "$KUBECONFIG_FILE" ]; then
    log_error "Fichier kubeconfig non trouvé: $KUBECONFIG_FILE"
    log_error "Démarrez d'abord P1 avec: cd $P1_DIR && make"
    exit 1
fi

# Vérifier la connectivité avec le cluster
log_info "Vérification de la connectivité avec le cluster K3s..."
if ! nc -z 192.168.56.110 6443 2>/dev/null; then
    log_error "Cluster K3s non accessible sur 192.168.56.110:6443"
    log_error "Assurez-vous que P1 est démarré"
    exit 1
fi

# Vérifier que kubectl fonctionne
log_info "Test de kubectl..."
export KUBECONFIG="$KUBECONFIG_FILE"
kubectl get nodes >/dev/null || { echo -e "${RED}❌ Cannot connect to cluster${NC}"; exit 1; }

# Deploy apps
echo "📦 Deploying applications..."
kubectl apply -f ./confs/
kubectl rollout status deployment --all --timeout=120s

# Show results
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo "Apps available at:"
echo "• http://app1.com (add '192.168.56.110 app1.com' to /etc/hosts)"
echo "• http://app2.com (add '192.168.56.110 app2.com' to /etc/hosts)" 
echo "• http://192.168.56.110 (app3 default)"
