# n8n + PostgreSQL + Traefik Compose

Este projeto orquestra o [n8n](https://n8n.io/) com banco de dados PostgreSQL e proxy reverso Traefik usando Docker Compose.

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

- Acesse: `http://localhost:5678` (ou pelo domínio configurado)
- Usuário e senha padrão: configure conforme necessário no `.env`.

---

## Acessando o Dashboard do Traefik

- Acesse: `https://traefik.SEUDOMINIO.com`  
- Usuário e senha definidos nas variáveis `TRAEFIK_DASHBOARD_USER` e `TRAEFIK_DASHBOARD_PASSWORD_HASH` no `.env`.

---

## Backups do banco de dados

O serviço `n8n_backups` está configurado para gerar backups automáticos do banco PostgreSQL diariamente às 10h da manhã.

Os arquivos de backups são salvos no diretório `n8n-compose/backups`.

### Executando backups manualmente

Para rodar o backups manualmente, execute:

```sh
docker exec -it n8n_backups /backups.sh
```

---

## Limpeza de backups antigos

O script `cleanup-backups.sh` remove backups antigos, mantendo apenas os 7 mais recentes.

Para executar manualmente:

```sh
docker exec -it n8n_backups /cleanup-backups.sh
```

---

## Restaurando backups

### Restaurando com script

Para facilitar a restauração de backups do banco PostgreSQL, utilize o script `restore-backups.sh`:

1. Dê permissão de execução ao script (apenas na primeira vez):

   ```sh
   chmod +x n8n-compose/restore-backups.sh
   ```

2. Execute o script informando o caminho do arquivo de backups `.sql` ou `.sql.gz`:

   ```sh
   ./n8n-compose/restore-backups.sh /caminho/para/backups.sql.gz
   ```

O script irá restaurar o backups diretamente no banco de dados do container `postgres` usando as variáveis de ambiente já configuradas.

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

- **Traefik:**  
  Os certificados TLS ficam no volume `traefik_data`.

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

---

> Dúvidas ou sugestões? Abra uma issue ou entre em contato.