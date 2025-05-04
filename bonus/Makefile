# Makefile pour le bonus du projet Inception-of-Things
# Intégration GitLab avec ArgoCD

# Variables
NAMESPACE=gitlab
APP_NAME=app-gitlab
PORT_GITLAB=8929
PORT_ARGOCD=8080

# Cibles principales
.PHONY: all clean install configure prepare-repo setup-argocd test help access-gitlab access-argocd

all: install

# Installation de GitLab
install:
	@echo "📦 Installation de GitLab dans le namespace $(NAMESPACE)..."
	@./scripts/install_gitlab_minimal.sh

# Configuration de GitLab et récupération du mot de passe
configure:
	@echo "🔧 Configuration de GitLab..."
	@./scripts/configure_gitlab.sh

# Accès à GitLab via port-forward
launch:
	@echo "🔗 Accès à GitLab via port-forward..."
	@echo "📝 URL: http://localhost:$(PORT_GITLAB)"
	@echo "👤 Utilisateur: root"
	@echo "🔑 Mot de passe: (fourni par make configure)"
	@echo "⚠️ Appuyez sur Ctrl+C pour quitter"
	@kubectl port-forward -n $(NAMESPACE) svc/gitlab $(PORT_GITLAB):80

# Accès à ArgoCD via port-forward
access-argocd:
	@echo "🔗 Accès à ArgoCD via port-forward..."
	@echo "📝 URL: http://localhost:$(PORT_ARGOCD)"
	@echo "⚠️ Appuyez sur Ctrl+C pour quitter"
	@kubectl port-forward -n argocd svc/argocd-server $(PORT_ARGOCD):443

# Préparation du dépôt Git
prepare-repo:
	@echo "🗂️ Préparation du dépôt Git pour ArgoCD..."
	@./scripts/prepare_git_repo.sh

# Configuration d'ArgoCD avec GitLab
setup-argocd:
	@echo "🔄 Configuration d'ArgoCD avec GitLab..."
	@./scripts/setup_argocd_gitlab.sh

# Test du déploiement et mise à jour
test:
	@echo "🧪 Test du déploiement et du processus de mise à jour..."
	@echo "Pour mettre à jour l'application de v1 à v2:"
	@echo "1. Allez dans votre dépôt Git"
	@echo "2. Modifiez l'image: sed -i 's/wil42\\/playground:v1/wil42\\/playground:v2/g' kubernetes/deployment.yaml"
	@echo "3. Commitez et poussez les changements"
	@echo "4. Vérifiez la synchronisation dans ArgoCD"
	@echo "Pour accéder à ArgoCD, utilisez: make access-argocd"

# Vérifier l'état de GitLab
check-gitlab:
	@echo "🔍 Vérification de l'état de GitLab..."
	@kubectl -n gitlab get pods
	@kubectl -n gitlab logs deployment/gitlab --tail=20
	@echo "👉 Pour vérifier l'initialisation complète, cherchez 'gitlab Reconfigured!' dans les logs"
	@echo "Pour voir les logs complets: kubectl -n gitlab logs deployment/gitlab -f"

# Nettoyage
clean:
	@echo "🧹 Nettoyage du bonus..."
	@kubectl delete ns $(NAMESPACE) --grace-period=0 --force 2>/dev/null || true
	@echo "✅ Nettoyage terminé."

# Afficher l'aide
help:
	@echo "📚 Aide du Makefile pour le bonus IoT:"
	@echo "  make               - Installation de GitLab"
	@echo "  make install       - Installation de GitLab"
	@echo "  make configure     - Configuration de GitLab et récupération du mot de passe"
	@echo "  make launch - Accéder à GitLab via port-forward"
	@echo "  make access-argocd - Accéder à ArgoCD via port-forward"
	@echo "  make prepare-repo  - Préparation du dépôt Git pour ArgoCD"
	@echo "  make setup-argocd  - Configuration d'ArgoCD avec GitLab"
	@echo "  make test          - Test du déploiement et du processus de mise à jour"
	@echo "  make clean         - Nettoyage du bonus"
	@echo "  make help          - Afficher cette aide"