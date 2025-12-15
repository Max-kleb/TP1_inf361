#!/bin/bash

################################################################################
# Script: create_users.sh
# Description: Automatisation de la création d'utilisateurs sous Linux
# Auteur: Étudiant Licence 3 Informatique - UY1
# Cours: INF 3611 - Administration Systèmes et Réseaux
# Date: Décembre 2025
################################################################################

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/user_creation_$(date +%Y%m%d_%H%M%S).log"
WELCOME_FILE="WELCOME.txt"

################################################################################
# Fonction: log_message
# Description: Enregistre un message dans le fichier de log avec timestamp
################################################################################
log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

################################################################################
# Fonction: print_color
# Description: Affiche un message en couleur
################################################################################
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

################################################################################
# Fonction: check_root
# Description: Vérifie que le script est exécuté en tant que root
################################################################################
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_color "$RED" "❌ Ce script doit être exécuté en tant que root (sudo)"
        exit 1
    fi
}

################################################################################
# Fonction: check_dependencies
# Description: Vérifie la présence des dépendances nécessaires
################################################################################
check_dependencies() {
    log_message "INFO" "Vérification des dépendances..."
    
    local deps=("useradd" "groupadd" "chpasswd" "quota" "chage")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_color "$RED" "❌ Dépendances manquantes: ${missing_deps[*]}"
        log_message "ERROR" "Dépendances manquantes: ${missing_deps[*]}"
        exit 1
    fi
    
    log_message "INFO" "✓ Toutes les dépendances sont installées"
}

################################################################################
# Fonction: create_log_directory
# Description: Crée le répertoire de logs s'il n'existe pas
################################################################################
create_log_directory() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR"
        log_message "INFO" "Répertoire de logs créé: $LOG_DIR"
    fi
}

################################################################################
# Fonction: create_group
# Description: Crée le groupe principal si nécessaire
################################################################################
create_group() {
    local group_name=$1
    
    if getent group "$group_name" > /dev/null 2>&1; then
        log_message "WARNING" "Le groupe $group_name existe déjà"
        print_color "$YELLOW" "⚠️  Le groupe $group_name existe déjà"
    else
        groupadd "$group_name"
        log_message "INFO" "Groupe $group_name créé avec succès"
        print_color "$GREEN" "✓ Groupe $group_name créé"
    fi
}

################################################################################
# Fonction: check_and_install_shell
# Description: Vérifie si un shell existe, sinon tente de l'installer
################################################################################
check_and_install_shell() {
    local shell_path=$1
    
    # Vérifier si le shell existe
    if [[ -f "$shell_path" ]]; then
        log_message "INFO" "Shell $shell_path est disponible"
        echo "$shell_path"
        return 0
    fi
    
    log_message "WARNING" "Shell $shell_path non trouvé, tentative d'installation..."
    
    # Extraire le nom du shell
    local shell_name=$(basename "$shell_path")
    
    # Tentative d'installation
    if apt-get update > /dev/null 2>&1 && apt-get install -y "$shell_name" > /dev/null 2>&1; then
        log_message "INFO" "Shell $shell_name installé avec succès"
        echo "$shell_path"
        return 0
    else
        log_message "ERROR" "Impossible d'installer $shell_name, utilisation de /bin/bash"
        print_color "$RED" "❌ Installation de $shell_name échouée, utilisation de /bin/bash"
        echo "/bin/bash"
        return 1
    fi
}

################################################################################
# Fonction: configure_sudo_restrictions
# Description: Configure les restrictions sudo pour le groupe
################################################################################
configure_sudo_restrictions() {
    local group_name=$1
    local sudoers_file="/etc/sudoers.d/${group_name}"
    
    # Créer le fichier de configuration sudo
    cat > "$sudoers_file" << EOF
# Configuration sudo pour le groupe $group_name
# Membres peuvent utiliser sudo mais pas la commande su
%${group_name} ALL=(ALL:ALL) ALL, !/bin/su, !/usr/bin/su
EOF
    
    # Définir les permissions appropriées
    chmod 0440 "$sudoers_file"
    
    # Vérifier la syntaxe
    if visudo -c -f "$sudoers_file" > /dev/null 2>&1; then
        log_message "INFO" "Configuration sudo créée pour $group_name avec restriction sur su"
        print_color "$GREEN" "✓ Restrictions sudo configurées"
    else
        log_message "ERROR" "Erreur dans la configuration sudo"
        rm -f "$sudoers_file"
        print_color "$RED" "❌ Erreur dans la configuration sudo"
    fi
}

