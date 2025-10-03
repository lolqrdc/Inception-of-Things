# Partie 2 - Applications Web avec Ingress

Cette partie déploie 3 applications web avec un système d'ingress sur un cluster K3s.

## 🚀 Démarrage rapide

```bash
cd p2/scripts
make start    # Démarre P2 + test automatique
```

## 📋 Commandes disponibles

- `make start` - Démarrer P2 (K3s + 3 applications)
- `make stop` - Arrêter et nettoyer P2
- `make test` - Tester P2 (cluster + applications)
- `make status` - Afficher le statut de P2
- `make ssh` - Se connecter en SSH au serveur
- `make logs` - Afficher les logs des applications
- `make clean` - Nettoyage complet

## 🌐 Applications déployées

- **app1.com** → Application 1 (1 replica)
- **app2.com** → Application 2 (3 replicas)
- **default** → Application 3 (accès direct par IP)

## 🔧 Configuration requise

Ajoutez à votre `/etc/hosts` :
```
192.168.56.110 app1.com app2.com
```

## 🧪 Tests

```bash
# Tests automatiques
make test

# Tests manuels
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl http://192.168.56.110  # app3 par défaut
```

## 🏗️ Architecture

- **VM unique** : `edetohS` (2048 MB, Debian 13)
- **IP** : `192.168.56.110` sur interface `eth1`
- **K3s** : Server mode avec Traefik ingress
- **Applications** : 3 services web avec routage HOST-based