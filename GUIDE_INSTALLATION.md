🚀 Guide d'Installation Complète - TP INF 3611
📋 Vue d'ensemble
Ce guide vous accompagne pas à pas dans la mise en place complète du projet d'automatisation de création d'utilisateurs Linux.

🎯 Objectifs
✅ Créer la structure du projet
✅ Configurer Git et GitHub
✅ Préparer les fichiers de configuration
✅ Tester chaque partie
✅ Déployer sur le serveur VPS
⏱️ Temps estimé
Configuration initiale : 30 minutes
Tests et déploiement : 1-2 heures
Total : 2-3 heures
📦 ÉTAPE 1 : Préparation de l'environnement local
1.1 Vérifier les prérequis
bash
# Vérifier Git
git --version

# Vérifier Bash
bash --version

# Vérifier Ansible
ansible --version

# Vérifier Terraform
terraform version

# Si manquant, installer :
sudo apt update
sudo apt install -y git ansible
1.2 Créer la structure du projet
bash
# Créer le répertoire principal
mkdir -p ~/TP-INF-361
cd ~/TP-INF-361

# Créer la structure
mkdir -p partie-0-ssh
mkdir -p partie-1-bash/logs
mkdir -p partie-2-ansible/templates
mkdir -p partie-3-terraform
📝 ÉTAPE 2 : Création des fichiers
2.1 Fichier principal : users.txt
bash
# Créer le fichier utilisateurs
cat > users.txt << 'EOF'
alice;P@ssw0rd123;Alice Kamga;+237698765432;alice.kamga@uy1.cm;/bin/bash
bob;Secure456!;Bob Nguema;+237677889900;bob.nguema@uy1.cm;/bin/zsh
charlie;MyP@ss789;Charlie Mbida;+237655443322;charlie.mbida@uy1.cm;/bin/bash
diane;SecureP@ss2024;Diane Fouda;+237699887766;diane.fouda@uy1.cm;/bin/fish
EOF
2.2 Partie 0 : SSH
bash
cd partie-0-ssh

# Créer le README (copier le contenu du README Partie 0)
nano README.md
2.3 Partie 1 : Script Bash
bash
cd ../partie-1-bash

# Créer le script (copier le contenu de create_users.sh)
nano create_users.sh

# Rendre exécutable
chmod +x create_users.sh

# Créer le README
nano README.md
2.4 Partie 2 : Ansible
bash
cd ../partie-2-ansible

# Créer le playbook
nano create_users.yml

# Créer l'inventaire
nano inventory.ini

# Créer le README
nano README.md
2.5 Partie 3 : Terraform
bash
cd ../partie-3-terraform

# Créer les fichiers Terraform
nano main.tf
nano variables.tf
nano outputs.tf

# Créer l'exemple de configuration
nano terraform.tfvars.example

# Créer le README
nano README.md
2.6 Fichiers racine
bash
cd ~/TP-INF-361

# Créer le README principal
nano README.md

# Créer le .gitignore
nano .gitignore
🔧 ÉTAPE 3 : Configuration Git et GitHub
3.1 Initialiser Git
bash
cd ~/TP-INF-361

# Initialiser le dépôt
git init

# Configurer Git (si pas déjà fait)
git config --global user.name "Votre Nom"
git config --global user.email "votre-email@example.com"
3.2 Créer le dépôt sur GitHub
Aller sur https://github.com
Cliquer sur "New repository"
Nom : TP-INF-361
Description : TP Administration Systèmes et Réseaux - Automatisation création utilisateurs Linux
Visibilité : Public ou Private
Ne PAS initialiser avec README, .gitignore ou licence
Cliquer sur "Create repository"
3.3 Lier le dépôt local à GitHub
bash
# Ajouter le remote
git remote add origin https://github.com/VOTRE-USERNAME/TP-INF-361.git

# Vérifier
git remote -v
3.4 Premier commit
bash
# Ajouter tous les fichiers
git add .

# Vérifier ce qui sera commité
git status

# Premier commit
git commit -m "Initial commit: Structure complète du projet TP INF-3611

- Partie 0: Configuration SSH
- Partie 1: Script Bash d'automatisation
- Partie 2: Playbook Ansible
- Partie 3: Configuration Terraform
- Documentation complète pour chaque partie"

# Pousser vers GitHub
git branch -M main
git push -u origin main
🔐 ÉTAPE 4 : Configuration du serveur VPS
4.1 Se connecter au VPS
bash
# Connexion initiale (remplacer par votre IP)
ssh root@VOTRE_IP_VPS

# OU si vous avez déjà un utilisateur
ssh user@VOTRE_IP_VPS
4.2 Sécuriser SSH (Partie 0)
⚠️ ATTENTION : Suivre EXACTEMENT la procédure de la Partie 0

bash
# Sur le serveur VPS

# 1. Sauvegarder
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 2. Créer un utilisateur admin AVANT de bloquer root
sudo adduser admin
sudo usermod -aG sudo admin

# 3. Configurer les clés SSH pour le nouvel utilisateur
# Sur votre machine locale :
ssh-keygen -t ed25519 -C "admin@vps"
ssh-copy-id admin@VOTRE_IP_VPS

