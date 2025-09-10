# P1 Vagrant - Cluster K3s

Ce projet permet de créer automatiquement un cluster Kubernetes K3s avec Vagrant et VirtualBox.

## Architecture

- **edetohS** (192.168.56.110) : Serveur K3s (master node)
- **edetohSW** (192.168.56.111) : Worker K3s (worker node)

## Prérequis

- Vagrant
- VirtualBox
- Clés SSH (générées automatiquement si nécessaire)

## Installation sur une nouvelle machine

Sur une nouvelle machine, exécutez d'abord le script d'initialisation :

```bash
./init.sh
```

Ce script va :
- Générer les clés SSH si elles n'existent pas
- Installer VirtualBox si nécessaire
- Installer Vagrant si nécessaire

## Utilisation

### Démarrage rapide

```bash
# Démarrer le cluster
vagrant up

# Ou utiliser le Makefile
make up
```

### Commandes principales

```bash
# Nettoyer et redémarrer complètement
make re

# Nettoyer complètement (destruction + nettoyage des ressources)
make clean

# Voir le statut des machines
make status

# Informations sur le cluster K3s
make cluster-info
```

### Connexion aux machines

```bash
# SSH vers le serveur
make ssh-server

# SSH vers le worker
make ssh-worker
```

### Accès au cluster depuis l'hôte

```bash
# Récupérer la configuration kubectl
make get-kubeconfig

# Utiliser la configuration
export KUBECONFIG=~/.kube/config-p1
kubectl get nodes
```

### Dépannage

```bash
# Voir les logs des services
make logs

# Redémarrer les services K3s
make restart-k3s

# Aide complète
make help
```

## Structure du projet

```
.
├── Vagrantfile                 # Configuration Vagrant avec K3s inline
├── Makefile                    # Automatisation
├── scripts/
│   ├── fetch_k3s_files.sh     # Récupération automatique des fichiers K3s
│   └── cleanup_libvirt.sh     # Nettoyage des ressources libvirt
├── confs/                      # Dossier partagé (créé automatiquement)
│   ├── node-token             # Token K3s (généré)
│   └── k3s.yaml               # Configuration kubectl (générée)
└── README.md                   # Cette documentation
```

## Résolution des problèmes courants

### Erreur "Name already taken"

```bash
make clean  # Nettoie tout
make up     # Redémarre
```

### Machines qui ne démarrent pas

```bash
# Vérifier l'état libvirt
sudo virsh list --all

# Forcer le nettoyage
make clean
```

### Problèmes de réseau

Les machines utilisent le réseau privé `192.168.56.0/24`. Assurez-vous qu'il n'y a pas de conflit avec votre réseau local.

## Configuration

### Modifier les ressources

Éditez le `Vagrantfile` pour ajuster :
- Mémoire : `lv.memory = "1024"`
- CPU : `lv.cpus = 1`
- IP : `vm.network "private_network", ip: "..."`

### Modifier la version K3s

Les scripts téléchargent automatiquement la dernière version stable. Pour une version spécifique, modifiez les scripts dans `scripts/`.

## Dépannage

### Erreur "private_key_path file must exist"

**Cause** : Les clés SSH n'existent pas sur la nouvelle machine.

**Solution** :
```bash
# Exécuter le script d'initialisation
./init.sh

# Ou générer manuellement les clés SSH
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
```

### Erreur "File upload source file must exist"

**Cause** : Le fichier `~/.ssh/id_rsa.pub` n'existe pas.

**Solution** : Exécutez `./init.sh` ou générez les clés SSH comme indiqué ci-dessus.

### Erreur "VirtualBox is not installed"

**Cause** : VirtualBox n'est pas installé sur la machine.

**Solution** :
```bash
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

### Erreur "Vagrant is not installed"

**Cause** : Vagrant n'est pas installé.

**Solution** :
```bash
sudo apt install vagrant
```

### Problème d'espace disque

**Cause** : Pas assez d'espace pour créer les VMs.

**Solution** :
```bash
# Vérifier l'espace disponible
df -h

# Libérer de l'espace si nécessaire
sudo apt autoremove
sudo apt autoclean
```

### Les VMs ne démarrent pas

**Cause** : Conflit avec VirtualBox ou réseau.

**Solution** :
```bash
# Nettoyer complètement
vagrant destroy -f
rm -rf .vagrant

# Redémarrer VirtualBox
sudo systemctl restart virtualbox

# Relancer
vagrant up
```

### Problème de réseau entre les VMs

**Cause** : Conflit d'IP ou problème de réseau VirtualBox.

**Solution** :
```bash
# Vérifier les IPs
vagrant ssh edetohS -c "ip addr show"
vagrant ssh edetohSW -c "ip addr show"

# Tester la connectivité
vagrant ssh edetohSW -c "ping -c 3 192.168.56.110"
```

## Développement

Pour contribuer ou modifier le projet :

1. Les scripts d'installation sont dans `scripts/`
2. Le `Makefile` contient toute l'automatisation
3. Le `Vagrantfile` définit l'infrastructure

## Licence

Ce projet est à des fins éducatives.
