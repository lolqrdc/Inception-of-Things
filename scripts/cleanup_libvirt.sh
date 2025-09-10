#!/bin/bash

# Script pour nettoyer les domaines libvirt orphelins
# Une seule demande de mot de passe sudo

PROJECT_NAME="p1-vagrant"

echo "🗑️  Suppression des domaines libvirt orphelins..."

# Destruction des domaines
for vm in edetohS edetohSW agloriosS agloriosSW; do
    virsh destroy ${PROJECT_NAME}_${vm} 2>/dev/null || true
done

# Suppression des définitions
for vm in edetohS edetohSW agloriosS agloriosSW; do
    virsh undefine ${PROJECT_NAME}_${vm} --remove-all-storage 2>/dev/null || true
done

echo "🧹 Nettoyage des volumes orphelins..."

# Suppression des volumes
for vm in edetohS edetohSW agloriosS agloriosSW; do
    virsh vol-delete ${PROJECT_NAME}_${vm}.img default 2>/dev/null || true
done

echo "✅ Nettoyage libvirt terminé"
