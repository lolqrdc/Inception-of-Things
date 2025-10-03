#!/bin/bash
set -e

echo "=== Vérification Docker ==="
if command -v docker >/dev/null 2>&1; then
    echo "Docker déjà installé : $(docker --version)"
else
    echo "Installation de Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm -f get-docker.sh
    echo "⚠️  Redémarrez votre session pour utiliser Docker"
fi

echo "=== Vérification K3d ==="
if command -v k3d >/dev/null 2>&1; then
    echo "K3d déjà installé : $(k3d version | head -1)"
else
    echo "Installation de K3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo "=== Vérification kubectl ==="
if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl déjà installé : $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    # S'assurer que kubectl est disponible localement
    if [ ! -f ../kubectl ]; then
        echo "Copie de kubectl pour usage local..."
        cp $(which kubectl) ../kubectl
        chmod +x ../kubectl
    fi
else
    echo "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    cp kubectl ../kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
fi

echo "=== Nettoyage des clusters existants ==="
k3d cluster delete iot-cluster 2>/dev/null || echo "Aucun cluster iot-cluster à supprimer"

echo "=== Création du cluster K3d ==="
k3d cluster create iot-cluster --port "8888:8888@loadbalancer"

echo "Installation terminée. Déconnectez-vous et reconnectez-vous pour utiliser Docker."
