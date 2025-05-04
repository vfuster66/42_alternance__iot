# Inception of Things - Partie Bonus : GitLab + ArgoCD

Cette partie bonus implémente l'intégration GitLab + ArgoCD dans votre cluster Kubernetes, permettant une configuration CI/CD complète avec un dépôt Git local hébergé dans le cluster.

## 📋 Vue d'ensemble

Ce projet déploie GitLab dans un cluster Kubernetes et le configure pour fonctionner avec ArgoCD, créant ainsi un pipeline CI/CD complet où les mises à jour de code dans GitLab sont automatiquement déployées dans le cluster.

### ✅ Fonctionnalités

- Déploiement de GitLab CE dans un namespace dédié
- Configuration automatique des identifiants
- Préparation d'un dépôt avec les fichiers de configuration Kubernetes
- Intégration avec ArgoCD pour le déploiement automatisé
- Mise à jour d'application de v1 à v2 via GitLab

## 🚀 Installation et utilisation

### Prérequis
- Un cluster Kubernetes fonctionnel (K3d)
- kubectl configuré
- Au moins 2Gi de RAM disponible pour GitLab

### Commandes principales

```bash
# 1. Installation de GitLab
make install

# 2. Configuration et obtention du mot de passe root
make configure

# 3. Accès à GitLab via port-forward
make launch

# 4. Création d'un dépôt Git local
make prepare-repo

# 5. Configuration d'ArgoCD avec GitLab (avec authentification)
make setup-argocd

# 6. Accès à ArgoCD pour vérifier le déploiement
make access-argocd
```

## 📝 Processus détaillé

1. **Installation de GitLab**
   - Déploie GitLab CE version 15.4.0 dans le namespace `gitlab`
   - Configure les ressources nécessaires (CPU et mémoire)

2. **Configuration de l'utilisateur root**
   - Récupère le mot de passe initial généré automatiquement
   - Établit un port-forward pour accéder à l'interface web

3. **Création du projet GitLab**
   - Se connecter à GitLab (http://localhost:8929)
   - Créer un nouveau projet (ex: `vfuster-config`)
   - Générer un token d'accès personnel

4. **Préparation du dépôt Git**
   - Crée un dépôt temporaire avec les fichiers Kubernetes
   - Prépare un déploiement avec l'image v1 de l'application

5. **Intégration avec ArgoCD**
   - Configure l'authentification avec le token GitLab
   - Crée une application ArgoCD qui surveille le dépôt
   - Configure la synchronisation automatique

6. **Test du déploiement automatisé**
   - Modifier le fichier deployment.yaml pour passer à v2
   - Observer la synchronisation automatique dans ArgoCD

## 🔄 Mise à jour d'une application

Pour mettre à jour l'application de v1 à v2 :

```bash
# Depuis le dépôt temporaire créé par make prepare-repo
cd /chemin/vers/depot/temporaire
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' kubernetes/deployment.yaml
git add kubernetes/deployment.yaml
git commit -m "Update to v2"
git push origin main
```

ArgoCD détectera automatiquement les changements et mettra à jour le déploiement.

## 🔍 Diagnostic

```bash
# Vérifier l'état de GitLab
make check-gitlab

# Accéder à l'interface GitLab
make launch

# Accéder à l'interface ArgoCD
make access-argocd
```

## 🧹 Nettoyage

```bash
# Supprimer l'installation GitLab
make clean
```

## 🔐 Authentification

- **GitLab** : 
  - URL: http://localhost:8929
  - Utilisateur: root
  - Mot de passe: Fourni par `make configure`

- **ArgoCD** :
  - URL: http://localhost:8080
  - Utilisateur: admin
  - Mot de passe: Affiché par `make setup-argocd`

## 📁 Structure du projet

```
bonus/
├── confs/                  # Fichiers de configuration
│   ├── argocd-app-gitlab.yaml      # Configuration de l'application ArgoCD
│   ├── argocd-app-gitlab-auth.yaml # Configuration avec authentification
│   ├── gitlab-minimal.yaml         # Déploiement GitLab
│   └── repo-creds.yaml             # Secrets pour l'authentification
├── Makefile                # Commandes make
├── README.md               # Documentation
└── scripts/                # Scripts d'automatisation
    ├── configure_gitlab.sh        # Configuration initiale de GitLab
    ├── install_gitlab_minimal.sh  # Installation de GitLab dans le cluster
    ├── prepare_git_repo.sh        # Préparation du dépôt Git local
    └── setup_argocd_gitlab.sh     # Configuration d'ArgoCD avec GitLab
```

## 📌 Notes importantes

- GitLab nécessite des ressources significatives. Assurez-vous que votre cluster dispose d'au moins 2Go de RAM disponible.
- La première initialisation peut prendre plusieurs minutes.
- Le token d'accès personnel GitLab est nécessaire pour que ArgoCD puisse se connecter au dépôt.