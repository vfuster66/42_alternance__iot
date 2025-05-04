# Partie 1 : K3s et Vagrant

Cette partie consiste à créer et configurer un cluster K3s à deux nœuds à l'aide de Vagrant.

## Objectifs

- Créer deux machines virtuelles à l'aide de Vagrant
- Installer K3s en mode serveur sur la première machine et en mode agent sur la seconde
- Configurer les machines avec les bonnes adresses IP et noms d'hôtes
- Vérifier que les deux machines appartiennent au même cluster K3s

## Définitions des concepts clés

### Vagrant

Vagrant est un outil qui permet de créer et de gérer des environnements de machines virtuelles de manière automatisée. Il utilise des fichiers de configuration (Vagrantfile) pour définir les spécifications des machines et automatise leur provisionnement.

### K3s

K3s est une distribution légère de Kubernetes, développée par Rancher. Elle est conçue pour être moins gourmande en ressources tout en conservant la plupart des fonctionnalités de Kubernetes.

- **Mode Server** : Le nœud maître qui gère le cluster et exécute les composants de contrôle de Kubernetes
- **Mode Agent** : Un nœud worker qui exécute les charges de travail mais ne participe pas à la gestion du cluster

## Infrastructure déployée

Le Vagrantfile configure deux machines virtuelles :

1. **vfusterS** (Server)
   - IP : 192.168.56.110
   - Rôle : Serveur K3s (contrôleur)
   - Ressources : 1 CPU, 1024 MB RAM
   - OS : Debian 12

2. **vfusterSW** (ServerWorker)
   - IP : 192.168.56.111
   - Rôle : Agent K3s (worker)
   - Ressources : 1 CPU, 1024 MB RAM
   - OS : Debian 12

## Installation et démarrage

Pour démarrer les machines virtuelles :

```bash
# Se placer dans le dossier p1
cd p1

# Lancer les machines virtuelles
vagrant up
```

Le processus d'installation peut prendre quelques minutes car il inclut :
- Téléchargement de l'image Debian 12 (si nécessaire)
- Création des machines virtuelles
- Installation de K3s sur les deux machines
- Configuration du réseau et des noms d'hôtes

## Fonctionnement des scripts d'installation

### Script du Serveur (install_master.sh)

Ce script est exécuté sur la machine vfusterS et effectue les opérations suivantes :
1. Met à jour le système et installe les dépendances réseau nécessaires
2. Installe K3s en mode serveur avec le nom de nœud et l'IP spécifiés
3. Sauvegarde le token d'authentification dans un fichier partagé pour que le worker puisse rejoindre le cluster

### Script du Worker (install_worker.sh)

Ce script est exécuté sur la machine vfusterSW et effectue les opérations suivantes :
1. Met à jour le système et installe les dépendances réseau nécessaires
2. Attend que le token d'authentification soit disponible dans le dossier partagé
3. Récupère le token et installe K3s en mode agent, en se connectant au serveur à l'adresse 192.168.56.110

## Vérification du fonctionnement

Pour vérifier que tout fonctionne correctement, vous pouvez utiliser le script de vérification inclus :

```bash
./p1_check.sh
```

Ce script vérifie :
- Que les deux machines sont en cours d'exécution
- Que les adresses IP sont correctement configurées
- Que les noms d'hôte sont correctement définis
- Que les deux nœuds font partie du même cluster K3s

### Vérification manuelle

Si vous préférez vérifier manuellement, vous pouvez vous connecter aux machines virtuelles et exécuter des commandes.

#### Connexion aux machines

```bash
# Connexion à la machine Server
vagrant ssh vfusterS

# Connexion à la machine ServerWorker
vagrant ssh vfusterSW
```

#### Vérification de la configuration réseau

Sur chaque machine, vérifiez que l'interface eth1 a la bonne adresse IP :

```bash
# Sur la machine Server
ip -4 addr show eth1 | grep inet
# Doit afficher l'adresse IP 192.168.56.110

# Sur la machine ServerWorker
ip -4 addr show eth1 | grep inet
# Doit afficher l'adresse IP 192.168.56.111
```

#### Vérification du nom d'hôte

```bash
hostname
# Doit afficher "vfusterS" sur le serveur et "vfusterSW" sur le worker
```

#### Vérification du cluster K3s

Sur la machine Server, vérifiez que les deux nœuds font partie du même cluster :

```bash
sudo k3s kubectl get nodes -o wide
```

Vous devriez voir les deux nœuds (vfusterS et vfusterSW) listés avec le statut "Ready".

## Commandes utiles

```bash
# Arrêter les machines virtuelles
vagrant halt

# Redémarrer les machines virtuelles
vagrant reload

# Supprimer les machines virtuelles
vagrant destroy

# Recréer une machine spécifique
vagrant up vfusterS

# Vérifier l'état des machines
vagrant status
```
