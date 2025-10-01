#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
fi

echo "=== Déploiement des applications ArgoCD ==="

# Vérifier qu'ArgoCD est installé
if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo "❌ ArgoCD n'est pas installé. Lancez d'abord ./setup.sh"
    exit 1
fi

# Vérifier qu'ArgoCD est prêt
echo "⏳ Vérification qu'ArgoCD est prêt..."
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
if kubectl get deployment argocd-application-controller -n argocd >/dev/null 2>&1; then
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd
else
    echo "=== Attente du StatefulSet argocd-application-controller ==="
    if ! kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=600s; then
        echo "⚠️  Timeout en attendant argocd-application-controller. État actuel :"
        kubectl get statefulset/argocd-application-controller -n argocd || true
        kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-application-controller || true
        exit 1
    fi
fi

ensure_dockerhub_secret() {
    if [ -z "${DOCKERHUB_USERNAME:-}" ] || [ -z "${DOCKERHUB_TOKEN:-}" ]; then
        echo "⚠️  Variables DOCKERHUB_USERNAME/DOCKERHUB_TOKEN non définies. Pulls Docker Hub non authentifiés.${NC:-}"
        return
    fi

    local ns="dev"
    if ! kubectl get namespace "$ns" >/dev/null 2>&1; then
        echo "⚠️  Namespace $ns absent, impossible de créer le secret Docker Hub."
        return
    fi

    if ! kubectl get secret dockerhub-cred -n "$ns" >/dev/null 2>&1; then
        echo "🔐 Création du secret dockerhub-cred dans le namespace $ns..."
        kubectl create secret docker-registry dockerhub-cred -n "$ns" \
            --docker-server=https://index.docker.io/v1/ \
            --docker-username="${DOCKERHUB_USERNAME}" \
            --docker-password="${DOCKERHUB_TOKEN}" \
            --docker-email="${DOCKERHUB_EMAIL:-no-reply@example.com}" >/dev/null
    else
        echo "✅ Secret dockerhub-cred déjà présent dans $ns"
    fi

    kubectl patch serviceaccount default -n "$ns" --type merge \
        -p '{"imagePullSecrets":[{"name":"dockerhub-cred"}]}' >/dev/null 2>&1 || true
}

ensure_dockerhub_secret

echo "📦 Déploiement de l'application wil-playground..."
kubectl apply -f confs/wil-application.yaml

echo "⏳ Attente de la création de l'application..."
for attempt in {1..20}; do
    if kubectl get applications.argoproj.io wil-playground -n argocd >/dev/null 2>&1; then
        break
    fi
    echo "   Application en cours de création... (tentative $attempt/20)"
    sleep 6
done

echo "⏳ Synchronisation de l'application via ArgoCD..."
synced=false
for attempt in {1..40}; do
    sync_status="$(kubectl get applications.argoproj.io wil-playground -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "")"
    health_status="$(kubectl get applications.argoproj.io wil-playground -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "")"
    if [[ "$sync_status" == "Synced" && "$health_status" == "Healthy" ]]; then
        synced=true
        echo "   ✅ Application synchronisée et saine (tentative $attempt)"
        break
    fi
    echo "   Sync=${sync_status:-Inconnu} Health=${health_status:-Inconnue} (tentative $attempt/40)"
    sleep 6
done

if [[ "$synced" != true ]]; then
    echo "❌ Impossible d'obtenir un état sain pour l'application." >&2
    kubectl describe applications.argoproj.io wil-playground -n argocd || true
    exit 1
fi

echo "📊 Statut de l'application ArgoCD:"
kubectl get applications.argoproj.io wil-playground -n argocd

echo "📦 Vérification du déploiement dans le namespace dev..."
deployment_found=false
for attempt in {1..30}; do
    if kubectl get deployment wil-playground -n dev >/dev/null 2>&1; then
        deployment_found=true
        break
    fi
    echo "   Déploiement wil-playground non encore créé (tentative $attempt/30)"
    sleep 6
done

if [[ "$deployment_found" != true ]]; then
    echo "❌ Le déploiement wil-playground n'a pas été créé dans le namespace dev." >&2
    kubectl get all -n dev || true
    exit 1
fi

kubectl wait --for=condition=available --timeout=180s deployment/wil-playground -n dev
kubectl get pods -n dev

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
