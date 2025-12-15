################################################################################
# Fichier: outputs.tf
# Description: Définition des sorties Terraform pour l'information utilisateur
# Auteur: Étudiant Licence 3 Informatique - UY1
# Cours: INF 3611 - Administration Systèmes et Réseaux
################################################################################

# ============================================================================
# OUTPUTS D'INFORMATION SUR LE DÉPLOIEMENT
# ============================================================================

output "deployment_summary" {
  description = "Résumé du déploiement"
  value = {
    server_ip       = var.server_ip
    ssh_port        = var.ssh_port
    group_name      = var.group_name
    script_executed = true
    timestamp       = timestamp()
  }
}

output "server_connection_info" {
  description = "Informations de connexion au serveur"
  value = {
    ip_address = var.server_ip
    ssh_port   = var.ssh_port
    ssh_user   = var.ssh_user
    ssh_command = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip}"
  }
}

# ============================================================================
# OUTPUTS DE VÉRIFICATION
# ============================================================================

output "group_verification_command" {
  description = "Commande pour vérifier la création du groupe"
  value       = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'getent group ${var.group_name}'"
}

output "list_users_command" {
  description = "Commande pour lister les utilisateurs du groupe"
  value       = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'getent group ${var.group_name} | cut -d: -f4'"
}

output "check_quota_command" {
  description = "Commande pour vérifier les quotas d'un utilisateur"
  value       = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'sudo quota -u USERNAME'"
}

# ============================================================================
# OUTPUTS DE CONFIGURATION
# ============================================================================

output "configuration_details" {
  description = "Détails de la configuration appliquée"
  value = {
    group_name           = var.group_name
    disk_quota_gb        = var.disk_quota_gb
    memory_limit_percent = var.memory_limit_percent
    script_path          = var.script_path
    users_file_path      = var.users_file_path
  }
}

# ============================================================================
# OUTPUTS DE LOCALISATION DES FICHIERS
# ============================================================================

output "files_location" {
  description = "Emplacement des fichiers sur le serveur"
  value = {
    script_location = "/tmp/create_users.sh"
    users_file      = "/tmp/users.txt"
    logs_directory  = "/tmp/logs/"
  }
}

# ============================================================================
# OUTPUTS DE LOGS
# ============================================================================

output "logs_info" {
  description = "Information sur les logs"
  value = {
    fetch_logs_enabled = var.fetch_logs
    local_logs_dir     = "./terraform_logs"
    remote_logs_dir    = "/tmp/logs/"
  }
  sensitive = false
}

# ============================================================================
# OUTPUTS D'ENVIRONNEMENT
# ============================================================================

output "environment_info" {
  description = "Information sur l'environnement"
  value = {
    project_name = var.project_name
    environment  = var.environment
    tags         = var.tags
  }
}

# ============================================================================
# OUTPUT DE VÉRIFICATION DU GROUPE
# ============================================================================

output "group_exists" {
  description = "Indique si le groupe a été créé avec succès"
  value       = try(data.external.verify_group.result.exists, "unknown")
}

# ============================================================================
# OUTPUTS DE COMMANDES UTILES
# ============================================================================

output "useful_commands" {
  description = "Commandes utiles pour la gestion post-déploiement"
  value = {
    connect_to_server     = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip}"
    list_group_users      = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'getent group ${var.group_name}'"
    view_remote_logs      = "ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'ls -lh /tmp/logs/'"
    download_latest_log   = "scp -P ${var.ssh_port} ${var.ssh_user}@${var.server_ip}:/tmp/logs/user_creation_*.log ."
    test_user_connection  = "ssh -p ${var.ssh_port} USERNAME@${var.server_ip}"
  }
}

# ============================================================================
# OUTPUT DE PROCHAINES ÉTAPES
# ============================================================================

output "next_steps" {
  description = "Prochaines étapes recommandées"
  value = <<-EOT
    
    ════════════════════════════════════════════════════════════════
                    ✅ TERRAFORM DEPLOYMENT COMPLETED
    ════════════════════════════════════════════════════════════════
    
    📋 PROCHAINES ÉTAPES RECOMMANDÉES:
    
    1. Vérifier les utilisateurs créés:
       ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'getent group ${var.group_name}'
    
    2. Tester la connexion d'un utilisateur:
       ssh -p ${var.ssh_port} USERNAME@${var.server_ip}
    
    3. Vérifier les quotas:
       ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'sudo quota -u USERNAME'
    
    4. Consulter les logs d'exécution:
       ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'cat /tmp/logs/user_creation_*.log'
    
    5. Télécharger les logs localement:
       scp -P ${var.ssh_port} ${var.ssh_user}@${var.server_ip}:/tmp/logs/*.log ./
    
    ════════════════════════════════════════════════════════════════
    
  EOT
}

# ============================================================================
# OUTPUT SENSIBLE (caché par défaut)
# ============================================================================

output "ssh_connection_string" {
  description = "Chaîne de connexion SSH complète (sensible)"
  value       = "ssh -i ${var.ssh_private_key_path} -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip}"
  sensitive   = true
}