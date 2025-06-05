# n8n + PostgreSQL Compose

Este projeto orquestra o [n8n](https://n8n.io/) com banco de dados PostgreSQL usando Docker Compose.

---

## Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- Renomeie e configure o arquivo `n8n-compose/.env` conforme necessário (não faça commit deste arquivo).

---

## Subindo o ambiente

No terminal, execute:

```sh
cd n8n-compose
docker compose up -d
```

---

## Acessando o n8n

- Acesse: `http://localhost:5678`  
- Usuário e senha padrão: configure conforme necessário no `.env`.

---

## Backups do banco de dados

O serviço `n8n_backups` está configurado para gerar backups automáticos do banco PostgreSQL diariamente às 3h da manhã.

Os arquivos de backups são salvos no diretório `n8n-compose/backups`.

### Executando backups manualmente

Para rodar o backup manualmente, execute:

```sh
docker exec -it n8n_backups /scripts/backup.sh
```

---

## Limpeza de backups antigos

O script `cleanup-backups.sh` remove backups antigos, mantendo apenas os 7 mais recentes.

Para executar manualmente:

```sh
docker exec -it n8n_backups /scripts/cleanup-backups.sh
```

---

## Restaurando backups

### Restaurando com script

Para facilitar a restauração de backups do banco PostgreSQL, utilize o script `restore-backups.sh`:

1. Dê permissão de execução ao script (apenas na primeira vez):

   ```sh
   chmod +x n8n-compose/scripts/restore-backups.sh
   ```

2. Execute o script informando o caminho do arquivo de backup `.sql` ou `.sql.gz`:

   ```sh
   ./n8n-compose/scripts/restore-backups.sh /caminho/para/backup.sql.gz
   ```

O script irá restaurar o backup diretamente no banco de dados do container `postgres` usando as variáveis de ambiente já configuradas.

---

## Persistência de dados

Os dados dos serviços são armazenados nos seguintes volumes Docker:

- **PostgreSQL:**  
  Os dados do banco ficam no volume `postgres_data`.  
  No host, o Docker armazena os volumes em um diretório gerenciado automaticamente (veja com `docker volume inspect postgres_data`).

- **n8n:**  
  Dados de configuração e workflows ficam no volume `n8n_data`.

- **Backups:**  
  Os arquivos de backups são salvos no diretório `n8n-compose/backups`.

> Para localizar o caminho físico dos volumes no host, use:
>
> ```sh
> docker volume inspect NOME_DO_VOLUME
> ```

> Certifique-se de criar o diretório `n8n-compose/binaryData` antes de subir o ambiente:
> 
> ```sh
> mkdir -p n8n-compose/binaryData
> ```

---

## Observações

- O arquivo `.env` não deve ser versionado (está no `.gitignore`).
- O script `init-data.sh` é executado automaticamente pelo container do PostgreSQL.
- Para ambientes Linux, garanta permissão de execução: `chmod +x n8n-compose/init-data.sh`.

> **Nota:** Este projeto não utiliza mais o Traefik como proxy reverso. Certifique-se de configurar o acesso ao n8n diretamente pelo endereço e porta configurados no Docker Compose.