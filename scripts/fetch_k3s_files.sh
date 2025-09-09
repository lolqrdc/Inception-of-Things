#!/bin/bash

# Script pour récupérer automatiquement les fichiers K3s depuis le master node
# Usage: ./scripts/fetch_k3s_files.sh

echo "🔄 Récupération automatique des fichiers K3s..."

# Créer le dossier confs s'il n'existe pas
mkdir -p ./confs

# Attendre que le master node soit prêt
echo "⏳ Attente que le master node soit prêt..."
while ! vagrant ssh edetohS -c "test -f /tmp/node-token-clean" 2>/dev/null; do
    sleep 2
done

# Récupérer le token
echo "📥 Récupération du token..."
vagrant ssh edetohS -c "cat /tmp/node-token-clean" > ./confs/node-token 2>/dev/null

# Récupérer la configuration K3s
echo "📥 Récupération de la configuration K3s..."
vagrant ssh edetohS -c "cat /tmp/k3s.yaml" > ./confs/k3s.yaml 2>/dev/null

# Vérifier que les fichiers ont été récupérés
if [ -s ./confs/node-token ] && [ -s ./confs/k3s.yaml ]; then
    echo "✅ Fichiers K3s récupérés avec succès !"
    echo "📁 Token: $(wc -c < ./confs/node-token) bytes"
    echo "📁 Config: $(wc -c < ./confs/k3s.yaml) bytes"
else
    echo "❌ Erreur lors de la récupération des fichiers"
    exit 1
fi
