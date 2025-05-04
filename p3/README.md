# Partie 3 : K3d et Argo CD

Cette partie implémente une infrastructure CI/CD avec K3d et Argo CD, qui déploie automatiquement une application depuis un dépôt GitHub et permet de changer facilement de version.

## Objectifs

- Installer K3d pour exécuter K3s dans Docker
- Configurer un cluster K3d
- Déployer Argo CD dans le namespace "argocd"
- Créer un namespace "dev" pour l'application
- Configurer Argo CD pour déployer automatiquement une application depuis GitHub
- Démontrer le changement de version (v1 à v2) via GitHub

## Définitions des concepts clés

### K3d vs K3s

- **K3s** : Distribution légère de Kubernetes, développée par Rancher, qui nécessite moins de ressources système.
- **K3d** : Wrapper permettant d'exécuter K3s dans des conteneurs Docker, simplifiant la création et la destruction de clusters pour les environnements de développement.

### Intégration Continue et Argo CD

- **Intégration continue** : Pratique de développement logiciel qui consiste à intégrer régulièrement le code source d'une application dans un dépôt partagé, puis à le tester et le déployer automatiquement.
- **Argo CD** : Outil GitOps qui synchronise automatiquement l'état d'un cluster Kubernetes avec une configuration déclarative stockée dans un dépôt Git. Lorsqu'une modification est apportée au dépôt, Argo CD détecte le changement et met à jour le cluster en conséquence.

### Namespace vs Pod

- **Namespace** : Division logique d'un cluster Kubernetes permettant d'isoler les ressources et d'organiser les applications. Similaire à des dossiers dans un système de fichiers.
- **Pod** : Plus petite unité déployable dans Kubernetes, constituée d'un ou plusieurs conteneurs qui partagent des ressources et un cycle de vie commun.

## Infrastructure déployée

L'infrastructure consiste en un cluster K3d sur lequel sont déployés :

- **Argo CD** dans le namespace "argocd"
- **Une application de démonstration** dans le namespace "dev"

L'application de démonstration est déployée à partir du dépôt GitHub "vfuster66/vfuster-config" et utilise l'image Docker "wil42/playground" avec deux versions disponibles (v1 et v2).

## Installation et configuration

Pour installer et configurer l'environnement complet (Docker, K3d, Argo CD, et l'application) :

```bash
# Se placer dans le dossier p3
cd p3

# Installer et configurer tout l'environnement
make install
```

Cette commande exécute le script d'installation (`scripts/install.sh`) qui :
1. Installe Docker (si nécessaire)
2. Installe K3d (si nécessaire)
3. Installe kubectl (si nécessaire)
4. Crée un cluster K3d nommé "iot-cluster"
5. Déploie Argo CD dans le namespace argocd
6. Configure l'application Argo CD pour surveiller le dépôt GitHub
7. Configure le port-forwarding pour accéder à Argo CD et à l'application

## Détail des fichiers de configuration

### confs/app.yaml

Ce fichier définit l'application Argo CD qui surveille le dépôt GitHub :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: playground
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/vfuster66/vfuster-config.git
    targetRevision: HEAD
    path: app
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Cette configuration :
- Spécifie le dépôt GitHub à surveiller (`vfuster66/vfuster-config`)
- Indique le chemin dans le dépôt où se trouvent les fichiers de configuration (`app`)
- Déploie l'application dans le namespace `dev`
- Active la synchronisation automatique (`automated`) avec nettoyage (`prune`) et auto-réparation (`selfHeal`)

### Structure du dépôt GitHub

Le dépôt GitHub contient un fichier `app/deployment.yaml` qui définit :
- Un déploiement Kubernetes avec l'image `wil42/playground:v1` ou `wil42/playground:v2`
- Un service Kubernetes exposant le port 8888

## Vérifications

Pour vérifier que tout fonctionne correctement :

```bash
# Vérifier l'environnement
make check
```

Cette commande exécute le script `p3_check.sh` qui vérifie :
- Que le cluster K3d est actif
- Que les namespaces "argocd" et "dev" existent
- Que l'application Argo CD est synchronisée et en bonne santé
- Qu'il y a au moins un pod dans le namespace "dev"

