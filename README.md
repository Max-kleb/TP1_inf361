TP 1 : Automatisation de la création d'utilisateurs sous Linux
Cours : INF 3611 - Administration Systèmes et Réseaux
Institution : Université de Yaoundé I - Faculté des Sciences
Département : Informatique - Licence 3
Date : Décembre 2025

📋 Table des matières
Vue d'ensemble
Structure du projet
Prérequis
Installation et Configuration
Utilisation
Partie 0 : Configuration SSH
Documentation technique
🎯 Vue d'ensemble
Ce projet automatise la création d'utilisateurs sur un serveur Linux VPS en utilisant trois approches différentes :

Script Bash : Automatisation avec shell scripting
Ansible : Orchestration et configuration management
Terraform : Infrastructure as Code
📁 Structure du projet
TP-INF-361/
├── README.md                          # Ce fichier
├── users.txt                          # Fichier source des utilisateurs
├── partie-0-ssh/
│   └── README.md                      # Configuration SSH
├── partie-1-bash/
│   ├── README.md
│   ├── create_users.sh               # Script Bash principal
│   └── logs/                         # Logs d'exécution
├── partie-2-ansible/
│   ├── README.md
│   ├── create_users.yml              # Playbook Ansible
│   ├── inventory.ini                 # Inventaire des serveurs
│   └── templates/
│       └── welcome_email.j2          # Template email
└── partie-3-terraform/
    ├── README.md
    ├── main.tf                       # Configuration principale
    ├── variables.tf                  # Variables Terraform
    └── outputs.tf                    # Sorties
🔧 Prérequis
Système d'exploitation
Ubuntu 20.04 LTS ou supérieur
Debian 10 ou supérieur
CentOS 8 ou supérieur
Logiciels requis
bash
# Sur le serveur cible
sudo apt update
sudo apt install -y python3 python3-pip openssh-server quota

# Sur la machine de contrôle
sudo apt install -y ansible terraform
Droits d'accès
Accès root ou sudo sur le serveur cible
Clés SSH configurées pour Ansible/Terraform
📦 Installation et Configuration
1. Cloner le projet
bash
git clone https://github.com/votre-username/TP-INF-361.git
cd TP-INF-361
2. Préparer le fichier users.txt
Créez ou modifiez users.txt avec la structure suivante :

username;password;Full Name;+237612345678;email@example.com;/bin/bash
alice;P@ssw0rd123;Alice Dupont;+237698765432;alice@uy1.cm;/bin/zsh
bob;Secure456!;Bob Martin;+237677889900;bob@uy1.cm;/bin/bash
3. Configuration SSH (Partie 0)
Avant toute création d'utilisateurs, sécurisez votre serveur SSH. Consultez partie-0-ssh/README.md pour les détails.

🚀 Utilisation
Méthode 1 : Script Bash
bash
cd partie-1-bash
sudo bash create_users.sh students-inf-361 ../users.txt
Méthode 2 : Ansible
bash
cd partie-2-ansible
# Éditer inventory.ini avec l'IP de votre serveur
ansible-playbook -i inventory.ini create_users.yml
Méthode 3 : Terraform
bash
cd partie-3-terraform
terraform init
terraform plan
terraform apply
🔐 Partie 0 : Configuration SSH
Procédure de modification
Sauvegarder la configuration actuelle
bash
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
Éditer le fichier de configuration
bash
   sudo nano /etc/ssh/sshd_config
Tester la configuration
bash
   sudo sshd -t
Recharger le service (PAS redémarrer)
bash
   sudo systemctl reload sshd
Ouvrir une NOUVELLE session SSH pour tester
bash
   ssh -p NOUVEAU_PORT user@serveur
⚠️ Risque principal
Ne JAMAIS redémarrer le service SSH sans avoir testé la configuration dans une nouvelle session.

Si la configuration est incorrecte et que vous redémarrez, vous perdrez l'accès au serveur. Utilisez toujours reload et testez dans une nouvelle session avant de fermer la session actuelle.

Paramètres de sécurité recommandés
1. Changer le port par défaut
bash
Port 2222
Justification : Réduit les attaques automatisées sur le port 22.

2. Désactiver la connexion root
bash
PermitRootLogin no
Justification : Force l'utilisation de comptes utilisateurs avec sudo, améliore la traçabilité.

3. Authentification par clés uniquement
bash
PasswordAuthentication no
PubkeyAuthentication yes
Justification : Élimine les attaques par force brute sur les mots de passe.

4. Limiter les tentatives de connexion
bash
MaxAuthTries 3
MaxSessions 2
Justification : Limite les tentatives d'intrusion et les connexions simultanées.

5. Désactiver les protocoles faibles
bash
Protocol 2
PermitEmptyPasswords no
X11Forwarding no
Justification : Utilise uniquement SSH version 2 (plus sécurisé) et désactive les fonctionnalités inutiles.

6. Timeout de connexion
bash
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
Justification : Déconnecte automatiquement les sessions inactives.

7. Limiter les utilisateurs autorisés
bash
AllowUsers alice bob charlie
AllowGroups students-inf-361
Justification : Contrôle précis des comptes autorisés à se connecter.

📊 Fonctionnalités implémentées
Script Bash
✅ Création de groupe personnalisé
✅ Création d'utilisateurs avec métadonnées complètes
✅ Vérification et installation de shells
✅ Hachage SHA-512 des mots de passe
✅ Changement de mot de passe obligatoire
✅ Ajout au groupe sudo avec restriction de su
✅ Message de bienvenue personnalisé
✅ Quotas disque (15 Go)
✅ Limitation mémoire (20% RAM)
✅ Journalisation complète
Playbook Ansible
✅ Toutes les fonctionnalités du script Bash
✅ Envoi d'email automatique avec :
IP du serveur
Port SSH
Identifiants
Commande de connexion
Commande pour transférer la clé publique
Terraform
✅ Provisioning d'infrastructure
✅ Exécution du script Bash
✅ Gestion de l'état
🔍 Vérification
Tester la création d'un utilisateur
bash
# Vérifier l'utilisateur
id alice

# Vérifier le groupe
getent group students-inf-361

# Tester la connexion
ssh alice@localhost

# Vérifier les quotas
sudo quota -u alice

# Vérifier les limites
ulimit -a
📝 Journalisation
Les logs sont stockés dans :

Bash : partie-1-bash/logs/user_creation_YYYYMMDD_HHMMSS.log
Ansible : Sortie standard + /var/log/ansible/
⚠️ Avertissements
Toujours tester en environnement de développement d'abord
Sauvegarder les configurations avant modification
Ne jamais fermer votre session SSH active avant d'avoir testé
Gardez une copie des mots de passe initiaux en lieu sûr
🆘 Dépannage
Le script échoue avec "Permission denied"
bash
chmod +x create_users.sh
sudo ./create_users.sh
Les quotas ne fonctionnent pas
bash
# Activer les quotas sur la partition
sudo mount -o remount,usrquota,grpquota /home
sudo quotacheck -cugm /home
sudo quotaon /home
Ansible ne peut pas se connecter
bash
# Vérifier la connectivité
ansible all -i inventory.ini -m ping

# Tester SSH manuellement
ssh -p PORT user@IP
👥 Auteurs
Votre Nom - Licence 3 Informatique - Université de Yaoundé I
📄 Licence
Ce projet est réalisé dans le cadre du cours INF 3611.

🙏 Remerciements
Dr. NGOUANFO - Enseignant INF 3611
Département d'Informatique - UY1
La communauté open source pour les outils utilisés
# TP1_inf361
