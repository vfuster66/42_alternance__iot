# Inception-of-Things (IoT)

Ce projet explore l'utilisation de technologies de conteneurisation et d'orchestration modernes pour mettre en place des infrastructures automatisées. À travers différentes parties, nous implémentons et configurons des environnements utilisant Vagrant, K3s, K3d et Argo CD.

## Vue d'ensemble du projet

Le projet est divisé en trois parties obligatoires :

1. **K3s et Vagrant** : Configuration d'un cluster K3s à deux nœuds (Server et ServerWorker) avec Vagrant
2. **K3s et applications web** : Déploiement de trois applications web simples avec Ingress dans un cluster K3s
3. **K3d et Argo CD** : Mise en place d'une intégration continue avec K3d et Argo CD

## Structure du projet

```
.
├── README.md                # Documentation générale
│
├── p1/                      # Partie 1: K3s et Vagrant
│   ├── README.md            # Documentation spécifique à la partie 1
│   ├── Vagrantfile          # Configuration Vagrant pour créer deux VMs
│   ├── install_master.sh    # Script d'installation pour le nœud maître
│   ├── install_worker.sh    # Script d'installation pour le nœud worker
│   └── p1_check.sh          # Script de vérification
│
├── p2/                      # Partie 2: K3s et trois applications web
│   ├── README.md            # Documentation spécifique à la partie 2
│   ├── Vagrantfile          # Configuration Vagrant pour créer une VM
│   ├── k3s_setup/           # Répertoire contenant les configurations Kubernetes
│   │   ├── app1.yaml        # Configuration de la première application
│   │   ├── app2.yaml        # Configuration de la deuxième application (3 réplicas)
│   │   ├── app3.yaml        # Configuration de la troisième application
│   │   └── ingress.yaml     # Configuration de l'Ingress
│   └── p2_check.sh          # Script de vérification
│
└── p3/                      # Partie 3: K3d et Argo CD
    ├── README.md            # Documentation spécifique à la partie 3
    ├── Makefile             # Automatisation des opérations
    ├── scripts/             # Scripts d'installation et de configuration
    │   └── install.sh       # Script d'installation principal
    ├── confs/               # Fichiers de configuration
    │   └── app.yaml         # Configuration de l'application Argo CD
    └── p3_check.sh          # Script de vérification
```

## Prérequis

Pour exécuter ce projet, vous aurez besoin des éléments suivants :

- VirtualBox 6.1 ou supérieur
- Vagrant 2.2 ou supérieur
- Au moins 2 Go de RAM disponible
- Au moins 10 Go d'espace disque libre
- Une connexion Internet (pour télécharger les images et packages nécessaires)

## Concepts clés

### Kubernetes et K3s

Kubernetes est une plateforme d'orchestration de conteneurs qui permet de gérer des applications conteneurisées à grande échelle. K3s est une distribution légère de Kubernetes, développée par Rancher, qui nécessite moins de ressources tout en conservant la plupart des fonctionnalités.

### Vagrant

Vagrant est un outil qui permet de créer et de configurer des environnements de développement virtualisés. Il automatise la création de machines virtuelles et leur configuration via des scripts, facilitant ainsi la mise en place d'environnements reproductibles.

### K3d

K3d est un wrapper qui permet d'exécuter K3s dans des conteneurs Docker. Cette approche simplifie la création et la destruction de clusters Kubernetes pour les environnements de développement et de test.

### Argo CD

Argo CD est un outil GitOps pour Kubernetes qui synchronise automatiquement l'état d'un cluster avec une configuration déclarative stockée dans un dépôt Git. Cette approche permet une intégration et un déploiement continus basés sur Git comme source unique de vérité.

## Instructions générales

Chaque partie du projet dispose de son propre README avec des instructions détaillées. Pour commencer :

1. Clonez ce dépôt
2. Naviguez vers le dossier de la partie que vous souhaitez exécuter (p1, p2 ou p3)
3. Suivez les instructions du README correspondant
