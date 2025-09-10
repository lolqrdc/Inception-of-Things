#!/bin/bash

# Script de diagnostic pour p1-vagrant
# Ce script détecte et résout automatiquement les problèmes courants

echo "🔍 Diagnostic du projet p1-vagrant..."
echo "====================================="

# Vérifier les prérequis
echo ""
echo "📋 Vérification des prérequis..."

# VirtualBox
if command -v VBoxManage &> /dev/null; then
    echo "✅ VirtualBox : $(VBoxManage --version)"
else
    echo "❌ VirtualBox : Non installé"
    echo "   Installation : sudo apt install virtualbox virtualbox-ext-pack"
fi

# Vagrant
if command -v vagrant &> /dev/null; then
    echo "✅ Vagrant : $(vagrant --version)"
else
    echo "❌ Vagrant : Non installé"
    echo "   Installation : sudo apt install vagrant"
fi

# Clés SSH
echo ""
echo "🔑 Vérification des clés SSH..."
if [ -f ~/.ssh/id_rsa ]; then
    echo "✅ Clé privée : ~/.ssh/id_rsa"
else
    echo "❌ Clé privée : ~/.ssh/id_rsa manquante"
    echo "   Génération : ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ''"
fi

if [ -f ~/.ssh/id_rsa.pub ]; then
    echo "✅ Clé publique : ~/.ssh/id_rsa.pub"
else
    echo "❌ Clé publique : ~/.ssh/id_rsa.pub manquante"
    echo "   Génération : ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub"
fi

# Virtualisation
echo ""
echo "🔧 Vérification de la virtualisation..."
if grep -q "vmx" /proc/cpuinfo; then
    echo "✅ Intel VT-x : Activé"
elif grep -q "svm" /proc/cpuinfo; then
    echo "✅ AMD SVM : Activé"
else
    echo "❌ Virtualisation : Non détectée"
    echo "   Activez VT-x/SVM dans le BIOS"
fi

# Vérifier si les VMs existent
echo ""
echo "🖥️  Vérification des machines virtuelles..."
if VBoxManage list vms | grep -q "p1-vagrant"; then
    echo "✅ VMs VirtualBox : Présentes"
    VBoxManage list vms | grep "p1-vagrant"
else
    echo "ℹ️  VMs VirtualBox : Aucune VM p1-vagrant trouvée"
fi

# Vérifier l'état de Vagrant
echo ""
echo "📦 État de Vagrant..."
if [ -d .vagrant ]; then
    echo "✅ Dossier .vagrant : Présent"
    vagrant status 2>/dev/null | grep -E "(edetohS|edetohSW)" || echo "   Aucune VM Vagrant active"
else
    echo "ℹ️  Dossier .vagrant : Absent (premier lancement)"
fi

# Solutions automatiques
echo ""
echo "🔧 Solutions proposées..."
echo "========================"

if [ ! -f ~/.ssh/id_rsa ]; then
    echo ""
    echo "Génération automatique des clés SSH ? (o/N)"
    read -r response
    if [[ "$response" =~ ^([oO]|[yY]) ]]; then
        ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
        echo "✅ Clés SSH générées"
    fi
fi

if ! grep -q "vmx\|svm" /proc/cpuinfo; then
    echo ""
    echo "⚠️  La virtualisation n'est pas détectée."
    echo "   Redémarrez et activez VT-x/SVM dans le BIOS."
    echo "   Sur la plupart des machines :"
    echo "   - Appuyez sur F2, F10, F12 ou Del au démarrage"
    echo "   - Cherchez 'Virtualization Technology' ou 'VT-x'"
    echo "   - Activez l'option et sauvegardez"
fi

echo ""
echo "🎯 Prochaines étapes :"
echo "1. Corrigez les problèmes détectés ci-dessus"
echo "2. Lancez : vagrant up --provider=virtualbox"
echo "3. Si ça ne fonctionne pas : ./init.sh"
