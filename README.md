# UPS Annex D Web Form (Bootstrap 5 + Express + PostgreSQL)

Projeto full-stack em Node.js para formulario wizard baseado na Purchase Table do Anexo D (IEC 62040-3), com:

- Wizard por secoes (Bootstrap 5)
- Persistencia em PostgreSQL
- Salvar rascunho e continuar por token URL
- Tela de resumo
- Export JSON
- Geracao de PDF
- Envio de e-mail com resumo HTML + PDF
- CSRF + sanitizacao + rate limit no endpoint de e-mail
- Interface bilingue: Portugues e Ingles

## 1. Requisitos

- Node.js 18+ (recomendado 20+)
- npm
- PostgreSQL 14+

## 2. Instalacao e execucao

1. Instale dependencias:

```bash
npm install
```

2. Crie o `.env`:

```bash
cp .env.example .env
```

3. Rode migracao e seed opcional:

```bash
npm run db:migrate
npm run db:seed
```

4. Inicie com:

```bash
npm run dev
```

Aplicacao: `http://localhost:3000`

## 3. Idioma (PT/EN)

- O idioma padrao e Portugues (`pt`).
- A escolha pode ser feita no topo da tela com os botoes `PT` e `EN`.
- A preferencia fica salva em cookie (`lang`).

## 4. Variaveis de ambiente (.env)

- `PORT`
- `APP_BASE_URL`
- `DATABASE_URL`
- `DATABASE_SSL`
- `ADMIN_USER`
- `ADMIN_PASS`
- `ADMIN_SESSION_SECRET`
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASS`
- `SMTP_FROM`

## 5. Area administrativa

- URL: `/admin/login`
- Funcionalidades:
  - login com usuario e senha
  - listagem de tokens cadastrados
  - exibicao de comprador e contato do comprador
  - exclusao de token

## 6. Estrutura

- `src/app.js`: servidor Express + endpoints
- `src/i18n/index.js`: mensagens de interface e erros (PT/EN)
- `src/schema/annexD.purchaseTable.json`: schema ativo do formulario
- `src/views`: templates EJS (wizard/review)
- `src/db/index.js`: conexao com PostgreSQL
- `scripts/migrate.js`: cria tabelas
- `scripts/seed.js`: gera uma submissao demo