# 4. Tester la connexion
ssh admin@VOTRE_IP_VPS

# 5. Modifier SSH (depuis la session admin)
sudo nano /etc/ssh/sshd_config

# Appliquer la configuration recommandée de la Partie 0

# 6. Tester la syntaxe
sudo sshd -t

# 7. Recharger (PAS redémarrer)
sudo systemctl reload sshd

# 8. Tester dans un NOUVEAU terminal
ssh -p 2222 admin@VOTRE_IP_VPS
🧪 ÉTAPE 5 : Tests des différentes parties
5.1 Test Partie 1 : Script Bash
bash
# Sur votre machine locale
cd ~/TP-INF-361/partie-1-bash

# Copier les fichiers sur le serveur
scp -P 2222 create_users.sh admin@VOTRE_IP_VPS:/tmp/
scp -P 2222 ../users.txt admin@VOTRE_IP_VPS:/tmp/

# Se connecter et exécuter
ssh -p 2222 admin@VOTRE_IP_VPS
cd /tmp
sudo bash create_users.sh students-inf-361 users.txt

# Vérifier
getent group students-inf-361
id alice
5.2 Test Partie 2 : Ansible
bash
# Sur votre machine locale
cd ~/TP-INF-361/partie-2-ansible

# Configurer l'inventaire
nano inventory.ini
# Remplacer VOTRE_IP_SERVEUR par votre vraie IP

# Configurer les variables dans le playbook
nano create_users.yml
# Configurer smtp_username, smtp_password, etc.

# Tester la connexion
ansible -i inventory.ini vps_servers -m ping

# Exécuter le playbook
ansible-playbook -i inventory.ini create_users.yml
5.3 Test Partie 3 : Terraform
bash
# Sur votre machine locale
cd ~/TP-INF-361/partie-3-terraform

# Créer la configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
# Configurer server_ip, ssh_user, etc.

# Initialiser Terraform
terraform init

# Planifier
terraform plan

# Appliquer
terraform apply
📤 ÉTAPE 6 : Finalisation et publication
6.1 Créer le fichier terraform.tfvars
bash
cd ~/TP-INF-361/partie-3-terraform

# Créer votre configuration (ne sera PAS commité grâce au .gitignore)
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
6.2 Mettre à jour la documentation
bash
cd ~/TP-INF-361

# Ajouter vos informations dans le README principal
nano README.md
# Remplacer "Votre Nom" par votre vrai nom
6.3 Commit final et push
bash
# Vérifier les modifications
git status

# Ajouter les changements
git add .

# Commit
git commit -m "Configuration complète et testée

- Script Bash testé avec succès
- Playbook Ansible fonctionnel
- Configuration Terraform validée
- Documentation à jour"

# Push vers GitHub
git push origin main
6.4 Créer un tag de version
bash
# Créer un tag
git tag -a v1.0.0 -m "Version 1.0.0 - TP INF-3611 complet et testé"

# Pousser le tag
git push origin v1.0.0
📊 ÉTAPE 7 : Vérification finale
7.1 Checklist de vérification
Sur GitHub, vérifier que vous avez :

 ✅ Tous les fichiers sont présents
 ✅ La structure des répertoires est correcte
 ✅ Le README principal est complet
 ✅ Chaque partie a son README
 ✅ Les fichiers sensibles ne sont PAS commités
 ✅ Le .gitignore fonctionne correctement
7.2 Tester le clonage
bash
# Dans un autre répertoire
cd /tmp
git clone https://github.com/VOTRE-USERNAME/TP-INF-361.git
cd TP-INF-361

# Vérifier la structure
tree -L 2

# Lire les README
cat README.md
7.3 Documentation des résultats
Créer un fichier RESULTATS.md :

bash
cd ~/TP-INF-361

cat > RESULTATS.md << 'EOF'
# Résultats des Tests - TP INF 3611

## Serveur VPS

- **IP** : VOTRE_IP
- **Port SSH** : 2222
- **OS** : Ubuntu 22.04 LTS
- **RAM** : 4 GB
- **Stockage** : 80 GB

## Partie 1 : Script Bash

✅ **Statut** : Testé avec succès

- Utilisateurs créés : 4
- Groupe créé : students-inf-361
- Quotas configurés : 15 Go par utilisateur
- Restrictions sudo : Actives

## Partie 2 : Ansible

✅ **Statut** : Testé avec succès

- Utilisateurs créés : 4
- Emails envoyés : 4/4
- Temps d'exécution : 2 min 15 sec

## Partie 3 : Terraform

✅ **Statut** : Testé avec succès

- Infrastructure provisionnée
- Script exécuté automatiquement
- Logs récupérés localement

## Captures d'écran

