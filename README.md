# APP-FORM-UPS-IEC

Projeto full-stack em Node.js (Express + EJS + PostgreSQL) para especificacao de UPS baseada no IEC 62040-3 (Anexo D), com:

- Campos dinamicos por secao
- Campos habilitados por cliente/token
- Perfis salvos de campos para reutilizacao
- CRUD de campos (`text`, `number`, `enum`, `boolean`, `time`, `dimension`)
- `hasDefault` + `defaultValue` por campo
- Precedencia de valor no formulario: `salvo > default > vazio`
- APIs de fields e specification

## Requisitos

- Node.js 18+
- PostgreSQL 14+

## Execucao

```bash
npm install
npm run db:migrate
npm run db:seed
npm run dev
```

Aplicacao: `http://localhost:3000`

## Comandos de manutenção APP via NPM

- `npm run dev`: sobe a aplicacao em modo desenvolvimento (`nodemon`).
- `npm run start`: sobe a aplicacao em modo normal.
- `npm run db:migrate`: aplica as migracoes do banco.
- `npm run db:backup-database`: gera backup `.sql` em `dados/backups`.
- `npm run db:restore-database`: restaura o backup mais recente de `dados/backups`.
- `npm run db:seed`: aplica seed dos campos (schema dinamico).
- `npm run db:reset`: limpa tabelas principais e reinicia IDs.
- `npm run db:reset-schema`: remove e recria o schema `public` (limpeza estrutural total para restore).
- `npm run db:restore-clean`: executa `db:reset-schema` + `db:restore-database`.
- `npm run db:reseed`: executa `db:reset` + `db:seed`.
- `npm run db:seed:purchase-profile`: executa seed do perfil de compra.
- `npm run api:key:create -- --name "integracao-x" --scopes "fields:read,spec:read,spec:write"`: cria API key.
- `npm run api:key:list`: lista API keys cadastradas.
- `npm run api:key:revoke -- 1`: revoga API key por ID.
- `npm run admin:sessions:clear`: invalida todas as sessoes admin ativas.
- `npm run admin:public-limit:reset`: reseta o contador de limite do modulo publico (IP/sessao navegador).
- `npm run teste-cliente`: executa teste de cadastro em lote de clientes (`dados/teste/stress-client-registrations.js`).
- `npm run teste-perfil-form`: executa teste de cadastro em lote de perfis de formulario (`dados/teste/stress-profile-form-registrations.js`).

## Backup e restore do banco

- Backup:
  - `npm run db:backup-database`
- Restore do ultimo backup (mais recente):
  - `npm run db:restore-database`
- Restore de arquivo especifico:
  - `npm run db:restore-database -- "dados/backups/db-backup-2026-03-07T03-43-17-589Z.sql"`
- Restore limpo (remove schema e depois restaura):
  - `npm run db:restore-clean`

## Modelo de dados novo

- `fields`: cadastro dinamico de campos (com secao, tipo, enum e default opcional)
- `equipments`: registro do equipamento/token
- `field_profiles` + `field_profile_fields`: perfis reutilizaveis com conjuntos de campos
- `equipment_enabled_fields`: campos habilitados por equipamento/token
- `equipment_field_values`: valores por equipamento e campo
- `equipment_documents`: anexos PDF por equipamento/token

## Fluxo de cliente com perfil

1. Acesse `/admin/clients/new`.
2. Informe nome e contato.
3. Escolha um perfil salvo (opcional) para preencher os campos habilitados.
4. Ajuste manualmente os checkboxes se necessario.
5. Opcionalmente informe um nome em "Salvar selecao atual como novo perfil".
6. Gere o token; o formulario desse cliente exibira somente os campos habilitados.

## Gestao de perfis de formulario

- Acesse `/admin/profiles` para criar, editar e excluir perfis de anexo formulario.
- Acesse `/admin/tokens/:id/config` para ajustar campos especificos de um cliente ja criado.
- Um perfil pode ser aplicado por cliente e os campos habilitados podem ser personalizados por cliente.

## Anexos PDF

- No final do formulario de especificacao, e possivel anexar PDFs (ex.: desenho unifilar e trifilar).
- Limite: ate 10 documentos por token, com ate 10MB por arquivo.
- Apenas PDF e aceito.
- Os arquivos sao salvos em `dados/docs` (na raiz da aplicacao).
- O sistema salva no banco o link externo do arquivo, baseado em `APP_BASE_URL`.
- Em producao, use `APP_BASE_URL` sem porta interna (ex.: `https://form.seudominio.com`).

## Temas visuais do formulario

- O projeto possui dois temas: `Soft` (padrao) e `Vextrom`.
- A troca e feita no seletor `Tema` no topo da tela.
- A preferencia fica salva em `localStorage` na chave `app_theme` (`soft` ou `vextrom`).
- Os tokens visuais (cores, sombras, bordas, espacamentos) ficam centralizados em `src/public/css/app.css`:
  - bloco `:root, :root[data-theme="soft"]`
  - bloco `:root[data-theme="vextrom"]`

## Seed do Anexo D

- O seed oficial esta em `src/schema/annexD.fields.seed.js`
- `npm run db:seed` popula/atualiza todos os campos do Anexo D
- O servidor tambem chama `seedAnnexDFields()` no startup para garantir estrutura base

## Como adicionar/editar campos

1. Acesse `/admin/fields`
2. Crie ou edite o campo informando:
   - `key` unica (slug)
   - `section`
   - `fieldType`
   - `enumOptions` (se `enum`)
   - toggle `Usar valor padrao` (`hasDefault=true`)
   - `defaultValue`
3. Salve. O campo aparece automaticamente no formulario de especificacao.

## Regra de default no formulario

No carregamento da especificacao:

1. Se existe valor salvo para `(equipmentId, fieldId)`, usa esse valor.
2. Senao, se `hasDefault=true`, usa `defaultValue` e marca badge `padrao`.
3. Senao, deixa vazio.

Ao salvar vazio, o valor salvo e removido e a regra volta para default/vazio.

## APIs principais

- `GET /fields?section=...`
- `POST /fields`
- `PUT /fields/:id`
- `DELETE /fields/:id`
- `GET /equipment/:id/specification`
- `PUT /equipment/:id/specification`

Autenticacao da API:

- Header: `Authorization: Bearer <API_KEY>` (ou `X-API-Key: <API_KEY>`).
- Escopos:
  - `fields:read`
  - `fields:write`
  - `spec:read`
  - `spec:write`
- Sessao admin valida tambem tem acesso (fallback para uso interno no painel).

## Documentacao da API

- Arquivo HTML da documentacao: `api.html`
