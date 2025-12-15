################################################################################
# Fichier: main.tf
# Description: Configuration Terraform pour exécuter le script de création
#              d'utilisateurs via un provisioner
# Auteur: Étudiant Licence 3 Informatique - UY1
# Cours: INF 3611 - Administration Systèmes et Réseaux
################################################################################

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# ============================================================================
# PROVIDER NULL (pour exécution de scripts)
# ============================================================================

# Le provider null permet d'exécuter des scripts sans créer de ressources cloud
provider "null" {}

# ============================================================================
# RESSOURCE NULL POUR UPLOADER LE SCRIPT
# ============================================================================

# Upload du script sur le serveur cible
resource "null_resource" "upload_script" {
  # Déclencher le re-déploiement si le script change
  triggers = {
    script_hash = filemd5(var.script_path)
    users_hash  = filemd5(var.users_file_path)
  }

  # Connexion SSH au serveur
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    port        = var.ssh_port
    timeout     = "5m"
  }

  # Upload du script de création d'utilisateurs
  provisioner "file" {
    source      = var.script_path
    destination = "/tmp/create_users.sh"
  }

  # Upload du fichier utilisateurs
  provisioner "file" {
    source      = var.users_file_path
    destination = "/tmp/users.txt"
  }

  # Rendre le script exécutable
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_users.sh",
      "echo '✓ Script uploadé et rendu exécutable'"
    ]
  }
}

# ============================================================================
# RESSOURCE NULL POUR EXÉCUTER LE SCRIPT
# ============================================================================

# Exécution du script de création d'utilisateurs
resource "null_resource" "execute_script" {
  # Dépend de l'upload du script
  depends_on = [null_resource.upload_script]

  # Déclencher la réexécution si les fichiers changent
  triggers = {
    script_hash = filemd5(var.script_path)
    users_hash  = filemd5(var.users_file_path)
    always_run  = timestamp() # Optionnel: toujours exécuter
  }

  # Connexion SSH au serveur
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    port        = var.ssh_port
    timeout     = "10m"
  }

  # Exécution du script avec gestion des logs
  provisioner "remote-exec" {
    inline = [
      "echo '════════════════════════════════════════════════════════'",
      "echo '🚀 Terraform - Exécution du script de création utilisateurs'",
      "echo '════════════════════════════════════════════════════════'",
      "echo ''",
      "echo '📋 Configuration:'",
      "echo '   • Groupe: ${var.group_name}'",
      "echo '   • Fichier: /tmp/users.txt'",
      "echo '   • Serveur: ${var.server_ip}'",
      "echo ''",
      "cd /tmp",
      "sudo bash create_users.sh ${var.group_name} users.txt",
      "echo ''",
      "echo '════════════════════════════════════════════════════════'",
      "echo '✅ Script exécuté avec succès via Terraform'",
      "echo '════════════════════════════════════════════════════════'"
    ]
  }
}

# ============================================================================
# RESSOURCE NULL POUR RÉCUPÉRER LES LOGS
# ============================================================================

# Téléchargement des logs d'exécution (optionnel)
resource "null_resource" "fetch_logs" {
  # Dépend de l'exécution du script
  depends_on = [null_resource.execute_script]

  # Déclencher si activé via variable
  count = var.fetch_logs ? 1 : 0

  # Connexion SSH au serveur
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    port        = var.ssh_port
  }

  # Récupérer le dernier fichier de log
  provisioner "local-exec" {
    command = <<-EOT
      echo "📥 Récupération des logs depuis le serveur..."
      scp -P ${var.ssh_port} -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no \
        ${var.ssh_user}@${var.server_ip}:/tmp/logs/user_creation_*.log ./terraform_logs/ 2>/dev/null || true
      echo "✓ Logs récupérés dans ./terraform_logs/"
    EOT
  }

  # Créer le répertoire de logs localement
  provisioner "local-exec" {
    command = "mkdir -p ./terraform_logs"
  }
}

# ============================================================================
# RESSOURCE NULL POUR NETTOYAGE (optionnel)
# ============================================================================

# Nettoyage des fichiers temporaires sur le serveur
resource "null_resource" "cleanup" {
  # Dépend des autres ressources
  depends_on = [
    null_resource.execute_script,
    null_resource.fetch_logs
  ]

  # Déclencher si activé via variable
  count = var.cleanup_temp_files ? 1 : 0

  # Connexion SSH au serveur
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    port        = var.ssh_port
  }

  # Supprimer les fichiers temporaires
  provisioner "remote-exec" {
    inline = [
      "echo '🧹 Nettoyage des fichiers temporaires...'",
      "sudo rm -f /tmp/create_users.sh",
      "sudo rm -f /tmp/users.txt",
      "echo '✓ Nettoyage terminé'"
    ]
  }
}

# ============================================================================
# DATA SOURCE POUR VÉRIFICATIONS POST-EXÉCUTION
# ============================================================================

# Vérification que le groupe a été créé
data "external" "verify_group" {
  depends_on = [null_resource.execute_script]
  
  program = ["bash", "-c", <<-EOT
    ssh -p ${var.ssh_port} -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no \
      ${var.ssh_user}@${var.server_ip} \
      "getent group ${var.group_name} > /dev/null 2>&1 && echo '{\"exists\":\"true\"}' || echo '{\"exists\":\"false\"}'"
  EOT
  ]
}

# ============================================================================
# OUTPUTS LOCAUX POUR DEBUG
# ============================================================================

# Affichage local des informations
resource "null_resource" "display_summary" {
  depends_on = [null_resource.execute_script]

  provisioner "local-exec" {
    command = <<-EOT
      echo ""
      echo "════════════════════════════════════════════════════════════════"
      echo "              📊 RÉSUMÉ TERRAFORM - CRÉATION UTILISATEURS"
      echo "════════════════════════════════════════════════════════════════"
      echo ""
      echo "✅ Infrastructure provisionnée avec succès"
      echo ""
      echo "📋 Détails:"
      echo "   • Serveur cible    : ${var.server_ip}:${var.ssh_port}"
      echo "   • Groupe créé      : ${var.group_name}"
      echo "   • Fichier source   : ${var.users_file_path}"
      echo "   • Script exécuté   : ${var.script_path}"
      echo ""
      echo "🔍 Vérification:"
      echo "   ssh -p ${var.ssh_port} ${var.ssh_user}@${var.server_ip} 'getent group ${var.group_name}'"
      echo ""
      echo "════════════════════════════════════════════════════════════════"
      echo ""
    EOT
  }
}