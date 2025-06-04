#!/bin/sh
BACKUPS_DIR="/backups"
DRY_RUN=false

# Verifica se o argumento --dry-run foi passado
if [ "$#" -gt 0 ] && [ "$1" = "--dry-run" ]; then
  DRY_RUN=true
  echo "Modo de simulação ativado (--dry-run). Nenhum arquivo será apagado."
fi

echo "Limpando backups antigos..."

if [ -d "$BACKUPS_DIR" ]; then
  # Lista os arquivos que seriam removidos
  FILES_TO_REMOVE=$(ls -tp "$BACKUPS_DIR"/n8n_backup_*.sql.gz | grep -v '/$' | tail -n +8)

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
