# ADR-003 — `FOR UPDATE SKIP LOCKED` para alocação de números

**Status:** aceita · **Contexto:** SPEC §4

## Decisão

A alocação usa `SELECT ... FOR UPDATE SKIP LOCKED` sobre um índice parcial de números
`DISPONIVEL`, ordenado pela coluna `ordem` (pré-embaralhada na publicação).

## Alternativa recusada

**Lock distribuído em Redis** (Redlock ou equivalente).

## Por quê

O Postgres **já garante** a exclusão mútua que precisamos, na mesma transação que grava o
resultado. Um lock em Redis adicionaria:

- mais um componente no caminho crítico da venda;
- uma janela entre "adquiri o lock" e "gravei no banco" — onde uma falha deixa número travado;
- a necessidade de expiração de lock, que reintroduz o problema que o lock resolvia.

`SKIP LOCKED` tem a propriedade certa para este caso: linha travada por outra transação **não
bloqueia** — vai para a próxima rodada. Isso transforma contenção em throughput, em vez de fila.

## Consequências

- **Postgres é requisito, não preferência.** SQLite não reproduz `SKIP LOCKED` — os testes de
  integração usam Testcontainers com Postgres real (SPEC §11).
- O worker de expiração também usa `SKIP LOCKED`, em lotes de 5.000, para não competir com a
  alocação num pico.
- O índice de alocação é **parcial** (`WHERE status = 'DISPONIVEL'`): mantém o índice pequeno
  conforme a campanha vende.

## A armadilha que este ADR não resolve sozinho

`SKIP LOCKED` garante que duas transações não peguem a mesma linha. **Não** garante que o teste
de concorrência tenha poder de detecção — um teste que nunca falhou pode estar medindo
serialização acidental do ambiente. Por isso o [ADR-012](ADR-012-verificacao-independente-ia.md)
exige rodá-lo contra uma implementação deliberadamente ingênua e **ver o teste falhar**.
