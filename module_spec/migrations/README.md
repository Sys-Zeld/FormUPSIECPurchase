As migrations do modulo sao executadas pelo mecanismo principal do projeto em `src/db/migrate.js`, chamando `module_spec/src/migrations.js`.

Modelo atual simplificado:
- familias
- modelos
- variacoes
- definicao de atributos
- atributos por variacao
- mappings de filtro por perfil
