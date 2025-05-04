# Makefile pour la partie 2 : K3s et trois applications web

.PHONY: all up start stop restart destroy status check ssh clean test-app1 test-app2 test-app3 test-all ingress pods

# Variables
VM_SERVER = vfusterS
CHECK_SCRIPT = ./p2_check.sh
SERVER_IP = 192.168.56.110

all: up

# Créer et provisionner la machine virtuelle
up:
	@echo "[INFO] Création et démarrage de la machine virtuelle..."
	vagrant up
	@echo "[INFO] La machine est prête. Exécutez 'make check' pour vérifier l'installation."

# Démarrer la machine virtuelle (sans provisionnement)
start:
	@echo "[INFO] Démarrage de la machine virtuelle..."
	vagrant up --no-provision

# Arrêter la machine virtuelle
stop:
	@echo "[INFO] Arrêt de la machine virtuelle..."
	vagrant halt

# Redémarrer la machine virtuelle
restart:
	@echo "[INFO] Redémarrage de la machine virtuelle..."
	vagrant reload

# Détruire la machine virtuelle
destroy:
	@echo "[INFO] Suppression de la machine virtuelle..."
	vagrant destroy -f
	@echo "[INFO] La machine a été supprimée."

# Vérifier l'état de la machine virtuelle
status:
	@echo "[INFO] État de la machine virtuelle :"
	vagrant status

# Exécuter les tests de vérification
check:
	@echo "[INFO] Vérification de l'installation..."
	@if [ -x $(CHECK_SCRIPT) ]; then \
		$(CHECK_SCRIPT); \
	else \
		chmod +x $(CHECK_SCRIPT) && $(CHECK_SCRIPT); \
	fi

# Se connecter en SSH à la machine
ssh:
	@echo "[INFO] Connexion SSH à la machine $(VM_SERVER)..."
	vagrant ssh $(VM_SERVER)

# Tester l'application 1
test-app1:
	@echo "[INFO] Test de l'application 1 (app1.com)..."
	@curl -s -H "Host: app1.com" http://$(SERVER_IP) | grep -q "Hello from App1" && \
		echo "[OK] Application 1 accessible via app1.com" || \
		echo "[KO] Application 1 non accessible"

# Tester l'application 2
test-app2:
	@echo "[INFO] Test de l'application 2 (app2.com)..."
	@curl -s -H "Host: app2.com" http://$(SERVER_IP) | grep -q "Hello from App2" && \
		echo "[OK] Application 2 accessible via app2.com" || \
		echo "[KO] Application 2 non accessible"

# Tester l'application 3 (par défaut)
test-app3:
	@echo "[INFO] Test de l'application 3 (par défaut)..."
	@curl -s http://$(SERVER_IP) | grep -q "Hello from App3" && \
		echo "[OK] Application 3 accessible par défaut" || \
		echo "[KO] Application 3 non accessible"

# Tester toutes les applications
test-all: test-app1 test-app2 test-app3

# Afficher la configuration Ingress
ingress:
	@echo "[INFO] Configuration Ingress :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get ingress -o wide"
	@echo "[INFO] Détails de l'Ingress :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl describe ingress app-ingress"

# Afficher les pods en cours d'exécution
pods:
	@echo "[INFO] Pods en cours d'exécution :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get pods -o wide"
	@echo "[INFO] Déploiements :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get deployments"

# Afficher tous les pods dans tous les namespaces
all-pods:
	@echo "[INFO] Tous les pods dans tous les namespaces :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get pods -A"

# Afficher tous les services
all-services:
	@echo "[INFO] Tous les services :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get services -A"

# Tester l'application 1 avec affichage complet
test-app1-full:
	@echo "[INFO] Test de l'application 1 (app1.com) avec affichage complet :"
	@echo "\n=== Requête curl -H \"Host: app1.com\" http://$(SERVER_IP) ==="
	@curl -s -H "Host: app1.com" http://$(SERVER_IP) || echo "Erreur: Pas de réponse"
	@echo "\n=== Fin de la requête ==="

# Tester l'application 2 avec affichage complet
test-app2-full:
	@echo "[INFO] Test de l'application 2 (app2.com) avec affichage complet :"
	@echo "\n=== Requête curl -H \"Host: app2.com\" http://$(SERVER_IP) ==="
	@curl -s -H "Host: app2.com" http://$(SERVER_IP) || echo "Erreur: Pas de réponse"
	@echo "\n=== Fin de la requête ==="

# Tester l'application 3 (par défaut) avec affichage complet
test-app3-full:
	@echo "[INFO] Test de l'application 3 (par défaut) avec affichage complet :"
	@echo "\n=== Requête curl http://$(SERVER_IP) ==="
	@curl -s http://$(SERVER_IP) || echo "Erreur: Pas de réponse"
	@echo "\n=== Fin de la requête ==="

# Tester toutes les applications avec affichage complet
test-all-full: test-app1-full test-app2-full test-app3-full

# Vérification complète pour la soutenance
demo:
	@echo "\n[INFO] === DÉMONSTRATION POUR LA SOUTENANCE ==="
	@echo "\n[INFO] 1. État de la machine virtuelle :"
	@vagrant status
	
	@echo "\n[INFO] 2. Configuration réseau :"
	@vagrant ssh $(VM_SERVER) -c "ip a show eth1 | grep 'inet '"
	@vagrant ssh $(VM_SERVER) -c "hostname"
	
	@echo "\n[INFO] 3. État de K3s :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get nodes -o wide"
	
	@echo "\n[INFO] 4. Déploiements :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get deployments"
	
	@echo "\n[INFO] 5. Pods :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get pods -o wide"
	
	@echo "\n[INFO] 6. Services :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get services"
	
	@echo "\n[INFO] 7. Configuration Ingress :"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl get ingress -o wide"
	@vagrant ssh $(VM_SERVER) -c "sudo k3s kubectl describe ingress app-ingress"
	
	@echo "\n[INFO] 8. Test des applications :"
	@echo "\n=== App1 (curl -H \"Host: app1.com\" http://$(SERVER_IP)) ==="
	@curl -s -H "Host: app1.com" http://$(SERVER_IP)
	
	@echo "\n\n=== App2 (curl -H \"Host: app2.com\" http://$(SERVER_IP)) ==="
	@curl -s -H "Host: app2.com" http://$(SERVER_IP)
	
	@echo "\n\n=== App3 (default) (curl http://$(SERVER_IP)) ==="
	@curl -s http://$(SERVER_IP)
	
	@echo "\n\n[INFO] === FIN DE LA DÉMONSTRATION ==="

# Nettoyer tous les fichiers générés
clean: destroy
	@echo "[INFO] Nettoyage des fichiers générés..."
	@rm -rf .vagrant
	@echo "[INFO] Nettoyage terminé."