#!/bin/bash

# Script pour récupérer automatiquement les fichiers K3s depuis le master node
# Usage: ./scripts/fetch_k3s_files.sh

echo "🔄 Récupération automatique des fichiers K3s..."

# Créer le dossier confs s'il n'existe pas
mkdir -p ./confs

# Attendre que le master node soit prêt et que les fichiers soient créés
echo "⏳ Attente que le master node soit prêt..."
TIMEOUT=90
ELAPSED=0
while ! vagrant ssh edetohS -c "test -f /tmp/node-token-clean && test -f /tmp/k3s.yaml && test -s /tmp/node-token-clean" 2>/dev/null; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "❌ Timeout : le master node n'est pas prêt après ${TIMEOUT}s"
        echo "🔍 Vérification de l'état du master..."
        vagrant ssh edetohS -c "ls -la /tmp/node-token* /tmp/k3s.yaml 2>/dev/null || echo 'Fichiers non trouvés'" 2>/dev/null || echo "Impossible de se connecter au master"
        exit 1
    fi
    if [ $((ELAPSED % 10)) -eq 0 ]; then
        echo "Attente du master... (${ELAPSED}/${TIMEOUT}s)"
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

echo "✅ Master node prêt !"

# Récupérer le token
echo "📥 Récupération du token..."
if vagrant ssh edetohS -c "cat /tmp/node-token-clean" > ./confs/node-token 2>/dev/null; then
    if [ -s ./confs/node-token ]; then
        echo "✅ Token récupéré ($(wc -c < ./confs/node-token) bytes)"
    else
        echo "❌ Token vide"
        exit 1
    fi
else
    echo "❌ Erreur lors de la récupération du token"
    exit 1
fi

# Récupérer la configuration K3s
echo "📥 Récupération de la configuration K3s..."
if vagrant ssh edetohS -c "cat /tmp/k3s.yaml" > ./confs/k3s.yaml 2>/dev/null; then
    if [ -s ./confs/k3s.yaml ]; then
        echo "✅ Configuration récupérée ($(wc -c < ./confs/k3s.yaml) bytes)"
    else
        echo "❌ Configuration vide"
        exit 1
    fi
else
    echo "❌ Erreur lors de la récupération de la configuration"
    exit 1
fi

# Affichage final
echo "✅ Fichiers K3s récupérés avec succès !"
echo "🔗 Token preview: $(head -c 20 ./confs/node-token)..."
echo "📁 Fichiers disponibles dans ./confs/"
