#!/bin/bash
set -e

# Récupérer le mot de passe admin d'ArgoCD
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Mot de passe ArgoCD : $ARGO_PWD"

# Création de l'application ArgoCD pour GitLab...
echo "Création de l'application ArgoCD pour GitLab..."

# Demander le nom du dépôt et le token GitLab
read -p "Entrez le nom de votre dépôt GitLab (ex: root/vfuster-config) : " REPO_NAME
read -p "Entrez votre token GitLab : " GITLAB_TOKEN
GITLAB_USER="oauth2"
GITLAB_URL="http://gitlab.gitlab.svc.cluster.local/${REPO_NAME}.git"

echo "Configuration des identifiants GitLab pour ArgoCD..."

# Créer un secret pour les identifiants GitLab
kubectl create secret generic gitlab-creds \
  --namespace argocd \
  --from-literal=username=${GITLAB_USER} \
  --from-literal=password=${GITLAB_TOKEN} \
  --dry-run=client -o yaml | kubectl apply -f -

# Créer le secret de repository pour ArgoCD
cat > repo-creds.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${GITLAB_URL}
  username: ${GITLAB_USER}
  password: ${GITLAB_TOKEN}
EOF

kubectl apply -f repo-creds.yaml

# Créer la configuration de l'application ArgoCD
cat > argocd-app-gitlab.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-gitlab
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${GITLAB_URL}
    targetRevision: main
    path: kubernetes
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Appliquer la configuration
kubectl apply -f argocd-app-gitlab.yaml

echo "Configuration ArgoCD terminée !"