(Ajouter vos captures d'écran ici)
EOF

# Commiter
git add RESULTATS.md
git commit -m "Ajout des résultats des tests"
git push origin main
🎓 ÉTAPE 8 : Préparation de la soumission
8.1 Vérifier les livrables
Selon le sujet du TP, vous devez avoir :

✅ create_users.sh (Partie 1)
✅ create_users.yml (Partie 2)
✅ inventory.ini (Partie 2)
✅ users.txt (ou .csv/.yaml)
✅ Dossier Terraform avec main.tf et variables.tf
✅ Documentation globale README.md
✅ README.md dans chaque partie
8.2 Créer une archive (si demandée)
bash
cd ~/TP-INF-361

# Créer une archive
tar -czf TP-INF-361-VOTRE_NOM.tar.gz \
  --exclude='.git' \
  --exclude='*.tfstate*' \
  --exclude='.terraform' \
  --exclude='logs' \
  .

# Vérifier le contenu
tar -tzf TP-INF-361-VOTRE_NOM.tar.gz | head -20
8.3 Préparer le lien GitHub
Créer un fichier SOUMISSION.txt :

bash
cat > SOUMISSION.txt << 'EOF'
═══════════════════════════════════════════════════════════════
              TP INF 3611 - INFORMATIONS DE SOUMISSION
═══════════════════════════════════════════════════════════════

Étudiant : VOTRE NOM
Matricule : VOTRE MATRICULE
Cours : INF 3611 - Administration Systèmes et Réseaux
Date : 15 décembre 2025

DÉPÔT GITHUB
════════════
URL : https://github.com/VOTRE-USERNAME/TP-INF-361
Branche : main
Tag : v1.0.0

LIVRABLES
═════════
✅ Script Bash : partie-1-bash/create_users.sh
✅ Playbook Ansible : partie-2-ansible/create_users.yml
✅ Inventaire : partie-2-ansible/inventory.ini
✅ Fichier utilisateurs : users.txt
✅ Configuration Terraform : partie-3-terraform/
✅ Documentation : README.md + READMEs par partie

TESTS EFFECTUÉS
═══════════════
✅ Script Bash testé sur VPS
✅ Playbook Ansible exécuté avec succès
✅ Terraform déployé correctement
✅ Emails reçus par les utilisateurs
✅ Configuration SSH sécurisée

NOTES SUPPLÉMENTAIRES
══════════════════════
- Tous les mots de passe sont hachés en SHA-512
- Les quotas de 15 Go sont configurés
- Les limites mémoire (20% RAM) sont actives
- La commande 'su' est désactivée pour le groupe
- Les logs sont disponibles dans partie-1-bash/logs/

═══════════════════════════════════════════════════════════════
EOF
🆘 Dépannage courant
Problème 1 : Git push refusé
bash
# Si erreur "Updates were rejected"
git pull origin main --rebase
git push origin main
Problème 2 : Permission denied (SSH)
bash
# Vérifier les permissions de la clé
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh

# Ajouter la clé à l'agent SSH
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
Problème 3 : Ansible ne se connecte pas
bash
# Test de connexion
ansible -i inventory.ini vps_servers -m ping -vvv

# Vérifier l'inventaire
cat inventory.ini

# Tester SSH manuellement
ssh -p PORT user@IP
Problème 4 : Terraform init échoue
bash
# Nettoyer et réinitialiser
rm -rf .terraform .terraform.lock.hcl
terraform init
📚 Ressources supplémentaires
Commandes Git utiles
bash
# Voir l'historique
git log --oneline --graph --all

# Voir les différences
git diff

# Annuler le dernier commit (garder les changements)
git reset --soft HEAD~1

# Créer une branche
git checkout -b feature/ameliorations

# Fusionner une branche
git checkout main
git merge feature/ameliorations
Commandes de vérification
bash
# Vérifier la structure
tree -L 3 -I '.git|.terraform|logs'

# Compter les lignes de code
find . -name "*.sh" -o -name "*.yml" -o -name "*.tf" | xargs wc -l

# Vérifier les permissions
find . -type f -name "*.sh" -exec ls -lh {} \;
✅ Checklist finale
Avant soumission
 Tous les fichiers sont sur GitHub
 Les README sont complets et à jour
 Les scripts ont été testés
 La documentation est claire
 Les fichiers sensibles ne sont pas commités
 Le projet peut être cloné et utilisé par quelqu'un d'autre
 Les captures d'écran sont incluses (si demandées)
 Le fichier RESULTATS.md est rempli
 Le lien GitHub est fonctionnel
Communication avec l'enseignant
Objet : Soumission TP INF 3611 - VOTRE NOM

Bonjour Dr. NGOUANFO,

Je vous soumets mon TP d'Administration Systèmes et Réseaux :

Dépôt GitHub : https://github.com/VOTRE-USERNAME/TP-INF-361

Le projet est complet avec :
- Script Bash fonctionnel
- Playbook Ansible avec envoi d'emails
- Configuration Terraform
- Documentation complète

Tous les tests ont été effectués avec succès sur mon VPS.

Cordialement,
VOTRE NOM
Matricule : XXXXXX
🎉 Félicitations !
Vous avez maintenant un projet complet, documenté et versionné sur GitHub !

Prochaines étapes suggérées :

Améliorer la gestion des erreurs
Ajouter des tests automatisés
Créer une CI/CD avec GitHub Actions
Dockeriser l'environnement
Ajouter un monitoring avec Prometheus
Bon courage pour votre soutenance ! 🚀

