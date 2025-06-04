#!/bin/sh
set -euo pipefail

# Configuração de logging
LOG_FILE="/var/log/backup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "⏳ $(date +"%Y-%m-%d %H:%M:%S") - Iniciando processo de backup do PostgreSQL..."

# Verifica se o diretório de destino existe
BACKUP_DIR="/backups"
if [ ! -d "$BACKUP_DIR" ]; then
  echo "❌ $(date +"%Y-%m-%d %H:%M:%S") - O diretório de destino $BACKUP_DIR não existe. Crie-o antes de executar o script."
  exit 1
fi

# Define nome do arquivo com timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/n8n_backup_${TIMESTAMP}.sql"
ENCRYPTED_BACKUP_FILE="${BACKUP_FILE}.gz.enc"

# Executa o backup
echo "🔄 $(date +"%Y-%m-%d %H:%M:%S") - Realizando backup do banco de dados..."
PGPASSWORD="$DB_PASSWORD" pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" "$DB_NAME" > "$BACKUP_FILE"

# Verifica se o backup foi bem-sucedido
if [ $? -eq 0 ]; then
  echo "✅ $(date +"%Y-%m-%d %H:%M:%S") - Backup finalizado com sucesso: $BACKUP_FILE"

  # Compacta o arquivo de backup usando gzip
  echo "🔄 $(date +"%Y-%m-%d %H:%M:%S") - Compactando o arquivo de backup..."
  gzip "$BACKUP_FILE"
  COMPRESSED_BACKUP_FILE="${BACKUP_FILE}.gz"
  echo "✅ $(date +"%Y-%m-%d %H:%M:%S") - Backup compactado: $COMPRESSED_BACKUP_FILE"

  # Criptografa o arquivo compactado usando OpenSSL
  echo "🔒 $(date +"%Y-%m-%d %H:%M:%S") - Criptografando o backup..."
  openssl enc -aes-256-cbc -salt -in "$COMPRESSED_BACKUP_FILE" -out "$ENCRYPTED_BACKUP_FILE" -k "$BACKUP_PASSWORD"
  echo "✅ $(date +"%Y-%m-%d %H:%M:%S") - Backup criptografado: $ENCRYPTED_BACKUP_FILE"

  # Remove o arquivo compactado não criptografado
  echo "🗑️ $(date +"%Y-%m-%d %H:%M:%S") - Removendo arquivo compactado não criptografado..."
  rm "$COMPRESSED_BACKUP_FILE"
else
  echo "❌ $(date +"%Y-%m-%d %H:%M:%S") - Falha no backup"
  exit 1
fi
