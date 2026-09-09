# TESTES DE CARGA — k6

## Cenário obrigatório (RNF-02)

**500 req/s no checkout por 60 segundos.**

| Métrica | Alvo |
|---|---|
| Taxa de erro | < 0,5% |
| **Números duplicados** | **0 — inegociável** |
| p95 de latência | dentro do budget do `perf-auditor` |

## Cenários

| # | Cenário | O que estressa |
|:-:|---|---|
| 1 | Checkout sustentado | Alocação sob concorrência |
| 2 | Estoque quase esgotado (1% restante) | Contenção máxima no índice parcial |
| 3 | Expiração em massa (50k) concorrente com alocação | Competição de lock entre worker e API |
| 4 | Construção da árvore de 1M de folhas | Fase 2 (Argon2id em pool) e fase 3 |

> **O cenário 2 é o que mais provavelmente encontra algo.** Com 1% de estoque, todas as
> transações disputam as mesmas poucas linhas — é onde `SKIP LOCKED` prova o valor ou falha.

## Verificação que não é de performance

Ao fim de cada execução, checar no banco:

```sql
SELECT numero, COUNT(*) FROM numero_sorte
WHERE campanha_id = $1 AND status <> 'DISPONIVEL'
GROUP BY numero HAVING COUNT(*) > 1;
```

**Zero linhas.** Qualquer resultado aqui é falha de RNF-01, independentemente da latência — e a
latência deixa de importar.

## Estado

Scripts não escritos. Serão criados em E10 (item 60 do [BACKLOG](../../backlog/BACKLOG.md)).
