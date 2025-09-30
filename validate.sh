#!/bin/bash
# Script de validation rapide du projet Inception of Things

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔍 Validation du projet Inception of Things${NC}"
echo "=============================================="

# Vérifier la structure des fichiers
echo -e "${YELLOW}📁 Vérification de la structure...${NC}"
for dir in p1 p2 p3; do
    if [ -d "$dir" ]; then
        echo -e "  ✅ $dir/"
    else
        echo -e "  ❌ $dir/ manquant"
        exit 1
    fi
done

# Vérifier les fichiers essentiels
echo -e "${YELLOW}📄 Vérification des fichiers essentiels...${NC}"
FILES=(
    "p1/Makefile"
    "p1/Vagrantfile"
    "p1/install.sh"
    "p2/confs/app1-deployment.yaml"
    "p2/confs/app2-deployment.yaml"
    "p2/confs/app3-deployment.yaml"
    "p2/confs/ingress.yaml"
    "p3/run.sh"
    "p3/test-app.sh"
    "p3/scripts/install.sh"
    "p3/scripts/setup.sh"
    "p3/scripts/deploy-apps.sh"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ✅ $file"
    else
        echo -e "  ❌ $file manquant"
        exit 1
    fi
done

# Vérifier les permissions d'exécution
echo -e "${YELLOW}🔐 Vérification des permissions...${NC}"
EXECUTABLES=(
    "p1/install.sh"
    "p3/run.sh"
    "p3/test-app.sh"
    "p3/scripts/install.sh"
    "p3/scripts/setup.sh"
    "p3/scripts/deploy-apps.sh"
)

for exec in "${EXECUTABLES[@]}"; do
    if [ -x "$exec" ]; then
        echo -e "  ✅ $exec (exécutable)"
    else
        echo -e "  ⚠️  $exec (pas exécutable - sera corrigé par le Makefile)"
    fi
done

# Vérifier le Makefile
echo -e "${YELLOW}📋 Vérification du Makefile...${NC}"
cd p1
if make help >/dev/null 2>&1; then
    echo -e "  ✅ Makefile syntaxiquement correct"
else
    echo -e "  ❌ Erreur de syntaxe dans le Makefile"
    exit 1
fi

# Lister les cibles principales
echo -e "${YELLOW}🎯 Cibles principales disponibles :${NC}"
grep "^[a-zA-Z][a-zA-Z0-9_-]*:" Makefile | grep -v "^#" | cut -d: -f1 | sort | while read target; do
    echo -e "  • $target"
done

echo ""
echo -e "${GREEN}✅ Validation terminée avec succès !${NC}"
echo ""
echo -e "${YELLOW}🚀 Pour démarrer le projet :${NC}"
echo -e "  cd p1"
echo -e "  make install    # Installation initiale"
echo -e "  make start-all  # Démarrer toutes les parties"
echo ""
echo -e "${YELLOW}🛑 Pour nettoyer :${NC}"
echo -e "  make stop-all   # Tout arrêter et nettoyer"