# UPS Annex D Dynamic Specification Form

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

## Modelo de dados novo

- `fields`: cadastro dinamico de campos (com secao, tipo, enum e default opcional)
- `equipments`: registro do equipamento/token
- `field_profiles` + `field_profile_fields`: perfis reutilizaveis com conjuntos de campos
- `equipment_enabled_fields`: campos habilitados por equipamento/token
- `equipment_field_values`: valores por equipamento e campo

## Fluxo de cliente com perfil

1. Acesse `/admin/clients/new`.
2. Informe nome e contato.
3. Escolha um perfil salvo (opcional) para preencher os campos habilitados.
4. Ajuste manualmente os checkboxes se necessario.
5. Opcionalmente informe um nome em "Salvar selecao atual como novo perfil".
6. Gere o token; o formulario desse cliente exibira somente os campos habilitados.

## Temas visuais do formulario

- O projeto possui dois temas: `Soft` (padrao) e `Vextrom`.
- A troca e feita no seletor `Tema` no topo da tela.
- A preferencia fica salva em `localStorage` na chave `app_theme` (`soft` ou `vextrom`).
- Os tokens visuais (cores, sombras, bordas, espacamentos) ficam centralizados em `src/public/css/app.css`:
  - bloco `:root, :root[data-theme="soft"]`
  - bloco `:root[data-theme="vextrom"]`

## Seed do Anexo D

- O seed oficial esta em `src/schema/annexD.fields.seed.js`
- `npm run db:seed` aplica migracao, popula/atualiza todos os campos do Anexo D e cria um equipamento de exemplo
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

Observacao: endpoints mutaveis exigem sessao admin.
