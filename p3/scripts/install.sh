#!/bin/bash
set -e

echo "=== Installation Docker ==="
curl -fsSL https://get.docker.com -o scripts/get-docker.sh
sudo sh scripts/get-docker.sh
sudo usermod -aG docker $USER

echo "=== Installation K3d ==="
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "=== Installation kubectl ==="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "=== Création du cluster K3d ==="
k3d cluster create iot-cluster --port "8888:8888@loadbalancer"

echo "Installation terminée. Déconnectez-vous et reconnectez-vous pour utiliser Docker."
