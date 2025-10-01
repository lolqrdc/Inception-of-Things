# Inception of Things

Projet de déploiement Kubernetes avec Vagrant, K3s et ArgoCD.

## 🚀 Installation et démarrage rapide

```bash
# Validation du projet
cd p3/scripts && ./validate.sh

# Installation et démarrage complet
cd p1/scripts
make install      # Installation initiale (une seule fois)
make start-all    # Démarrer toutes les parties (P1+P2+P3)

# Tests
make test-p2      # Tester les applications P2
make test-p3      # Tester l'application P3
```

## 📦 Structure du projet

```
├── p1/
│   ├── scripts/     # Makefile principal et scripts d'installation
│   ├── Vagrantfile  # Configuration des VMs
│   └── confs/       # Fichiers de configuration K3s (générés)
├── p2/          # Applications Kubernetes (app1, app2, app3)
├── p3/          # ArgoCD et application wil-playground
│   └── scripts/     # Scripts et validate.sh
└── README.md    # Ce fichier
```

## 🎯 Commandes principales

| Commande | Description |
|----------|-------------|
| `make start-all` | Démarrer toutes les parties (P1+P2+P3) + test P3 |
| `make stop-all` | Arrêter et nettoyer tout |
| `make help` | Afficher l'aide complète |

## 🌐 Applications accessibles

**Après `make start-all` :**

### P2 - Applications Kubernetes
- **app1**: http://app1.com (ajoutez `192.168.56.110 app1.com` à `/etc/hosts`)
- **app2**: http://app2.com (ajoutez `192.168.56.110 app2.com` à `/etc/hosts`)
- **app3**: http://192.168.56.110

### P3 - ArgoCD
- **ArgoCD UI**: http://localhost:8080 (après `make port-forward-p3`)
- **wil-playground**: http://localhost:8889 (lancé automatiquement avec `make start-all`)

## 🔧 Commandes détaillées

### P1 - Cluster K3s
```bash
cd p1/scripts
make up           # Démarrer le cluster K3s
make status       # Statut des VMs
make cluster-info # Informations cluster
make destroy      # Détruire les VMs
```

### P2 - Applications
```bash
cd p1/scripts
make deploy-p2    # Déployer les applications
make status-p2    # Statut des applications
make test-p2      # Tester les applications
make clean-p2     # Supprimer les applications
```

### P3 - ArgoCD
```bash
cd p1/scripts
make install-p3     # Installer K3d
make setup-p3       # Configurer ArgoCD
make deploy-p3      # Déployer wil-playground
make status-p3      # Statut de P3
make port-forward-p3 # Accès ArgoCD (http://localhost:8080)
make test-p3        # Tester l'application
make clean-p3       # Nettoyer P3
```

## 🛠️ Dépannage

### Problème de connexion ArgoCD
```bash
cd p1/scripts
make port-forward-p3  # Relancer le port-forward
# Puis accéder à http://localhost:8080
```

### Redémarrage complet
```bash
cd p1/scripts
make stop-all    # Tout nettoyer
make start-all   # Tout redémarrer
```

### Vérification de l'état
```bash
cd p1/scripts
make status      # VMs P1
make status-p2   # Applications P2
make status-p3   # ArgoCD et P3
```## 📋 Prérequis

- VirtualBox
- Vagrant
- Docker (installé automatiquement pour P3)
- kubectl (installé automatiquement pour P3)
- k3d (installé automatiquement pour P3)

## 🎓 Détails techniques

- **P1** : Cluster K3s avec 1 master + 1 worker (VMs Vagrant)
- **P2** : 3 applications avec Ingress sur le cluster K3s
- **P3** : ArgoCD sur cluster K3d avec GitOps pour wil-playground

Le projet utilise GitOps pour P3 avec le repository externe :
https://github.com/eliamd/iot-dep.git