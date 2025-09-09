# P1 Vagrant - Cluster K3s

Ce projet permet de créer automatiquement un cluster Kubernetes K3s avec Vagrant et libvirt.

## Architecture

- **edetohS** (192.168.56.110) : Serveur K3s (master node)
- **edetohSW** (192.168.56.111) : Worker K3s (worker node)

## Prérequis

- Vagrant
- libvirt/KVM
- Accès sudo (pour la gestion des domaines libvirt)

## Utilisation

### Démarrage rapide

```bash
# Démarrer le cluster
make

# Ou explicitement
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
├── Vagrantfile                 # Configuration Vagrant
├── Makefile                    # Automatisation
├── scripts/
│   ├── install_k3s_server.sh  # Installation du serveur K3s
│   └── install_k3s_worker.sh  # Installation du worker K3s
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

## Développement

Pour contribuer ou modifier le projet :

1. Les scripts d'installation sont dans `scripts/`
2. Le `Makefile` contient toute l'automatisation
3. Le `Vagrantfile` définit l'infrastructure

## Licence

Ce projet est à des fins éducatives.
