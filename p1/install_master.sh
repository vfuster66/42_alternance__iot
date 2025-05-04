#!/bin/bash

# Update + install réseau
sudo apt update && sudo apt install -y curl iptables iproute2 conntrack

# Install K3s en mode serveur (avec plus de tentatives et meilleure gestion d'erreur)
echo "Installation de K3s..."
for i in {1..3}; do
  echo "Tentative $i d'installation de K3s..."
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-name vfusterS --node-ip 192.168.56.110" sh - && break
  echo "Échec de l'installation, nouvelle tentative dans 10 secondes..."
  sleep 10
done

# Vérifier si K3s est bien installé
if ! command -v k3s &> /dev/null; then
  echo "ERREUR: K3s n'a pas pu être installé correctement."
  exit 1
fi

# attendre que K3s démarre
echo "Attente du démarrage de K3s..."
sleep 15

# afficher les nodes
echo "Affichage des nœuds K3s:"
sudo k3s kubectl get nodes -o wide || echo "Erreur lors de l'affichage des nœuds"

# sauvegarder le token pour le worker
echo "Sauvegarde du token K3s..."
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/k3s_token.txt || 
  (echo "Erreur lors de la récupération du token. Réessai dans 10 secondes..."; sleep 10; 
   sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/k3s_token.txt)

# Vérifier que le token a bien été sauvegardé
if [ ! -s /vagrant/k3s_token.txt ]; then
  echo "ERREUR: Impossible de sauvegarder le token K3s."
  exit 1
fi

echo "Installation de K3s terminée avec succès!"