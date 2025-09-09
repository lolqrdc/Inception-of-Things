#!/bin/bash
set -e

echo "Installation du serveur K3s sur Alpine Linux..."

# Mise à jour du système Alpine
apk update

# Installation de K3s en mode serveur
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -

# Attendre que K3s démarre complètement et que le fichier kubeconfig soit créé
echo "Attente du démarrage de K3s..."
KUBE_CONFIG="/etc/rancher/k3s/k3s.yaml"
TIMEOUT=120  # Timeout de 2 minutes
COUNT=0

while [ ! -e ${KUBE_CONFIG} ] && [ $COUNT -lt $TIMEOUT ]
do
    echo "Attente de la création du fichier kubeconfig... ($COUNT/$TIMEOUT)"
    sleep 2
    COUNT=$((COUNT + 2))
done

if [ ! -e ${KUBE_CONFIG} ]; then
    echo "ERREUR: Le fichier kubeconfig n'a pas été créé dans les temps impartis"
    echo "Vérification du statut de K3s:"
    rc-status | grep k3s || true
    exit 1
fi

# Rendre le fichier kubeconfig lisible (déjà défini par K3S_KUBECONFIG_MODE mais on s'assure)
chmod 644 ${KUBE_CONFIG}
echo "Fichier kubeconfig créé et permissions définies"

# Attendre que le token soit généré
echo "Attente de la génération du token..."
NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"
TIMEOUT=60  # Timeout de 1 minute pour le token
COUNT=0

while [ ! -e ${NODE_TOKEN} ] && [ $COUNT -lt $TIMEOUT ]
do
    echo "Attente du token... ($COUNT/$TIMEOUT)"
    sleep 2
    COUNT=$((COUNT + 2))
done

if [ ! -e ${NODE_TOKEN} ]; then
    echo "ERREUR: Le token n'a pas été généré dans les temps impartis"
    exit 1
fi

# Le token est automatiquement généré et stocké dans le fichier par K3s
echo "Token généré automatiquement par K3s et stocké dans $NODE_TOKEN"
cat $NODE_TOKEN

# Vérifier que K3s fonctionne
echo "Vérification que K3s fonctionne..."
sleep 5
if ! kubectl get nodes 2>/dev/null; then
    echo "ATTENTION: kubectl get nodes a échoué, mais on continue..."
fi

# Le fichier kubeconfig est créé automatiquement par K3s
echo "Configuration Kubernetes créée dans /etc/rancher/k3s/k3s.yaml"

# Configurer kubectl pour l'utilisateur vagrant
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Alias kubectl
echo "alias k='kubectl'" >> /home/vagrant/.bashrc

echo "Installation du serveur K3s terminée!"
