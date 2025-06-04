#!/bin/sh
BACKUPS_DIR="/backups"
DRY_RUN=false
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7} # Padrão de 7 dias caso a variável não esteja definida

# Verifica se o argumento --dry-run foi passado
if [ "$#" -gt 0 ] && [ "$1" = "--dry-run" ]; then
  DRY_RUN=true
  echo "Modo de simulação ativado (--dry-run). Nenhum arquivo será apagado."
fi

echo "Limpando backups antigos com retenção de $RETENTION_DAYS dias..."

if [ -d "$BACKUPS_DIR" ]; then
  # Encontra arquivos mais antigos que o período de retenção (.gz e .gz.enc)
  FILES_TO_REMOVE=$(find "$BACKUPS_DIR" -type f \( -name "n8n_backup_*.sql.gz" -o -name "n8n_backup_*.sql.gz.enc" \) -mtime +$RETENTION_DAYS)

  if [ -z "$FILES_TO_REMOVE" ]; then
    echo "Nenhum backup antigo para remover."
  else
    if [ "$DRY_RUN" = true ]; then
      echo "Os seguintes arquivos seriam removidos:"
      echo "$FILES_TO_REMOVE"
    else
      echo "$FILES_TO_REMOVE" | xargs -I {} rm -- {}
      echo "Backups antigos removidos com sucesso."
    fi
  fi
else
  echo "Erro: Diretório de backups '$BACKUPS_DIR' não encontrado!"
fi