################################################################################
# Fonction: create_welcome_message
# Description: Crée le message de bienvenue personnalisé
################################################################################
create_welcome_message() {
    local home_dir=$1
    local username=$2
    local full_name=$3
    
    local welcome_path="${home_dir}/${WELCOME_FILE}"
    
    cat > "$welcome_path" << EOF
╔════════════════════════════════════════════════════════════════╗
║                    BIENVENUE SUR LE SERVEUR VPS                ║
║                  UNIVERSITÉ DE YAOUNDÉ I                       ║
║            Département d'Informatique - Licence 3              ║
╚════════════════════════════════════════════════════════════════╝

Bonjour ${full_name} (${username}),

Vous êtes maintenant connecté(e) au serveur VPS du cours INF 3611.

📋 INFORMATIONS IMPORTANTES :
   • Groupe : students-inf-361
   • Quota disque : 15 Go maximum
   • Limite mémoire : 20% de la RAM par processus
   • Vous devez changer votre mot de passe à la première connexion

⚠️  RÈGLES DE SÉCURITÉ :
   • Ne partagez jamais vos identifiants
   • Utilisez des mots de passe forts
   • La commande 'su' est désactivée pour votre sécurité
   • Toutes vos actions sont journalisées

📞 SUPPORT :
   • En cas de problème, contactez l'administrateur système
   • Email : admin@uy1.cm

Bon travail ! 🚀

════════════════════════════════════════════════════════════════
Date de création du compte : $(date '+%d/%m/%Y à %H:%M')
════════════════════════════════════════════════════════════════
EOF
    
    chown "${username}:${username}" "$welcome_path"
    chmod 644 "$welcome_path"
    
    log_message "INFO" "Message de bienvenue créé pour $username"
}

################################################################################
# Fonction: configure_bashrc
# Description: Configure .bashrc pour afficher le message de bienvenue
################################################################################
configure_bashrc() {
    local home_dir=$1
    local username=$2
    local bashrc="${home_dir}/.bashrc"
    
    # Créer .bashrc s'il n'existe pas
    if [[ ! -f "$bashrc" ]]; then
        touch "$bashrc"
        chown "${username}:${username}" "$bashrc"
    fi
    
    # Ajouter l'affichage du message de bienvenue
    if ! grep -q "WELCOME.txt" "$bashrc" 2>/dev/null; then
        cat >> "$bashrc" << 'EOF'

# Affichage du message de bienvenue
if [ -f ~/WELCOME.txt ]; then
    cat ~/WELCOME.txt
fi
EOF
        log_message "INFO" ".bashrc configuré pour $username"
    fi
}

################################################################################
# Fonction: setup_disk_quota
# Description: Configure les quotas disque pour un utilisateur
################################################################################
setup_disk_quota() {
    local username=$1
    local quota_limit_gb=15
    local quota_limit_blocks=$((quota_limit_gb * 1024 * 1024))  # Conversion en blocs de 1K
    
    # Vérifier si les quotas sont activés
    if ! command -v setquota &> /dev/null; then
        log_message "ERROR" "La commande setquota n'est pas disponible"
        print_color "$YELLOW" "⚠️  Quotas non configurés (setquota manquant)"
        return 1
    fi
    
    # Configurer le quota (soft limit = hard limit = 15 GB)
    setquota -u "$username" "$quota_limit_blocks" "$quota_limit_blocks" 0 0 / 2>/dev/null || \
    setquota -u "$username" "$quota_limit_blocks" "$quota_limit_blocks" 0 0 /home 2>/dev/null || {
        log_message "WARNING" "Impossible de configurer les quotas pour $username"
        print_color "$YELLOW" "⚠️  Quotas non configurés (vérifier la partition)"
        return 1
    }
    
    log_message "INFO" "Quota de ${quota_limit_gb}G configuré pour $username"
    return 0
}

