################################################################################
# Fichier: variables.tf
# Description: Définition des variables pour le module Terraform
# Auteur: Étudiant Licence 3 Informatique - UY1
# Cours: INF 3611 - Administration Systèmes et Réseaux
################################################################################

# ============================================================================
# VARIABLES DE CONNEXION SSH
# ============================================================================

variable "server_ip" {
  description = "Adresse IP du serveur VPS cible"
  type        = string
  
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.server_ip))
    error_message = "L'adresse IP doit être au format IPv4 valide (ex: 192.168.1.100)"
  }
}

variable "ssh_user" {
  description = "Nom d'utilisateur SSH pour la connexion au serveur"
  type        = string
  default     = "root"
}

variable "ssh_port" {
  description = "Port SSH du serveur (22 par défaut)"
  type        = number
  default     = 22
  
  validation {
    condition     = var.ssh_port > 0 && var.ssh_port <= 65535
    error_message = "Le port SSH doit être entre 1 et 65535"
  }
}

variable "ssh_private_key_path" {
  description = "Chemin vers la clé privée SSH pour l'authentification"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# ============================================================================
# VARIABLES DE CONFIGURATION DU SCRIPT
# ============================================================================

variable "group_name" {
  description = "Nom du groupe principal à créer pour les utilisateurs"
  type        = string
  default     = "students-inf-361"
  
  validation {
    condition     = length(var.group_name) > 0 && length(var.group_name) <= 32
    error_message = "Le nom du groupe doit contenir entre 1 et 32 caractères"
  }
}

variable "script_path" {
  description = "Chemin local vers le script create_users.sh"
  type        = string
  default     = "../partie-1-bash/create_users.sh"
}

variable "users_file_path" {
  description = "Chemin local vers le fichier users.txt"
  type        = string
  default     = "../users.txt"
}

# ============================================================================
# VARIABLES DE CONFIGURATION OPTIONNELLES
# ============================================================================

variable "fetch_logs" {
  description = "Télécharger les logs d'exécution depuis le serveur"
  type        = bool
  default     = true
}

variable "cleanup_temp_files" {
  description = "Nettoyer les fichiers temporaires sur le serveur après exécution"
  type        = bool
  default     = false
}

# ============================================================================
# VARIABLES DE CONFIGURATION DES UTILISATEURS
# ============================================================================

variable "disk_quota_gb" {
  description = "Quota disque par utilisateur en Go"
  type        = number
  default     = 15
  
  validation {
    condition     = var.disk_quota_gb > 0 && var.disk_quota_gb <= 1000
    error_message = "Le quota disque doit être entre 1 et 1000 Go"
  }
}

variable "memory_limit_percent" {
  description = "Limite mémoire par processus en pourcentage de la RAM totale"
  type        = number
  default     = 20
  
  validation {
    condition     = var.memory_limit_percent > 0 && var.memory_limit_percent <= 100
    error_message = "La limite mémoire doit être entre 1 et 100%"
  }
}

# ============================================================================
# VARIABLES DE TAGS ET MÉTADONNÉES
# ============================================================================

variable "project_name" {
  description = "Nom du projet pour l'organisation"
  type        = string
  default     = "INF-3611-User-Management"
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit être dev, staging ou prod"
  }
}

variable "tags" {
  description = "Tags additionnels pour l'organisation"
  type        = map(string)
  default = {
    Course      = "INF-3611"
    University  = "UY1"
    Department  = "Informatique"
    Managed_by  = "Terraform"
  }
}

# ============================================================================
# VARIABLES DE CONFIGURATION AVANCÉE
# ============================================================================

variable "connection_timeout" {
  description = "Timeout pour les connexions SSH (en minutes)"
  type        = number
  default     = 10
}

variable "retry_attempts" {
  description = "Nombre de tentatives de réexécution en cas d'échec"
  type        = number
  default     = 3
  
  validation {
    condition     = var.retry_attempts >= 0 && var.retry_attempts <= 10
    error_message = "Le nombre de tentatives doit être entre 0 et 10"
  }
}

variable "enable_verbose_output" {
  description = "Activer la sortie détaillée des commandes"
  type        = bool
  default     = true
}