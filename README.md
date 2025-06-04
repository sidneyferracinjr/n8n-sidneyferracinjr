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

## Restaurando backups do banco de dados

Para restaurar um backup do banco de dados PostgreSQL, siga os passos abaixo:

1. **Coloque o arquivo de backup no diretório correto**  
   Certifique-se de que o arquivo de backup (`.sql` ou `.sql.gz`) esteja no diretório `n8n-compose/backups`.  
   Exemplo: `n8n-compose/backups/meu_backup.sql.gz`.

2. **Dê permissão de execução ao script de restauração**  
   Caso ainda não tenha feito isso, execute o comando abaixo para garantir que o script tenha permissão de execução:  
   ```sh
   chmod +x n8n-compose/scripts/restore-backups.sh
   ```

3. **Execute o script de restauração**  
   Use o comando abaixo para restaurar o backup, substituindo `<nome-do-arquivo>` pelo nome do arquivo de backup:  
   ```sh
   ./n8n-compose/scripts/restore-backups.sh n8n-compose/backups/<nome-do-arquivo>
   ```

   Exemplo:  
   ```sh
   ./n8n-compose/scripts/restore-backups.sh n8n-compose/backups/meu_backup.sql.gz
   ```

4. **Confirmação (opcional)**  
   O script solicitará uma confirmação antes de sobrescrever os dados existentes. Para ignorar a confirmação, adicione a flag `--force`:  
   ```sh
   ./n8n-compose/scripts/restore-backups.sh n8n-compose/backups/meu_backup.sql.gz --force
   ```

> **Nota:** O script utiliza as variáveis de ambiente configuradas no arquivo `.env` para se conectar ao banco de dados. Certifique-se de que o arquivo `.env` está configurado corretamente antes de executar o script.

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

---

# n8n Backup and Restore

Este repositório contém scripts e configurações para gerenciar backups e restaurações do banco de dados PostgreSQL utilizado pelo n8n. Abaixo, você encontrará uma explicação de cada script, instruções de uso e pré-requisitos.

---

## 📜 Scripts

### 1. `backup.sh`
- **Descrição**: Realiza o backup do banco de dados PostgreSQL, compacta o arquivo e o criptografa usando OpenSSL.
- **Saída**: O backup é salvo no diretório `/backups` com o formato `n8n_backup_<timestamp>.sql.gz.enc`.
- **Logs**: As mensagens de execução são registradas em `/var/log/backup.log`.

### 2. `cleanup-backups.sh`
- **Descrição**: Remove backups antigos com base no período de retenção configurado pela variável de ambiente `BACKUP_RETENTION_DAYS` (padrão: 7 dias).
- **Opções**:
  - `--dry-run`: Simula a remoção, listando os arquivos que seriam apagados sem realmente excluí-los.

### 3. `restore-backups.sh`
- **Descrição**: Restaura um backup do banco de dados PostgreSQL a partir de um arquivo `.sql` ou `.sql.gz`.
- **Uso**:
  - Solicita confirmação antes de sobrescrever os dados existentes, a menos que a flag `--force` seja usada.

### 4. `init-data.sh`
- **Descrição**: Inicializa o banco de dados PostgreSQL, criando o banco e o usuário não-root, caso ainda não existam.

---

## ⚙️ Pré-requisitos

1. **Docker**: Certifique-se de que o Docker está instalado no sistema.
   - [Instalar Docker](https://docs.docker.com/get-docker/)
2. **Docker Compose**: Necessário para gerenciar os serviços definidos no `compose.yaml`.
   - [Instalar Docker Compose](https://docs.docker.com/compose/install/)
3. **Permissões de pasta**:
   - O diretório `/backups` deve existir e ter permissões de leitura e escrita para o usuário que executa os scripts.

---

## 🛠️ Instruções

### 1. **Executar backup manualmente**
Para realizar um backup manual, execute o script `backup.sh`:

```bash
./backup.sh
```