################################################################################
# Fonction: setup_memory_limit
# Description: Configure les limites mémoire pour un utilisateur
################################################################################
setup_memory_limit() {
    local username=$1
    local limits_file="/etc/security/limits.d/${username}.conf"
    
    # Calculer 20% de la RAM totale en KB
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_limit_kb=$((total_ram_kb * 20 / 100))
    
    # Créer le fichier de configuration des limites
    cat > "$limits_file" << EOF
# Limites de ressources pour l'utilisateur $username
# 20% de la RAM totale (${mem_limit_kb} KB)
$username soft rss $mem_limit_kb
$username hard rss $mem_limit_kb
$username soft nproc 100
$username hard nproc 150
EOF
    
    chmod 644 "$limits_file"
    
    log_message "INFO" "Limites mémoire configurées pour $username (20% RAM = ${mem_limit_kb}KB)"
    print_color "$GREEN" "✓ Limites mémoire configurées"
}

################################################################################
# Fonction: create_user
# Description: Crée un utilisateur avec toutes ses configurations
################################################################################
create_user() {
    local username=$1
    local password=$2
    local full_name=$3
    local phone=$4
    local email=$5
    local preferred_shell=$6
    local group_name=$7
    
    log_message "INFO" "════════════════════════════════════════"
    log_message "INFO" "Création de l'utilisateur: $username"
    print_color "$BLUE" "\n🔧 Création de l'utilisateur: $username"
    
    # Vérifier si l'utilisateur existe déjà
    if id "$username" &>/dev/null; then
        log_message "WARNING" "L'utilisateur $username existe déjà, ignoré"
        print_color "$YELLOW" "⚠️  L'utilisateur $username existe déjà"
        return 0
    fi
    
    # Vérifier et installer le shell si nécessaire
    local shell=$(check_and_install_shell "$preferred_shell")
    
    # Créer l'utilisateur
    useradd -m -s "$shell" -c "${full_name},${phone},${email}" -G "$group_name,sudo" "$username"
    
    if [[ $? -eq 0 ]]; then
        log_message "INFO" "✓ Utilisateur $username créé"
        print_color "$GREEN" "  ✓ Compte créé"
    else
        log_message "ERROR" "Échec de la création de l'utilisateur $username"
        print_color "$RED" "  ❌ Échec de la création"
        return 1
    fi
    
    # Configurer le mot de passe (haché en SHA-512)
    echo "$username:$password" | chpasswd -c SHA512
    log_message "INFO" "✓ Mot de passe configuré (SHA-512)"
    print_color "$GREEN" "  ✓ Mot de passe configuré"
    
    # Forcer le changement de mot de passe à la première connexion
    chage -d 0 "$username"
    log_message "INFO" "✓ Changement de mot de passe forcé"
    print_color "$GREEN" "  ✓ Changement obligatoire activé"
    
    # Créer le message de bienvenue
    local home_dir=$(eval echo "~$username")
    create_welcome_message "$home_dir" "$username" "$full_name"
    configure_bashrc "$home_dir" "$username"
    print_color "$GREEN" "  ✓ Message de bienvenue configuré"
    
    # Configurer les quotas disque
    setup_disk_quota "$username"
    
    # Configurer les limites mémoire
    setup_memory_limit "$username"
    
    log_message "INFO" "✓ Utilisateur $username créé et configuré avec succès"
    print_color "$GREEN" "  ✓ Configuration complète"
    
    return 0
}

