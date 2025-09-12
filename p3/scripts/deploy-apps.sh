#!/bin/bash
set -e

echo "=== Déploiement des applications ArgoCD ==="

# Vérifier qu'ArgoCD est installé
if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo "❌ ArgoCD n'est pas installé. Lancez d'abord ./setup.sh"
    exit 1
fi

# Vérifier qu'ArgoCD est prêt
echo "⏳ Vérification qu'ArgoCD est prêt..."
kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n argocd

echo "📦 Déploiement de l'application wil-playground..."
kubectl apply -f argocd-configs/wil-application.yaml

echo "⏳ Attente de la synchronisation de l'application..."
sleep 15

echo "� Statut de l'application ArgoCD:"
kubectl get applications -n argocd

echo ""
echo "📊 Vérification du déploiement dans le namespace dev:"
kubectl get pods -n dev 2>/dev/null || echo "En attente de création des pods..."

echo ""
echo "============================================"
echo "🎉 Application wil-playground déployée!"
echo "============================================"
echo ""
echo "🌐 Accédez à ArgoCD: https://localhost:8080"
echo ""
echo "📱 Application déployée:"
echo "   • wil-playground (wil42/playground:v1, namespace: dev, port: 8888)"
echo ""
echo "🔍 Vérifier le déploiement:"
echo "   kubectl get pods -n dev"
echo "   kubectl get svc -n dev"
echo "   kubectl port-forward svc/wil-playground-service -n dev 8888:8888"
echo ""
echo "🧪 Tester l'application:"
echo "   curl http://localhost:8888/"
echo ""
