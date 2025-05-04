#!/bin/bash
set -e

echo "Installation de GitLab minimal..."

# Supprimer et recréer le namespace
kubectl delete ns gitlab --grace-period=0 --force || true
sleep 5
kubectl create namespace gitlab

# Déployer GitLab
kubectl apply -f confs/gitlab-minimal.yaml

echo "GitLab se déploie... (cela peut prendre plusieurs minutes)"
echo "Vérifiez le statut avec: kubectl -n gitlab get pods"
echo "Une fois que le pod est 'Running', GitLab sera accessible via:"
echo "kubectl port-forward -n gitlab svc/gitlab 8929:80"
echo "Puis accédez à http://localhost:8929 dans votre navigateur"
