# Partie 3 - ArgoCD et GitOps

Cette partie déploie ArgoCD sur un cluster K3d pour la gestion GitOps des applications.

## 🚀 Démarrage rapide

```bash
cd p3/scripts
make start    # Installation + démarrage + test automatique
```

## 📋 Commandes principales

- `make install` - Installer K3d et ArgoCD
- `make start` - Démarrage complet P3 (install + setup + deploy + test)
- `make stop` - Arrêter et nettoyer P3
- `make deploy` - Déployer les applications
- `make test` - Tester P3 (cluster + ArgoCD + apps)
- `make validate` - Validation complète

## 🔧 Commandes utilitaires

- `make status` - Afficher le statut de P3
- `make logs` - Afficher les logs
- `make restart` - Redémarrer les services
- `make argocd-ui` - Accéder à ArgoCD UI
- `make port-forward` - Port-forward vers wil-playground
- `make clean` - Nettoyage complet

## 🎯 Workflow recommandé

```bash
# 1. Démarrage complet
make start

# 2. Accès à ArgoCD UI
make argocd-ui
# URL: https://localhost:8080
# Username: admin
# Password: affiché par la commande

# 3. Test de l'application
make port-forward
# Dans un autre terminal :
curl http://localhost:8889/

# 4. Validation complète
make validate

# 5. Arrêt
make stop
```

## 🌟 Technologies

- **K3d** : Cluster Kubernetes dans Docker
- **ArgoCD** : GitOps et déploiement continu
- **Application Wil** : Déployée via GitOps depuis https://github.com/eliamd/iot-dep.git

## 🌐 Accès aux services

- **ArgoCD UI** : `https://localhost:8080`
- **wil-playground** : `http://localhost:8889` (après port-forward)

## 🏗️ Architecture

- **Cluster K3d** : `iot-cluster`
- **Namespaces** : `argocd`, `dev`
- **Déploiement** : GitOps automatisé via ArgoCD
- **Monitoring** : Logs et métriques intégrés