#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ok() {
  echo -e "${GREEN}[OK]${NC} $1"
}

ko() {
  echo -e "${RED}[KO]${NC} $1"
}

### 1. Vérifier le contexte actif ###
CTX=$(kubectl config current-context 2>/dev/null)
if [[ "$CTX" == "k3d-iot-cluster" ]]; then
  ok "Contexte actif = $CTX"
else
  ko "Contexte actif incorrect ou cluster absent (actuel: $CTX)"
fi

### 2. Vérifier les droits Docker avant k3d ###
if ! docker info &>/dev/null; then
  ko "Impossible d'accéder au daemon Docker. Essayez de relancer ce terminal ou exécutez : newgrp docker"
  echo -e "${RED}[INFO]${NC} Skip vérification k3d car accès Docker refusé"
else
  if k3d cluster list | grep -q iot-cluster; then
    ok "Cluster k3d 'iot-cluster' détecté"
  else
    ko "Cluster k3d 'iot-cluster' manquant"
  fi
fi

### 3. Vérifier les namespaces ###
for ns in argocd dev; do
  if kubectl get ns $ns &>/dev/null; then
    ok "Namespace '$ns' présent"
  else
    ko "Namespace '$ns' manquant"
  fi
done

### 4. Vérifier l'application Argo CD ###
if kubectl get application -n argocd playground &>/dev/null; then
  SYNC=$(kubectl get application -n argocd playground -o jsonpath='{.status.sync.status}')
  HEALTH=$(kubectl get application -n argocd playground -o jsonpath='{.status.health.status}')
  [[ "$SYNC" == "Synced" ]] && ok "Application Argo CD synchronisée ($SYNC)" || ko "Application non synchronisée ($SYNC)"
  [[ "$HEALTH" == "Healthy" ]] && ok "Application en bonne santé ($HEALTH)" || ko "Application en erreur ($HEALTH)"
else
  ko "Application 'playground' non trouvée dans le namespace argocd"
fi

### 5. Vérifier les pods dans dev ###
if kubectl get pods -n dev | grep -q playground; then
  ok "Pod(s) déployé(s) dans le namespace dev"
else
  ko "Aucun pod détecté dans le namespace dev"
fi