################################################################################
# Fonction: process_users_file
# Description: Traite le fichier des utilisateurs ligne par ligne
################################################################################
process_users_file() {
    local file=$1
    local group_name=$2
    local line_number=0
    local success_count=0
    local error_count=0
    
    log_message "INFO" "Début du traitement du fichier: $file"
    print_color "$BLUE" "\n📄 Traitement du fichier utilisateurs..."
    
    while IFS=';' read -r username password full_name phone email shell || [[ -n "$username" ]]; do
        ((line_number++))
        
        # Ignorer les lignes vides et les commentaires
        [[ -z "$username" ]] && continue
        [[ "$username" =~ ^[[:space:]]*# ]] && continue
        
        # Supprimer les espaces en début et fin
        username=$(echo "$username" | xargs)
        password=$(echo "$password" | xargs)
        full_name=$(echo "$full_name" | xargs)
        phone=$(echo "$phone" | xargs)
        email=$(echo "$email" | xargs)
        shell=$(echo "$shell" | xargs)
        
        # Valider les champs obligatoires
        if [[ -z "$username" ]] || [[ -z "$password" ]]; then
            log_message "ERROR" "Ligne $line_number: username ou password manquant"
            ((error_count++))
            continue
        fi
        
        # Créer l'utilisateur
        if create_user "$username" "$password" "$full_name" "$phone" "$email" "$shell" "$group_name"; then
            ((success_count++))
        else
            ((error_count++))
        fi
        
    done < "$file"
    
    log_message "INFO" "════════════════════════════════════════"
    log_message "INFO" "Traitement terminé:"
    log_message "INFO" "  - Utilisateurs créés avec succès: $success_count"
    log_message "INFO" "  - Erreurs rencontrées: $error_count"
    log_message "INFO" "════════════════════════════════════════"
    
    print_color "$BLUE" "\n" "═══════════════════════════════════════════════"
    print_color "$GREEN" "✅ Résumé de l'exécution:"
    print_color "$GREEN" "   • Utilisateurs créés: $success_count"
    if [[ $error_count -gt 0 ]]; then
        print_color "$RED" "   • Erreurs: $error_count"
    fi
    print_color "$BLUE" "═══════════════════════════════════════════════"
}

################################################################################
# Fonction: display_usage
# Description: Affiche l'aide d'utilisation du script
################################################################################
display_usage() {
    cat << EOF
Usage: $0 <nom_du_groupe> <fichier_utilisateurs>

Description:
    Crée automatiquement des utilisateurs Linux avec leurs configurations
    à partir d'un fichier texte.

Arguments:
    nom_du_groupe         : Nom du groupe principal (ex: students-inf-361)
    fichier_utilisateurs  : Chemin vers le fichier users.txt

Format du fichier utilisateurs (séparateur: point-virgule):
    username;password;Full Name;phone;email;shell

Exemple:
    sudo $0 students-inf-361 users.txt

Fichier de log:
    ${LOG_DIR}/user_creation_YYYYMMDD_HHMMSS.log

EOF
}

################################################################################
# PROGRAMME PRINCIPAL
################################################################################
main() {
    # Afficher le banner
    print_color "$BLUE" "
╔════════════════════════════════════════════════════════════════╗
║         SCRIPT DE CRÉATION AUTOMATISÉE D'UTILISATEURS         ║
║                  UNIVERSITÉ DE YAOUNDÉ I                       ║
║            INF 3611 - Administration Systèmes et Réseaux       ║
╚════════════════════════════════════════════════════════════════╝
"
    
    # Vérifier les arguments
    if [[ $# -ne 2 ]]; then
        display_usage
        exit 1
    fi
    
    local group_name=$1
    local users_file=$2
    
    # Créer le répertoire de logs
    create_log_directory
    
    # Démarrer la journalisation
    log_message "INFO" "════════════════════════════════════════"
    log_message "INFO" "DÉBUT DE L'EXÉCUTION DU SCRIPT"
    log_message "INFO" "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    log_message "INFO" "Groupe cible: $group_name"
    log_message "INFO" "Fichier source: $users_file"
    log_message "INFO" "════════════════════════════════════════"
    
    # Vérifications préliminaires
    check_root
    check_dependencies
    
    # Vérifier que le fichier existe
    if [[ ! -f "$users_file" ]]; then
        print_color "$RED" "❌ Fichier '$users_file' introuvable"
        log_message "ERROR" "Fichier '$users_file' introuvable"
        exit 1
    fi
    
    print_color "$GREEN" "✓ Vérifications préliminaires réussies"
    
    # Créer le groupe principal
    print_color "$BLUE" "\n🔧 Configuration du groupe..."
    create_group "$group_name"
    
    # Configurer les restrictions sudo
    configure_sudo_restrictions "$group_name"
    
    # Traiter le fichier utilisateurs
    process_users_file "$users_file" "$group_name"
    
    # Fin de l'exécution
    log_message "INFO" "════════════════════════════════════════"
    log_message "INFO" "FIN DE L'EXÉCUTION DU SCRIPT"
    log_message "INFO" "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    log_message "INFO" "Fichier de log: $LOG_FILE"
    log_message "INFO" "════════════════════════════════════════"
    
    print_color "$GREEN" "\n✅ Script terminé avec succès!"
    print_color "$BLUE" "📋 Consultez le log pour plus de détails: $LOG_FILE"
    
    # Afficher des commandes utiles
    print_color "$YELLOW" "\n💡 Commandes utiles:"
    echo "   • Voir les utilisateurs créés : getent group $group_name"
    echo "   • Tester une connexion : ssh username@localhost"
    echo "   • Vérifier les quotas : sudo quota -u username"
    echo ""
}

# Exécuter le programme principal
main "$@"