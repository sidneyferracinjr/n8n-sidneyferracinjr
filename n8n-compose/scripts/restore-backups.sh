#!/bin/bash
set -e

# Carregar variáveis do arquivo .env
ENV_FILE="$(dirname "$0")/.env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# Função para verificar se uma variável está definida
check_env_var() {
  if [ -z "${!1}" ]; then
    echo "Erro: A variável de ambiente '$1' não está definida."
    exit 1
  fi
}

# Validar variáveis de ambiente necessárias
check_env_var "DB_POSTGRESDB_USER"
check_env_var "DB_POSTGRESDB_DATABASE"
check_env_var "DB_POSTGRESDB_PASSWORD"
check_env_var "DB_POSTGRESDB_HOST"
check_env_var "DB_POSTGRESDB_PORT"
check_env_var "BACKUP_PASSWORD"

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo "Erro: Docker não está instalado ou não está no PATH."
  exit 1
fi

# Verificar conexão com o banco de dados
echo "🔍 Verificando conexão com o banco de dados..."
if ! PGPASSWORD="$DB_POSTGRESDB_PASSWORD" psql -U "$DB_POSTGRESDB_USER" -h "$DB_POSTGRESDB_HOST" -p "$DB_POSTGRESDB_PORT" -d "$DB_POSTGRESDB_DATABASE" -c '\q' &> /dev/null; then
  echo "❌ Erro: Não foi possível conectar ao banco de dados. Verifique as credenciais e a conectividade."
  exit 1
fi
echo "✅ Conexão com o banco de dados verificada com sucesso."

# Verificar se os arquivos de backups foram fornecidos
if [ -z "$1" ]; then
  echo "Uso: $0 <arquivo-backups.sql[.gz][.enc]> [--force]"
  exit 1
fi

BACKUPS_FILE="$1"
FORCE=false

# Verificar flag --force
if [ "$2" == "--force" ]; then
  FORCE=true
fi

if [ ! -f "$BACKUPS_FILE" ]; then
  echo "Erro: Arquivo de backups '$BACKUPS_FILE' não encontrado!"
  exit 1
fi

# Confirmar restauração, a menos que --force seja usado
if [ "$FORCE" = false ]; then
  read -p "Tem certeza que deseja restaurar os backups '$BACKUPS_FILE'? Isso irá sobrescrever dados existentes. (s/N): " confirm
  if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
    echo "Restauração cancelada."
    exit 0
  fi
fi

# Verificar integridade do arquivo
echo "🔍 Verificando integridade do arquivo de backup..."
FILE_TYPE=$(file -b "$BACKUPS_FILE")

if [[ "$BACKUPS_FILE" == *.enc ]]; then
  echo "🔒 Arquivo criptografado detectado. Decriptando com OpenSSL..."
  TEMP_FILE="/tmp/backup_to_restore.sql.gz"
  openssl enc -aes-256-cbc -d -in "$BACKUPS_FILE" -out "$TEMP_FILE" -k "$BACKUP_PASSWORD"
  echo "✅ Decriptação concluída: $TEMP_FILE"
  BACKUPS_FILE="$TEMP_FILE"
  FILE_TYPE=$(file -b "$BACKUPS_FILE")
fi

if [[ "$FILE_TYPE" == *gzip* ]]; then
  echo "🔍 Arquivo compactado detectado. Testando integridade com gzip..."
  if gzip -t "$BACKUPS_FILE"; then
    echo "✅ Arquivo compactado válido."
  else
    echo "❌ Erro: O arquivo compactado está corrompido."
    exit 1
  fi
elif [[ "$FILE_TYPE" == *ASCII* ]]; then
  echo "✅ Arquivo SQL detectado e válido."
else
  echo "❌ Erro: Tipo de arquivo desconhecido ou inválido: $FILE_TYPE"
  exit 1
fi

# Criar um container temporário para restauração
TEMP_CONTAINER_NAME="postgres_restore_temp"
echo "Criando container temporário para restauração..."

docker run --rm --name "$TEMP_CONTAINER_NAME" \
  -e POSTGRES_USER="$DB_POSTGRESDB_USER" \
  -e POSTGRES_PASSWORD="$DB_POSTGRESDB_PASSWORD" \
  -e POSTGRES_DB="$DB_POSTGRESDB_DATABASE" \
  -v "$BACKUPS_FILE:/backup.sql.gz" \
  postgres:16.2 bash -c "
    echo 'Iniciando restauração...';
    gunzip -c /backup.sql.gz | psql -h $DB_POSTGRESDB_HOST -p $DB_POSTGRESDB_PORT -U $DB_POSTGRESDB_USER -d $DB_POSTGRESDB_DATABASE;
    echo 'Restauração concluída.';
  "

# Limpar arquivo temporário
if [[ "$BACKUPS_FILE" == "/tmp/backup_to_restore.sql.gz" ]]; then
  rm -f "$BACKUPS_FILE"
fi

echo "Restauração dos backups '$1' concluída com sucesso!"