### Vérifications manuelles

```bash
# Vérifier les namespaces
kubectl get ns
# Doit afficher les namespaces "argocd" et "dev"

# Vérifier les pods dans le namespace dev
kubectl get pods -n dev
# Doit afficher au moins un pod "playground-xxx" en état "Running"

# Vérifier les pods d'Argo CD
kubectl get pods -n argocd
# Doit afficher plusieurs pods Argo CD en état "Running"

# Vérifier l'état de l'application Argo CD
kubectl get application -n argocd playground
# Doit afficher "Synced" et "Healthy"
```

## Accès à l'interface Argo CD

Pour accéder à l'interface web d'Argo CD :

```bash
# Si le port-forwarding n'est pas déjà configuré
make port-forward
```

Puis ouvrir dans un navigateur : [https://localhost:8080](https://localhost:8080)
- Utilisateur : admin
- Mot de passe : obtenu lors de l'installation (affiché dans la console)

Si vous avez besoin de récupérer le mot de passe à nouveau :
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Test de l'application

L'application est accessible sur le port 8888 (via port-forwarding) :

```bash
# Tester l'application
curl -s http://localhost:8888/
# Devrait afficher {"status":"ok", "message": "v1"} ou {"status":"ok", "message": "v2"}
```

## Changer la version de l'application

Pour tester le processus CI/CD, vous pouvez changer la version de l'application en modifiant le fichier de configuration sur GitHub :

1. Accéder au dépôt GitHub : [https://github.com/vfuster66/vfuster-config](https://github.com/vfuster66/vfuster-config)
2. Modifier le fichier `app/deployment.yaml`
3. Changer la ligne d'image de `wil42/playground:v1` à `wil42/playground:v2` (ou vice versa)
4. Commit et push les changements

Après quelques instants, Argo CD détectera le changement et mettra à jour l'application automatiquement. Vous pouvez observer ce processus de plusieurs façons :

```bash
# Observer la recréation du pod
kubectl get pods -n dev -w

# Vérifier la nouvelle version de l'application
curl -s http://localhost:8888/
# Devrait maintenant afficher la nouvelle version
```

Vous pouvez également observer la synchronisation dans l'interface web d'Argo CD.

## Commandes du Makefile

Le Makefile inclut plusieurs commandes utiles pour gérer l'environnement :

```bash
# Installer l'environnement complet
make install

# Vérifier l'état de l'environnement
make check

# Configurer le port forwarding pour Argo CD et l'application
make port-forward

# Arrêter le port forwarding
make stop-forward

# Forcer la synchronisation automatique
make sync

# Forcer une synchronisation immédiate
make sync-now

# Tester l'application
make test

# Supprimer le cluster et nettoyer l'environnement
make clean
```

## Explications détaillées du processus CI/CD

Le processus complet fonctionne comme suit :

1. **Configuration initiale** :
   - Le script d'installation crée un cluster K3d
   - Argo CD est déployé dans le namespace "argocd"
   - Une application Argo CD est configurée pour surveiller le dépôt GitHub

2. **Déploiement initial** :
   - Argo CD lit les manifestes Kubernetes du dépôt GitHub
   - Il crée les ressources correspondantes dans le namespace "dev"
   - L'application "playground" est déployée avec l'image spécifiée

3. **Mise à jour de l'application** :
   - Lorsqu'un changement est effectué sur le dépôt GitHub (par exemple, changer la version de l'image)
   - Argo CD détecte ce changement via la configuration `syncPolicy.automated`
   - Il met à jour les ressources dans le cluster pour correspondre à l'état souhaité
   - Le pod est recréé avec la nouvelle version de l'image

4. **Vérification** :
   - On peut vérifier que l'application utilise bien la nouvelle version en interrogeant son API
   - L'interface d'Argo CD affiche l'historique des synchronisations et l'état actuel des ressources

Ce processus GitOps présente plusieurs avantages :
- Git comme source unique de vérité pour l'état souhaité du cluster
- Déploiements automatisés sans intervention manuelle
- Auditabilité complète des changements via l'historique Git
- Facilité de rollback en cas de problème
