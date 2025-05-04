#!/bin/bash

# Update + install réseau
sudo apt update && sudo apt install -y curl iptables iproute2 conntrack

# Attendre que le token soit disponible avec un délai maximum
MAX_WAIT=120  # 2 minutes
START_TIME=$(date +%s)
echo "Attente du token K3s..."

while [ ! -f /vagrant/k3s_token.txt ] || [ ! -s /vagrant/k3s_token.txt ]; do
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
  
  if [ $ELAPSED_TIME -gt $MAX_WAIT ]; then
    echo "ERREUR: Le token K3s n'est pas disponible après $MAX_WAIT secondes."
    exit 1
  fi
  
  echo "Token non disponible, nouvelle vérification dans 5 secondes..."
  sleep 5
done

TOKEN=$(cat /vagrant/k3s_token.txt)
echo "Token K3s récupéré avec succès!"

# Vérifier si le binaire K3s existe dans /vagrant
if [ -f /vagrant/k3s ]; then
  echo "Utilisation du binaire K3s existant dans /vagrant..."
else
  echo "Copie du binaire K3s du serveur..."
  # La machine serveur doit avoir k3s installé à ce stade
  scp -o StrictHostKeyChecking=no vagrant@192.168.56.110:/usr/local/bin/k3s /vagrant/k3s || {
    echo "Impossible de copier le binaire K3s du serveur. Installation manuelle..."
    # Fallback: essayer l'installation normale
    curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=${TOKEN} INSTALL_K3S_EXEC="--node-name vfusterSW --node-ip 192.168.56.111" sh -
    if [ $? -ne 0 ]; then
      echo "ERREUR: Installation de K3s agent échouée."
      exit 1
    fi
    echo "Installation de K3s agent terminée avec succès!"
    exit 0
  }
fi

# Installation manuelle de K3s en mode agent
echo "Installation manuelle de K3s agent..."
sudo mkdir -p /var/lib/rancher/k3s/agent
sudo cp /vagrant/k3s /usr/local/bin/
sudo chmod +x /usr/local/bin/k3s

# Créer le fichier de configuration K3s
sudo mkdir -p /etc/rancher/k3s
cat > /tmp/config.yaml << EOF
server: https://192.168.56.110:6443
token: ${TOKEN}
node-name: vfusterSW
node-ip: 192.168.56.111
EOF
sudo mv /tmp/config.yaml /etc/rancher/k3s/config.yaml

# Créer le service systemd
cat > /tmp/k3s-agent.service << EOF
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
After=network-online.target

[Service]
Type=exec
ExecStart=/usr/local/bin/k3s agent
KillMode=process
Delegate=yes
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
sudo mv /tmp/k3s-agent.service /etc/systemd/system/k3s-agent.service

# Démarrer le service
sudo systemctl daemon-reload
sudo systemctl enable k3s-agent
sudo systemctl start k3s-agent

# Vérifier si le service est démarré
if sudo systemctl is-active k3s-agent > /dev/null; then
  echo "Installation de K3s agent terminée avec succès!"
else
  echo "ERREUR: K3s agent n'a pas démarré correctement."
  exit 1
fi