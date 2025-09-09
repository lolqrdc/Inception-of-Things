#!/bin/bash
set -e

echo "Installation du worker K3s sur Alpine Linux..."

# Mise à jour du système Alpine
apk update
apk add --no-cache netcat-openbsd curl

#############################################
# Récupérer le token du serveur via SSH
echo "Récupération du token du serveur via SSH..."

# Configuration SSH pour la connexion automatique
export VAGRANT_DISABLE_STRICT_HOST_KEY_CHECKING=1

# IP du serveur K3s
SERVER_IP="192.168.56.110"
TIMEOUT=300
COUNTER=0

# Attendre que le serveur soit accessible via SSH
echo "Vérification de la connectivité vers le serveur K3s..."
while ! nc -z $SERVER_IP 22 2>/dev/null && [ $COUNTER -lt $TIMEOUT ]; do
    echo "Attente de la connectivité SSH vers le serveur... ($COUNTER/$TIMEOUT)"
    sleep 5
    COUNTER=$((COUNTER + 5))
done

if [ $COUNTER -ge $TIMEOUT ]; then
    echo "ERREUR: Impossible de se connecter au serveur K3s"
    exit 1
fi

echo "Serveur K3s accessible !"

# Récupérer le token via SSH
echo "Récupération du token..."
TOKEN_COUNTER=0
while [ $TOKEN_COUNTER -lt $TIMEOUT ]; do
    TOKEN=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null vagrant@$SERVER_IP "sudo cat /var/lib/rancher/k3s/server/node-token" 2>/dev/null)

    if [ -n "$TOKEN" ] && [ "$TOKEN" != "cat: /var/lib/rancher/k3s/server/node-token: No such file or directory" ]; then
        echo "Token récupéré avec succès !"
        break
    fi

    echo "Attente de la génération du token sur le serveur... ($TOKEN_COUNTER/$TIMEOUT)"
    sleep 5
    TOKEN_COUNTER=$((TOKEN_COUNTER + 5))
done

if [ -z "$TOKEN" ]; then
    echo "ERREUR: Impossible de récupérer le token du serveur"
    exit 1
fi

# Attendre un peu plus pour s'assurer que le serveur est complètement prêt
echo "Token trouvé, attente de la stabilisation du serveur..."
sleep 8

# Vérifier la connectivité vers le serveur
echo "Vérification de la connectivité vers le serveur K3s..."
until curl -sk https://192.168.56.110:6443/healthz >/dev/null; do
    echo "Serveur K3s non accessible, nouvelle tentative..."
    sleep 5
done
echo "Serveur K3s accessible !"

# Purger toute ancienne configuration/état avant de (ré)joindre
echo "Nettoyage de l'état k3s-agent avant jonction..."
rc-service k3s-agent stop || true
k3s-agent-uninstall.sh || true
rm -rf /etc/rancher/k3s /var/lib/rancher/k3s /var/lib/kubelet || true

# Token récupéré, connexion au serveur...
echo "Token récupéré, connexion au serveur..."

# Installation de K3s en mode agent/worker
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="$TOKEN" sh -s -

# Attendre que l'agent démarre et s'enregistre
echo "Attente du démarrage/enregistrement de l'agent K3s..."
for i in $(seq 1 30); do
  if rc-service k3s-agent status 2>/dev/null | grep -q started; then
    echo "k3s-agent démarré (tentative $i)"
    break
  fi
  sleep 2
done

# Alias kubectl pour l'utilisateur vagrant
echo "alias k='kubectl'" >> /home/vagrant/.bashrc

echo "Installation du worker K3s terminée!"
