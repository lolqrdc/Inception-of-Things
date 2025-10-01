# Inception of Things - Partie 3 (ArgoCD)

Déploiement d'ArgoCD avec K3d et l'application wil42/playground.

## 🚀 Installation

```bash
cd /home/e/Inception-of-Things/p3

# Installation complète
./scripts/run.sh install    # K3d + Docker + kubectl
# Reconnexion nécessaire pour Docker
./scripts/run.sh setup      # ArgoCD
./scripts/run.sh deploy     # Application wil-playground
```

## 🌐 Accès

- **ArgoCD**: https://localhost:8080 (admin/password affiché dans `./scripts/run.sh status`)
- **Application**: `./scripts/test-app.sh test` puis http://localhost:8888

## 🔄 Changement de version

Les manifests Kubernetes sont maintenant dans le repository externe:
**https://github.com/eliamd/iot-dep.git**

```bash
# Cloner le repository
git clone https://github.com/eliamd/iot-dep.git
cd iot-dep

# Modifier la version dans deployment.yaml
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' deployment.yaml

# Pousser les changements
git add deployment.yaml
git commit -m "Update to v2"
git push            # ArgoCD synchronise automatiquement
```

## 🔧 Commandes utiles

```bash
./scripts/run.sh status         # Statut complet
./scripts/test-app.sh status    # Statut application
kubectl get ns          # Voir namespaces: argocd, dev
kubectl get pods -n dev # Voir pods wil-playground
./scripts/run.sh clean          # Nettoyage
```
