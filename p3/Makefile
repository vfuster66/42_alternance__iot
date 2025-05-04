# Variables
SCRIPT=./scripts/install.sh
CHECK=./p3_check.sh

.PHONY: all install check p3-check test sync sync-now clean port-forward stop-forward \
       info logs password argo-status get-version help

# Commande par défaut
all: install

# Installation complète de l'environnement
install:
	@echo "[INFO] Installation complète (Docker, k3d, ArgoCD, app)"
	@bash $(SCRIPT)

# Vérification de l'état de l'environnement
check:
	@echo "[INFO] Vérification de l'environnement (cluster, ArgoCD, app)"
	@bash $(CHECK)

# Alias pour check
p3-check: check

# Forcer la synchronisation automatique
sync:
	@echo "[INFO] Forçage de la synchronisation automatique de l'application Argo CD"
	@kubectl -n argocd patch application playground \
		-p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}' \
		--type=merge

# Forcer une synchronisation immédiate
sync-now:
	@echo "[INFO] Synchronisation immédiate de l'application Argo CD"
	@kubectl -n argocd apply -f confs/app.yaml

# Configurer les redirections de ports
port-forward:
	@echo "[INFO] Port-forward ArgoCD sur https://localhost:8080"
	@kubectl port-forward svc/argocd-server -n argocd 8080:443 &
	@echo "[INFO] Port-forward playground sur http://localhost:8888"
	@kubectl port-forward svc/playground -n dev 8888:8888 &

# Arrêter les redirections de ports
stop-forward:
	@echo "[INFO] Arrêt des port-forwards"
	@pkill -f "kubectl port-forward" || true

# Supprimer le cluster et nettoyer
clean:
	@echo "[INFO] Suppression du cluster k3d et nettoyage"
	@k3d cluster delete iot-cluster 2>/dev/null || true
	@echo "[INFO] Cluster supprimé"

# Tester l'application
test: check
	@echo "[INFO] Test fonctionnel de l'application"
	@curl -s http://localhost:8888 | grep -q '"status":"ok"' && \
		echo "[OK] Application répond correctement sur port 8888" || \
		echo "[KO] Aucune réponse de l'application (localhost:8888)"

# Afficher des informations sur l'environnement
info:
	@echo "[INFO] === État du cluster ==="
	@kubectl cluster-info
	@echo "\n[INFO] === Namespaces ==="
	@kubectl get ns
	@echo "\n[INFO] === Pods dans argocd ==="
	@kubectl get pods -n argocd
	@echo "\n[INFO] === Pods dans dev ==="
	@kubectl get pods -n dev
	@echo "\n[INFO] === Application Argo CD ==="
	@kubectl get application -n argocd playground -o wide

# Afficher les logs des pods
logs:
	@echo "[INFO] === Logs des pods dans dev ==="
	@POD_NAME=$$(kubectl get pods -n dev -l app=playground -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -n "$$POD_NAME" ]; then \
		kubectl logs -n dev $$POD_NAME; \
	else \
		echo "[ERREUR] Aucun pod trouvé dans le namespace dev"; \
	fi

# Récupérer le mot de passe Argo CD
password:
	@echo "[INFO] Récupération du mot de passe Argo CD"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || \
		echo "[ERREUR] Secret non trouvé. ArgoCD est-il correctement installé ?"

# Afficher l'état de l'application dans Argo CD
argo-status:
	@echo "[INFO] État de l'application dans Argo CD"
	@kubectl get application -n argocd playground -o jsonpath='{.status.sync.status}{" / "}{.status.health.status}{"\n"}'

# Obtenir la version actuelle de l'application
get-version:
	@echo "[INFO] Version actuelle de l'application"
	@curl -s http://localhost:8888 | grep -o '"message": "v[1-2]"' || echo "[ERREUR] Impossible d'obtenir la version"

# Afficher l'aide
help:
	@echo "Makefile pour la partie 3 : K3d et Argo CD"
	@echo ""
	@echo "Commandes principales :"
	@echo "  make install       - Installer l'environnement complet"
	@echo "  make check         - Vérifier l'état de l'installation"
	@echo "  make test          - Tester l'application"
	@echo "  make clean         - Supprimer le cluster et nettoyer"
	@echo ""
	@echo "Gestion des ports :"
	@echo "  make port-forward  - Configurer les redirections de ports"
	@echo "  make stop-forward  - Arrêter les redirections de ports"
	@echo ""
	@echo "Argo CD :"
	@echo "  make sync          - Configurer la synchronisation automatique"
	@echo "  make sync-now      - Forcer une synchronisation immédiate"
	@echo "  make password      - Afficher le mot de passe Argo CD"
	@echo "  make argo-status   - Afficher l'état de l'application"
	@echo ""
	@echo "Informations :"
	@echo "  make info          - Afficher des informations sur l'environnement"
	@echo "  make logs          - Afficher les logs de l'application"
	@echo "  make get-version   - Afficher la version actuelle de l'application"
	@echo "  make help          - Afficher cette aide"