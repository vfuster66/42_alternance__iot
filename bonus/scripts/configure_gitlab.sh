#!/bin/bash
set -e

echo "Configuration automatique de GitLab..."

# Attendre que le pod GitLab soit prêt
echo "Attente que GitLab soit prêt..."
kubectl -n gitlab wait --for=condition=ready pod -l app=gitlab --timeout=600s

# Port-forward pour accéder à GitLab
echo "Configuration du port-forward..."
kubectl port-forward -n gitlab svc/gitlab 8929:80 &
PF_PID=$!

# Attendre que le port-forward soit établi
sleep 5

# Attendre que GitLab soit complètement initialisé
echo "Attente de l'initialisation complète de GitLab (cela peut prendre quelques minutes)..."
until curl -s http://localhost:8929/users/sign_in > /dev/null; do
  echo "GitLab n'est pas encore prêt, attente de 30 secondes..."
  sleep 30
done

echo "GitLab est prêt ! Configuration de l'utilisateur root..."

# Obtenir le mot de passe initial root
ROOT_PASSWORD=$(kubectl -n gitlab exec deployment/gitlab -- grep 'Password:' /etc/gitlab/initial_root_password | awk '{print $2}')

echo "Mot de passe root initial : $ROOT_PASSWORD"
echo "Vous pouvez maintenant vous connecter à GitLab sur http://localhost:8929"
echo "Utilisateur : root"
echo "Mot de passe : $ROOT_PASSWORD"

# Créer un projet pour ArgoCD
echo "Pour créer un nouveau projet dans GitLab :"
echo "1. Connectez-vous avec les identifiants ci-dessus"
echo "2. Créez un nouveau projet (par exemple 'votre-login-config')"
echo "3. Clonez le dépôt et ajoutez vos fichiers de configuration"

# Terminer le port-forward à la fin du script
kill $PF_PID

echo "Configuration de GitLab terminée !"
