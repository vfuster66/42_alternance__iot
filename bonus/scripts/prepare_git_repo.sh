#!/bin/bash
set -e

# Créer un dossier temporaire pour le repo
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

echo "Préparation du dépôt Git dans $TEMP_DIR"

# Initialiser le repo Git
git init
git config --local user.name "root"
git config --local user.email "admin@example.com"

# Créer le fichier de déploiement pour la version v1
mkdir -p kubernetes
cat > kubernetes/deployment.yaml << 'EOFDEPL'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: wil42/playground:v1
        ports:
        - containerPort: 8888
---
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: dev
spec:
  selector:
    app: web-app
  ports:
  - port: 8888
    targetPort: 8888
  type: ClusterIP
EOFDEPL

# Créer le README
cat > README.md << 'EOFREADME'
# Inception of Things - Partie Bonus

Ce dépôt contient les configurations Kubernetes pour le déploiement de l'application via ArgoCD.

## Versions
- v1: Version initiale de l'application
- v2: Version mise à jour de l'application (à déployer via un commit)

## Structure
- kubernetes/deployment.yaml: Fichier de déploiement Kubernetes

## CI/CD avec ArgoCD
1. L'application est automatiquement déployée via ArgoCD
2. Pour mettre à jour vers v2, modifiez l'image dans deployment.yaml
3. Commitez et poussez les changements
4. ArgoCD détectera les changements et déploiera automatiquement la nouvelle version
EOFREADME

# Ajouter et commiter les fichiers
git add .
git commit -m "Initial commit with v1 app"

echo "Dépôt Git préparé avec succès !"
echo ""
echo "Pour connecter ce dépôt à GitLab, exécutez les commandes suivantes :"
echo "git remote add origin http://localhost:8929/root/votre-login-config.git"
echo "git push -u origin main"
echo ""
echo "Pour mettre à jour vers la version v2, exécutez :"
echo "sed -i 's/wil42\\/playground:v1/wil42\\/playground:v2/g' kubernetes/deployment.yaml"
echo "git add kubernetes/deployment.yaml"
echo "git commit -m \"Update to v2\""
echo "git push origin main"
echo ""
echo "Emplacement du dépôt : $TEMP_DIR"
