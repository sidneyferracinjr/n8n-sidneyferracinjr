
# n8n-sidneyferracinjr

Este repositório contém a infraestrutura Docker personalizada para o **n8n**, uma plataforma de automação de workflows. O projeto é voltado para fácil deploy, automação de backups e restauração de dados, utilizando Docker Compose.

## 📦 Estrutura do Projeto

```
n8n-compose/
├── .env               # Variáveis de ambiente (não versionado)
├── .env.example       # Exemplo de variáveis de ambiente
├── compose.yaml       # Arquivo principal do Docker Compose
├── Dockerfile.n8n_backup  # Imagem personalizada para o contêiner de backup
├── init-data.sh       # Script para inicialização do banco de dados
└── scripts/
    ├── backup.sh          # Script de backup automatizado
    ├── cleanup-backups.sh # Script para limpar backups antigos
    └── restore-backups.sh # Script de restauração manual
```

## 🚀 Como usar

### 1. Clonar o repositório

```bash
git clone https://github.com/seuusuario/n8n-sidneyferracinjr.git
cd n8n-sidneyferracinjr/n8n-compose
```

### 2. Configurar variáveis de ambiente

Copie o arquivo `.env.example` para `.env` e edite os valores conforme necessário:

```bash
cp .env.example .env
```

Variáveis como:

- `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`
- `N8N_HOST`, `WEBHOOK_TUNNEL_URL`
- `BACKUP_CRON_EXPRESSION`, etc.

### 3. Subir os serviços

```bash
docker-compose up -d --build
```

### 4. Acessar a aplicação

Acesse via navegador:

```
https://<N8N_HOST>
```

## 🗃️ Backups

### Backup Automático

Um contêiner cron executa backups automaticamente com base na expressão definida em `BACKUP_CRON_EXPRESSION`.

### Backup Manual

Execute manualmente:

```bash
./scripts/backup.sh
```

### Restaurar Backup

Para restaurar:

```bash
./scripts/restore-backups.sh <nome_do_arquivo_de_backup>
```

### Limpeza de Backups

Para limpar backups antigos:

```bash
./scripts/cleanup-backups.sh
```

## 🛠 Serviços

O `compose.yaml` define os seguintes serviços:

- **n8n** – Plataforma de automação
- **postgres** – Banco de dados relacional
- **n8n_backups** – Serviço para gerenciar backups
- **traefik** – (Opcional) Proxy reverso com suporte a HTTPS
- **cloudflared** – (Opcional) Proxy seguro via Cloudflare Tunnel

## 🧱 Base Docker

Contêiner de backup é construído com base no `Dockerfile.n8n_backup` e é responsável por:

- Executar scripts shell do diretório `scripts/`
- Conectar ao volume de dados
- Interagir com o PostgreSQL

## 📋 Observações

- Certifique-se de ter o `Docker` e `Docker Compose` instalados.
- Use HTTPS e autenticação básica (`BASIC_AUTH`) para segurança.
- O `init-data.sh` pode ser usado para inicializar dados de forma personalizada, se necessário.

## 📄 Licença

Este projeto está licenciado sob os termos da licença MIT.
