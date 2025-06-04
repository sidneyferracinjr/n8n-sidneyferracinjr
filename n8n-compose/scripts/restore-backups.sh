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

# Verificar se os arquivos de backups foram fornecidos
if [ -z "$1" ]; then
  echo "Uso: $0 <arquivo-backups.sql[.gz]> [--force]"
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

# Criar um container temporário para restauração
TEMP_CONTAINER_NAME="postgres_restore_temp"
echo "Criando container temporário para restauração..."

docker run --rm --name "$TEMP_CONTAINER_NAME" \
  -e POSTGRES_USER="$DB_POSTGRESDB_USER" \
  -e POSTGRES_PASSWORD="$DB_POSTGRESDB_PASSWORD" \
  -e POSTGRES_DB="$DB_POSTGRESDB_DATABASE" \
  -v "$(pwd)/$BACKUPS_FILE:/backup.sql.gz" \
  postgres:16.2 bash -c "
    echo 'Iniciando restauração...';
    if [[ '/backup.sql.gz' == *.gz ]]; then
      gunzip -c /backup.sql.gz | psql -h $DB_POSTGRESDB_HOST -p $DB_POSTGRESDB_PORT -U $DB_POSTGRESDB_USER -d $DB_POSTGRESDB_DATABASE;
    else
      psql -h $DB_POSTGRESDB_HOST -p $DB_POSTGRESDB_PORT -U $DB_POSTGRESDB_USER -d $DB_POSTGRESDB_DATABASE < /backup.sql.gz;
    fi
    echo 'Restauração concluída.';
  "

echo "Restauração dos backups '$BACKUPS_FILE' concluída com sucesso!"