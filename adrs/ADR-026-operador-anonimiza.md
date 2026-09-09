# ADR-026 — Operador se anonimiza, não se apaga

**Status:** aceita · **Data:** 2026-09-08 · **Contexto:** SPEC §9

> Numeração: registrada primeiro como ADR-23, corrigida para 26 — 23 já era "Node 24 LTS".

## Contexto

O inventário de PII marcava o operador como "chave da organização, não do titular-comprador" —
uma negação sem contrapartida. O operador **é** titular de dados pessoais; o que muda é a base
legal: **execução de contrato** (art. 7º, V), não consentimento. Consequência prática: ele não
revoga o tratamento a pedido enquanto o contrato vigora (art. 18, §2º); o que tem é o direito à
**eliminação ao término do tratamento** (art. 16). Prazo e gatilho, não botão.

## Decisão

Dois tempos, e nenhum deles é `DELETE`:

| Momento | Gatilho | Efeito |
|---|---|---|
| **Desligamento** | Sai da organização | `desativado_em` + revoga todas as sessões na mesma transação |
| **Anonimização** | 5 anos após o desligamento | `email`/`nome` → marcador, segredos zerados, `anonimizado_em` carimbado. `id`, `tenant_id` e **todas as FKs** preservados |

`CHECK (anonimizado_em IS NULL OR desativado_em IS NOT NULL)` — não existe caminho que anonimize
quem ainda pode fazer login. **Não há rota de API que exclua operador.**

## Alternativa recusada

**`DELETE` na linha do operador**, que seria o entendimento ingênuo de "direito ao esquecimento".

## Por quê

`auditoria.operador_id` e `extracao_tentativa.operador_id` são FK. Apagar destruiria **quem
autorizou a entrada manual da extração** — exatamente o controle que o ADR-016 exige (dois
responsáveis distintos).

> Um controle antifraude que se apaga a pedido do fraudador não é controle.

## Consequências

- O e-mail vira índice **parcial** (`WHERE anonimizado_em IS NULL`): libera o endereço após a
  anonimização, permitindo recontratar a mesma pessoa sem colidir com a linha morta.
- A anonimização é registrada em `auditoria` como qualquer transição — o ato de eliminar é ele
  próprio auditável, senão vira a porta dos fundos que o resto do capítulo fecha.
- O prazo de 5 anos é **premissa** (prescrição do art. 206 CC). Se o contrato de operação fixar
  outro, é esse número que muda — [G-17](../requirements/GAP_ANALYSIS.md).

## Distinção que o glossário precisa manter

| Termo | Sujeito | Mecanismo |
|---|---|---|
| **Crypto-shredding** | Comprador | Apagar a DEK do titular |
| **Anonimização** | Operador | `UPDATE` que zera PII preservando FKs |
| **Expurgo** | Sessão | `NULL` em `ip`/`user_agent` em D+90 |
