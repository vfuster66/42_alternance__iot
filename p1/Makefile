# Makefile pour la partie 1 : K3s et Vagrant

.PHONY: all up start stop restart destroy status check ssh-server ssh-worker clean

# Variables
VM_SERVER = vfusterS
VM_WORKER = vfusterSW
CHECK_SCRIPT = ./p1_check.sh

all: up

# Créer et provisionner les deux machines virtuelles
up:
	@echo "[INFO] Création et démarrage des machines virtuelles..."
	vagrant up
	@echo "[INFO] Les machines sont prêtes. Exécutez 'make check' pour vérifier l'installation."

copy-k3s:
	@echo "[INFO] Copie du binaire K3s vers le dossier partagé..."
	@vagrant ssh vfusterS -c "sudo cp /usr/local/bin/k3s /vagrant/"
	@echo "[INFO] Binaire K3s copié avec succès"

# Démarrer les machines virtuelles (sans provisionnement)
start:
	@echo "[INFO] Démarrage des machines virtuelles..."
	vagrant up --no-provision

# Arrêter les machines virtuelles
stop:
	@echo "[INFO] Arrêt des machines virtuelles..."
	vagrant halt

# Redémarrer les machines virtuelles
restart:
	@echo "[INFO] Redémarrage des machines virtuelles..."
	vagrant reload

# Ajouter cette cible au Makefile
retry:
	@echo "[INFO] Réessai d'installation après échec..."
	@vagrant provision

# Détruire les machines virtuelles
destroy:
	@echo "[INFO] Suppression des machines virtuelles..."
	vagrant destroy -f
	@echo "[INFO] Les machines ont été supprimées."

# Vérifier l'état des machines virtuelles
status:
	@echo "[INFO] État des machines virtuelles :"
	vagrant status

# Exécuter les tests de vérification
check:
	@echo "[INFO] Vérification de l'installation..."
	@if [ -x $(CHECK_SCRIPT) ]; then \
		$(CHECK_SCRIPT); \
	else \
		chmod +x $(CHECK_SCRIPT) && $(CHECK_SCRIPT); \
	fi

# Se connecter en SSH au serveur
ssh-server:
	@echo "[INFO] Connexion SSH au serveur $(VM_SERVER)..."
	vagrant ssh $(VM_SERVER)

# Se connecter en SSH au worker
ssh-worker:
	@echo "[INFO] Connexion SSH au worker $(VM_WORKER)..."
	vagrant ssh $(VM_WORKER)

# Vérification manuelle des nodes K3s
nodes:
	@echo "[INFO] Liste des nœuds K3s :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get nodes -o wide"

# Vérification manuelle des pods K3s
pods:
	@echo "[INFO] Liste des pods K3s :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get pods -A"

# Nettoyer tous les fichiers générés
clean: destroy
	@echo "[INFO] Nettoyage des fichiers générés..."
	@rm -f k3s_token.txt
	@rm -rf .vagrant
	@echo "[INFO] Nettoyage terminé."