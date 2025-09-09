#!/bin/bash
set -e

echo "Installation du worker K3s sur Alpine Linux..."

# Mise à jour du système Alpine
apk update
apk add --no-cache netcat-openbsd curl nmap

#############################################
# Découvrir automatiquement l'IP du serveur K3s
echo "Découverte de l'IP du serveur K3s..."

# Le serveur a le hostname 'edetohs', essayons de le résoudre
SERVER_IP=""

# Méthode 1: Résolution DNS via /etc/hosts
if getent hosts edetohs >/dev/null 2>&1; then
    SERVER_IP=$(getent hosts edetohs | awk '{print $1}')
    echo "IP du serveur trouvée via DNS: $SERVER_IP"
fi

# Méthode 2: Scanner le réseau privé pour trouver le serveur K3s
if [ -z "$SERVER_IP" ]; then
    echo "Recherche du serveur K3s sur le réseau..."
    # Récupérer notre propre réseau
    NETWORK=$(ip route | grep eth1 | grep -E '192\.168\.|172\.|10\.' | head -1 | awk '{print $1}')
    if [ -n "$NETWORK" ]; then
        echo "Scan du réseau: $NETWORK"
        # Scanner le port 6443 (API Kubernetes) sur le réseau
        for ip in $(nmap -sn $NETWORK 2>/dev/null | grep -oP '192\.168\.\d+\.\d+|172\.\d+\.\d+\.\d+|10\.\d+\.\d+\.\d+'); do
            if nc -z $ip 6443 2>/dev/null; then
                SERVER_IP=$ip
                echo "Serveur K3s trouvé à l'IP: $SERVER_IP"
                break
            fi
        done
    fi
fi

# Méthode 3: IP par défaut fallback (si les autres méthodes échouent)
if [ -z "$SERVER_IP" ]; then
    echo "Utilisation de la résolution manuelle..."
    # Essayer les IPs communes du réseau Vagrant
    for ip in $(ip route | grep eth1 | head -1 | awk '{print $1}' | sed 's/\.[0-9]*\/.*/.1/'); do
        for i in $(seq 2 20); do
            test_ip=$(echo $ip | sed "s/\.1$/\.$i/")
            if nc -z $test_ip 6443 2>/dev/null; then
                SERVER_IP=$test_ip
                echo "Serveur K3s trouvé par scan: $SERVER_IP"
                break 2
            fi
        done
    done
fi

if [ -z "$SERVER_IP" ]; then
    echo "ERREUR: Impossible de découvrir l'IP du serveur K3s"
    exit 1
fi

echo "IP du serveur K3s confirmée: $SERVER_IP"
# Attendre que le serveur soit accessible via SSH
echo "Vérification de la connectivité SSH vers le serveur K3s..."
TIMEOUT=300
COUNTER=0

while ! nc -z $SERVER_IP 22 2>/dev/null && [ $COUNTER -lt $TIMEOUT ]; do
    echo "Attente de la connectivité SSH vers le serveur... ($COUNTER/$TIMEOUT)"
    sleep 5
    COUNTER=$((COUNTER + 5))
done

if [ $COUNTER -ge $TIMEOUT ]; then
    echo "ERREUR: Impossible de se connecter au serveur K3s via SSH"
    exit 1
fi

echo "Serveur K3s accessible via SSH !"

# Récupérer le token via SSH
echo "Récupération du token du serveur..."
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

# Vérifier la connectivité vers le serveur K3s API
echo "Vérification de la connectivité vers l'API du serveur K3s..."
until curl -sk https://$SERVER_IP:6443/healthz >/dev/null; do
    echo "API du serveur K3s non accessible, nouvelle tentative..."
    sleep 5
done
echo "API du serveur K3s accessible !"

# Purger toute ancienne configuration/état avant de (ré)joindre
echo "Nettoyage de l'état k3s-agent avant jonction..."
rc-service k3s-agent stop || true
k3s-agent-uninstall.sh || true
rm -rf /etc/rancher/k3s /var/lib/rancher/k3s /var/lib/kubelet || true

# Installation de K3s en mode agent/worker avec l'IP découverte
echo "Connexion au serveur K3s à l'adresse: https://$SERVER_IP:6443"
curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN="$TOKEN" sh -s -

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
