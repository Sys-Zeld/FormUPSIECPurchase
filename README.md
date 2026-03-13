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
npm run db:seed:default
npm run dev
```

Aplicacao: `http://localhost:3000`

## Comandos de manutenÃ§Ão APP via NPM

- `npm run dev`: sobe a aplicacao em modo desenvolvimento (`nodemon`).
- `npm run start`: sobe a aplicacao em modo normal.
- `npm run db:migrate`: aplica as migracoes do banco.
- `npm run db:backup-database`: gera backup `.sql` em `dados/backups`.
- `npm run db:restore-database`: restaura o backup mais recente de `dados/backups` (limpa o schema `public` antes por padrao).
- `npm run db:seed`: aplica seed dos campos (schema dinamico).
- `npm run db:seed:default`: aplica seed dos campos e cria/atualiza o perfil padrÃ£o `PADRÃO CHLORIDE`.
- `npm run db:reset`: limpa tabelas principais e reinicia IDs.
- `npm run db:reset-schema`: remove e recria o schema `public` (limpeza estrutural total para restore).
- `npm run db:restore-clean`: executa `db:reset-schema` + `db:restore-database`.
- `npm run db:reseed`: executa `db:reset` + `db:seed`.
- `npm run db:seed:default`: aplica `db:seed` + `node scripts/seed-profile-purchase.js`.
- `npm run api:key:create -- --name "integracao-x" --scopes "fields:read,spec:read,spec:write"`: cria API key.
- `npm run api:key:list`: lista API keys cadastradas.
- `npm run api:key:revoke -- 1`: revoga API key por ID.
- `npm run api:key:delete -- 1`: deleta API key por ID.
- `npm run admin:sessions:clear`: invalida todas as sessoes admin ativas.
- `npm run admin:public-limit:reset`: reseta o contador de limite do modulo publico (IP/sessao navegador).
- `npm run token:set-sent -- --token=<TOKEN>`: forÃ§a status do token para `sent` (uso de teste).
- `npm run token:set-draft -- --token=<TOKEN>`: forÃ§a status do token para `draft` (uso de teste).
- `npm run teste-cliente`: executa teste de cadastro em lote de clientes (`dados/teste/stress-client-registrations.js` exemplo: 'npm' run teste-cliente -- --count=500 --concurrency=20').
- `npm run teste-perfil-form`: executa teste de cadastro em lote de perfis de formulario (`dados/teste/stress-profile-form-registrations.js`).

### Painel de manutencao admin

- Acesse `/admin/maintenance` para executar comandos de manutencao.
- Esta rota e restrita ao administrador principal (`ADMIN_USER`/`ADMIN_PASS`).
- Nessa tela tambem e possivel cadastrar usuarios admin adicionais para login no painel.

## Exemplos CMD - stress de cliente

```cmd
cd "C:\Users\VitorSuares\OneDrive - Vextrom\Ãrea de Trabalho\ServiÃ§os\Projetos\AppFormUPSIEC\FormUPSIECPurchase"
npm run teste-cliente -- --count=500 --concurrency=20
```

```cmd
npm run teste-cliente -- --count=10000 --concurrency=50
```

## Backup e restore do banco

- Backup:
  - `npm run db:backup-database`
- Restore do ultimo backup (mais recente, com limpeza automatica do schema `public`):
  - `npm run db:restore-database`
- Restore de arquivo especifico:
  - `npm run db:restore-database -- "dados/backups/db-backup-2026-03-07T03-43-17-589Z.sql"`
- Importacao de arquivo `.sql` pela UI:
  - Acesse `/admin/maintenance`
  - Use o bloco **Importar arquivo .sql**
  - O upload apenas importa o arquivo para `dados/backups` e atualiza o catalogo
  - Depois execute o restore pelo botao **Restaurar** na lista de backups
  - Limite atual: `50 MB`
- Restore sem limpar schema antes (avancado):
  - `npm run db:restore-database -- --no-clean`
- Restore limpo (remove schema e depois restaura):
  - `npm run db:restore-clean`
- Timeout do restore:
  - Variavel opcional `DB_RESTORE_TIMEOUT_MS` (padrao: `1200000`, 20 minutos)

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
- Na tela de perfis, use o botao **Perfil com IA** para abrir a pagina dedicada `/admin/profiles/ai`.
- Na pagina dedicada de IA, voce pode:
  - Enviar documento `PDF`, `TXT` ou `Excel` (`.xlsx`/`.xls`)
  - Informar um modelo JSON de perfil
  - Informar instrucoes adicionais para a IA (opcional)
  - Visualizar o prompt final enviado para a IA
  - Gerar JSON com IA (OpenAI), baixar o arquivo ou importar direto para criar um novo perfil
  - Limite de tamanho do documento para IA: `10MB`
  - Em falha de parse JSON, a resposta da IA e exibida com bloco `debug` (payload bruto) para diagnostico

### Variaveis de ambiente para IA (OpenAI)

- `OPENAI_API_KEY`: chave da API OpenAI (obrigatoria para o recurso de IA).
- `OPENAI_MODEL`: modelo usado na geracao (padrao: `gpt-4.1-mini`).
- `OPENAI_BASE_URL`: base da API (padrao: `https://api.openai.com/v1`).
- `OPENAI_MAX_OUTPUT_TOKENS`: tokens de saida por tentativa (padrao: `8000`).
- `OPENAI_MAX_OUTPUT_RETRIES`: tentativas adicionais em caso de truncamento por tokens (padrao: `2`).
- `OPENAI_MAX_OUTPUT_TOKENS_CAP`: limite maximo de tokens por tentativa com escalonamento (padrao: `20000`).

## Anexos PDF

- No final do formulario de especificacao, e possivel anexar PDFs (ex.: desenho unifilar e trifilar).
- Limite: ate 10 documentos por token, com ate 10MB por arquivo.
- Apenas PDF e aceito.
- Os arquivos sao salvos em `dados/docs` (na raiz da aplicacao).
- O sistema salva no banco o link externo do arquivo, baseado em `APP_BASE_URL`.
- Em producao, use `APP_BASE_URL` sem porta interna (ex.: `https://form.seudominio.com`).

## Temas visuais do formulario

- O projeto possui dois temas: `Soft` e `Vextrom` (padrao).
- A troca e feita no seletor `Tema` no topo da tela.
- A preferencia fica salva em `localStorage` na chave `app_theme` (`soft` ou `vextrom`).
- Os tokens visuais (cores, sombras, bordas, espacamentos) ficam centralizados em `src/public/css/app.css`:
  - bloco `:root, :root[data-theme="soft"]`
  - bloco `:root[data-theme="vextrom"]`

## Seed do Anexo D

- O seed oficial esta em `src/schema/annexD.fields.seed.js`
- `npm run db:seed` popula/atualiza todos os campos do Anexo D
- `npm run db:seed:default` tambÃ©m cria/atualiza o perfil padrÃ£o `PADRÃO CHLORIDE`
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

