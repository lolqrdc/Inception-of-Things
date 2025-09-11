#!/bin/bash

# =============================================================================
# Script d'installation pour Inception of Things (IoT)
# Ce script configure automatiquement l'environnement pour le projet K3s
# =============================================================================

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérification que le script est exécuté depuis le bon répertoire
check_directory() {
    if [ ! -f "Vagrantfile" ] || [ ! -f "Makefile" ]; then
        log_error "Ce script doit être exécuté depuis le répertoire racine du projet (contenant Vagrantfile et Makefile)"
        exit 1
    fi
}

# Vérification des prérequis système
check_system() {
    log_info "Vérification du système..."

    # Vérifier Ubuntu
    if ! command -v lsb_release >/dev/null 2>&1 || ! lsb_release -d | grep -q "Ubuntu"; then
        log_error "Ce script nécessite Ubuntu"
        exit 1
    fi

    # Vérifier les droits sudo
    if ! sudo -n true 2>/dev/null; then
        log_warning "Droits sudo requis. Vous pourriez être invité à saisir votre mot de passe."
    fi

    log_success "Système compatible détecté"
}

# Installation de VirtualBox
install_virtualbox() {
    log_info "Vérification et installation de VirtualBox..."

    if command -v VBoxManage >/dev/null 2>&1; then
        local version=$(VBoxManage --version)
        log_success "VirtualBox déjà installé (version: $version)"
        return 0
    fi

    log_info "Installation de VirtualBox..."
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -y virtualbox virtualbox-ext-pack >/dev/null 2>&1

    # Ajouter l'utilisateur au groupe vboxusers
    sudo usermod -aG vboxusers $USER

    log_success "VirtualBox installé avec succès"
}

# Installation de Vagrant
install_vagrant() {
    log_info "Vérification et installation de Vagrant..."

    if command -v vagrant >/dev/null 2>&1; then
        local version=$(vagrant --version)
        log_success "Vagrant déjà installé ($version)"
        return 0
    fi

    log_info "Installation de Vagrant..."

    # Télécharger et installer Vagrant depuis le site officiel
    wget -O vagrant.deb https://releases.hashicorp.com/vagrant/2.4.1/vagrant_2.4.1-1_amd64.deb >/dev/null 2>&1
    sudo dpkg -i vagrant.deb >/dev/null 2>&1
    sudo apt-get install -f -y >/dev/null 2>&1  # Résoudre les dépendances
    rm -f vagrant.deb

    log_success "Vagrant installé avec succès"
}

# Configuration de la virtualisation imbriquée
setup_nested_virtualization() {
    log_info "Configuration de la virtualisation imbriquée..."

    # Vérifier si nous sommes dans une VM
    if systemd-detect-virt >/dev/null 2>&1; then
        log_warning "Virtualisation imbriquée détectée"

        # Décharger les modules KVM s'ils sont chargés
        if lsmod | grep -q kvm; then
            log_info "Déchargement des modules KVM pour éviter les conflits..."
            sudo modprobe -r kvm_intel kvm 2>/dev/null || true
        fi

        # Blacklister KVM pour éviter les conflits avec VirtualBox
        if [ ! -f /etc/modprobe.d/blacklist-kvm.conf ]; then
            log_info "Configuration du blacklist KVM..."
            echo "blacklist kvm" | sudo tee /etc/modprobe.d/blacklist-kvm.conf >/dev/null
            echo "blacklist kvm_intel" | sudo tee -a /etc/modprobe.d/blacklist-kvm.conf >/dev/null
            sudo update-initramfs -u >/dev/null 2>&1
        fi

        log_success "Virtualisation imbriquée configurée"
    else
        log_success "Environnement de virtualisation standard détecté"
    fi
}

# Installation des outils supplémentaires
install_tools() {
    log_info "Installation des outils supplémentaires..."

    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -y \
        curl \
        wget \
        net-tools \
        make \
        git \
        vim \
        htop \
        tree >/dev/null 2>&1

    log_success "Outils supplémentaires installés"
}

# Préparation des répertoires
setup_directories() {
    log_info "Préparation des répertoires..."

    # Créer le répertoire confs s'il n'existe pas
    mkdir -p confs
    chmod 755 confs

    # Rendre les scripts exécutables
    if [ -d scripts ]; then
        chmod +x scripts/*.sh
    fi

    log_success "Répertoires préparés"
}

# Test de la configuration
test_configuration() {
    log_info "Test de la configuration..."

    # Vérifier VirtualBox
    if ! VBoxManage list vms >/dev/null 2>&1; then
        log_error "VirtualBox ne fonctionne pas correctement"
        return 1
    fi

    # Vérifier Vagrant
    if ! vagrant version >/dev/null 2>&1; then
        log_error "Vagrant ne fonctionne pas correctement"
        return 1
    fi

    log_success "Configuration testée avec succès"
}

# Affichage des instructions finales
show_usage() {
    echo ""
    echo -e "${GREEN}🎉 Installation terminée avec succès !${NC}"
    echo ""
    echo -e "${BLUE}📖 Instructions d'utilisation :${NC}"
    echo ""
    echo -e "${YELLOW}Démarrer le cluster K3s :${NC}"
    echo "  make up"
    echo ""
    echo -e "${YELLOW}Vérifier l'état du cluster :${NC}"
    echo "  make cluster-info"
    echo ""
    echo -e "${YELLOW}Se connecter aux machines :${NC}"
    echo "  make ssh-server    # Master node"
    echo "  make ssh-worker    # Worker node"
    echo ""
    echo -e "${YELLOW}Nettoyer complètement :${NC}"
    echo "  make clean"
    echo ""
    echo -e "${YELLOW}Aide complète :${NC}"
    echo "  make help"
    echo ""
    if systemd-detect-virt >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Note importante pour la virtualisation imbriquée :${NC}"
        echo "Si vous rencontrez des problèmes, redémarrez votre VM après l'installation."
        echo ""
    fi
}

# Fonction principale
main() {
    echo -e "${GREEN}🚀 Installation d'Inception of Things (IoT) - Projet K3s${NC}"
    echo "================================================================"
    echo ""

    check_directory
    check_system
    install_virtualbox
    install_vagrant
    setup_nested_virtualization
    install_tools
    setup_directories
    test_configuration
    show_usage
}

# Gestion des signaux
trap 'log_error "Installation interrompue"; exit 1' INT TERM

# Exécution du script principal
main "$@"
