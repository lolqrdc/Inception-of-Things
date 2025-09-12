#!/bin/bash
set -e

echo "=== Installation Argo CD ==="
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Création namespace dev ==="
kubectl create namespace dev

echo "=== Attente du démarrage d'Argo CD ==="
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "=== Configuration port-forward ==="
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "=== Récupération mot de passe admin ==="
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Admin password: $ARGOCD_PASSWORD"

echo "=== Configuration port-forward pour interface web ==="
echo "Lancement du port-forward en arrière-plan..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
PORT_FORWARD_PID=$!
echo "Port-forward PID: $PORT_FORWARD_PID"

# Attendre que le port-forward soit actif
sleep 5

echo ""
echo "============================================"
echo "🎉 ArgoCD installé et configuré avec succès!"
echo "============================================"
echo ""
echo "📝 Informations de connexion:"
echo "   URL: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "⚠️  Acceptez le certificat auto-signé dans votre navigateur"
echo ""
echo "🔧 Commandes utiles:"
echo "   kubectl get pods -n argocd"
echo "   kubectl get svc -n argocd"
echo ""
echo "🛑 Pour arrêter le port-forward:"
echo "   kill $PORT_FORWARD_PID"
echo "   ou: pkill -f 'kubectl port-forward svc/argocd-server'"
