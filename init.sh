#!/bin/bash

# Script d'initialisation pour le projet p1-vagrant
# À exécuter sur une nouvelle machine avant de lancer Vagrant

echo "🔧 Initialisation du projet p1-vagrant..."

# Vérifier si les clés SSH existent
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "📝 Génération des clés SSH..."
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
    echo "✅ Clés SSH générées"
else
    echo "✅ Clés SSH déjà présentes"
fi

# Installer VirtualBox si nécessaire
if ! command -v virtualbox &> /dev/null; then
    echo "📦 Installation de VirtualBox..."
    sudo apt update
    sudo apt install -y virtualbox virtualbox-ext-pack
    echo "✅ VirtualBox installé"
else
    echo "✅ VirtualBox déjà installé"
fi

# Installer Vagrant si nécessaire
if ! command -v vagrant &> /dev/null; then
    echo "📦 Installation de Vagrant..."
    sudo apt install -y vagrant
    echo "✅ Vagrant installé"
else
    echo "✅ Vagrant déjà installé"
fi

echo "🎉 Initialisation terminée !"
echo "Vous pouvez maintenant lancer : vagrant up"
