#!/bin/bash

set -e

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m' # No Color

ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

### 1. Installer Docker si nécessaire et s'assurer qu'il est actif ###

if ! command -v docker &> /dev/null; then
    echo "Installation de Docker..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/debian bookworm stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    newgrp docker
    ok "Docker installé"
else
    ok "Docker déjà installé"
fi

if ! docker info &> /dev/null; then
    echo "[INFO] Démarrage du daemon Docker..."
    sudo systemctl start docker || sudo service docker start
fi

if docker info &> /dev/null; then
    ok "Docker est actif"
else
    echo "[ERREUR] Docker est installé mais ne peut pas être lancé."
    exit 1
fi

### 2. Installer k3d si nécessaire ###

if ! command -v k3d &> /dev/null; then
    echo "Installation de k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    ok "k3d installé"
else
    ok "k3d déjà installé"
fi

### 3. Installer kubectl si nécessaire ###

if ! command -v kubectl &> /dev/null; then
    echo "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    ok "kubectl installé"
else
    ok "kubectl déjà installé"
fi

### 4. Créer le cluster k3d si non existant ###

if ! k3d cluster list | grep -q iot-cluster; then
    echo "Création du cluster k3d..."
    k3d cluster create iot-cluster --api-port 6550 -p "80:80@loadbalancer" --agents 1
    ok "Cluster k3d créé"
else
    ok "Cluster k3d déjà existant"
fi

### 5. Installer Argo CD ###

kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
ok "Argo CD déployé dans namespace argocd"

### 6. Déployer l'application Argo CD ###

kubectl create namespace dev || true

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

kubectl apply -f "$PROJECT_ROOT/confs/app.yaml"
ok "Application Argo CD créée pour déployer dans dev"

### 7. Attente du secret d'admin ArgoCD ###
# Modification à apporter au script install.sh (partie attente du secret)
echo -e "\n[INFO] Attente du mot de passe Argo CD (argocd-initial-admin-secret)..."
for i in {1..30}; do  # Augmenter à 30 tentatives
    if kubectl -n argocd get secret argocd-initial-admin-secret &>/dev/null; then
        PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        echo "Password initial: $PASSWORD"
        break
    fi
    echo "Attente des pods ArgoCD... ($i/30)"
    kubectl -n argocd get pods
    sleep 5  # Attendre 5 secondes entre chaque tentative
done

### 8. Informations finales ###
echo -e "\nArgo CD accessible via port-forward :"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Ensuite accès via https://localhost:8080"
echo "Default login: admin"
echo "Password initial :"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Lancer le port-forward Argo CD en arrière-plan
echo -e "\n[INFO] Lancement du port-forward Argo CD (https://localhost:8080)..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &

# Lancer le port-forward playground en arrière-plan
echo -e "[INFO] Lancement du port-forward playground (http://localhost:8888)..."
kubectl port-forward svc/playground -n dev 8888:8888 >/dev/null 2>&1 &

ok "Port-forward Argo CD & App playground actifs en arrière-plan"
