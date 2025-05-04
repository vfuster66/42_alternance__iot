# Partie 2 : K3s et trois applications web simples

Cette partie met en œuvre une machine virtuelle unique avec K3s et déploie trois applications web accessibles via un service Ingress.

## Objectifs

- Créer une machine virtuelle avec Vagrant
- Installer K3s en mode serveur
- Déployer trois applications web distinctes
- Configurer un Ingress pour acheminer le trafic en fonction du nom d'hôte
- S'assurer que la deuxième application est déployée avec 3 réplicas

## Définitions des concepts clés

### Ingress

Un Ingress est une ressource Kubernetes qui gère l'accès externe aux services dans un cluster, généralement via HTTP. Il fournit des fonctionnalités de routage basées sur les règles, permettant de diriger le trafic vers différents services en fonction de l'URL ou du nom d'hôte.

### Réplicas

Les réplicas sont des copies identiques d'un pod qui s'exécutent en parallèle pour assurer la haute disponibilité, la tolérance aux pannes et la répartition de charge. Le nombre de réplicas définit combien d'instances d'une application doivent être maintenues en fonctionnement.

## Infrastructure déployée

Le Vagrantfile configure une machine virtuelle unique :

- **vfusterS**
  - IP : 192.168.56.110
  - Ressources : 1 CPU, 1024 MB RAM
  - Système d'exploitation : Debian 12

Sur cette machine, trois applications web sont déployées :

1. **App1** : Accessible via le nom d'hôte "app1.com" (1 replica)
2. **App2** : Accessible via le nom d'hôte "app2.com" (3 replicas)
3. **App3** : Application par défaut accessible pour tout autre nom d'hôte (1 replica)

Toutes les applications utilisent l'image Docker `paulbouwer/hello-kubernetes:1.10.1` avec des messages personnalisés pour les différencier.

## Installation et démarrage

Pour démarrer la machine virtuelle et déployer les applications :

```bash
# Se placer dans le dossier p2
cd p2

# Lancer la machine virtuelle
vagrant up
```

Le processus d'installation inclut :
- Création de la machine virtuelle
- Installation de K3s
- Déploiement de l'Ingress
- Déploiement des trois applications web

## Détail des fichiers de configuration

### app1.yaml

Définit un déploiement avec 1 replica de l'application 1 et un service associé. L'application affiche le message "Hello from App1".

### app2.yaml

Définit un déploiement avec 3 replicas de l'application 2 et un service associé. L'application affiche le message "Hello from App2".

### app3.yaml

Définit un déploiement avec 1 replica de l'application 3 et un service associé. L'application affiche le message "Hello from App3".

### ingress.yaml

Configure les règles de routage pour diriger le trafic vers :
- app1 lorsque l'en-tête Host est "app1.com"
- app2 lorsque l'en-tête Host est "app2.com"
- app3 pour tout autre Host (règle par défaut)

## Vérification du fonctionnement

Pour vérifier que tout fonctionne correctement, vous pouvez utiliser le script de vérification inclus :

```bash
./p2_check.sh
```

Ce script vérifie :
- Que la machine virtuelle est en cours d'exécution avec la bonne IP
- Que le nom d'hôte est correctement configuré
- Que K3s est installé et fonctionne
- Que les trois applications sont déployées
- Que l'application 2 a bien 3 replicas
- Que l'Ingress est configuré correctement
- Que le routage basé sur l'hôte fonctionne pour toutes les applications

### Vérification manuelle

Si vous préférez vérifier manuellement, vous pouvez vous connecter à la machine virtuelle et exécuter des commandes.

#### Connexion à la machine

```bash
vagrant ssh vfusterS
```

#### Vérification de la configuration réseau

```bash
# Vérifier l'interface eth1
ip a show eth1 | grep inet
# Doit afficher l'adresse IP 192.168.56.110

# Vérifier le nom d'hôte
hostname
# Doit afficher "vfusterS"
```

#### Vérification des déploiements Kubernetes

```bash
# Vérifier le nœud
sudo k3s kubectl get nodes -o wide
# Doit afficher le nœud "vfusterS" avec le statut "Ready"

# Vérifier les déploiements
sudo k3s kubectl get deployments
# Doit afficher les 3 déploiements, avec app2-deployment ayant 3 replicas

# Vérifier les pods
sudo k3s kubectl get pods
# Doit afficher 5 pods (1 pour app1, 3 pour app2, 1 pour app3)

# Vérifier l'Ingress
sudo k3s kubectl get ingress
# Doit afficher l'Ingress app-ingress
```

#### Test des applications

Pour tester les applications en fonction des noms d'hôtes, utilisez curl avec l'option `-H` pour spécifier l'en-tête Host :

```bash
# Tester app1
curl -H "Host: app1.com" http://192.168.56.110
# Doit afficher une page HTML contenant "Hello from App1"

# Tester app2
curl -H "Host: app2.com" http://192.168.56.110
# Doit afficher une page HTML contenant "Hello from App2"

# Tester app3 (par défaut)
curl http://192.168.56.110
# ou
curl -H "Host: quelquechose.com" http://192.168.56.110
# Doit afficher une page HTML contenant "Hello from App3"
```

## Commandes utiles

```bash
# Arrêter la machine virtuelle
vagrant halt

# Redémarrer la machine virtuelle
vagrant reload

# Supprimer la machine virtuelle
vagrant destroy

# Vérifier l'état de la machine virtuelle
vagrant status

# Voir les détails de l'Ingress
sudo k3s kubectl describe ingress app-ingress
```

## Dépannage

Si vous rencontrez des problèmes lors de l'installation ou du test des applications, voici quelques pistes pour les résoudre :

### K3s ne démarre pas

Vérifiez les journaux de K3s :

```bash
sudo journalctl -u k3s
```

### Les applications ne sont pas accessibles

Vérifiez que les pods sont en cours d'exécution :

```bash
sudo k3s kubectl get pods
```

Si les pods sont en état "Pending" ou "CrashLoopBackOff", consultez leurs journaux :

```bash
sudo k3s kubectl describe pod <nom-du-pod>
sudo k3s kubectl logs <nom-du-pod>
```

### L'Ingress ne fonctionne pas correctement

Vérifiez les détails de la configuration de l'Ingress :

```bash
sudo k3s kubectl describe ingress app-ingress
```

Vérifiez que le contrôleur Ingress est en cours d'exécution :

```bash
sudo k3s kubectl get pods -n kube-system | grep ingress
```