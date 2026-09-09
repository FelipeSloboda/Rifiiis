# PADRÃO DE ESCRITA DE ISSUE — Dream RI

Vale o canônico do workspace: [`plan-project/PADRAO_ESCRITA_JIRA.md`](../PADRAO_ESCRITA_JIRA.md).

Este arquivo registra apenas o **delta** do projeto DRI.

## Prefixo e board

- Chave: `DRI-###`
- Board: `DRI` — **ainda não criado** (pendência 2 do [INDEX](INDEX.md))

## Labels obrigatórias

| Label | Valores |
|---|---|
| `epic:` | `E01`..`E10` |
| `lane:` | `backlog` · `pronto-p-dev` · `em-dev` · `review` · `done` |
| `req:` | `R0`, `R0.5`, `R1`… conforme [CONVENCOES-IDS](CONVENCOES-IDS.md) |
| `critico` | quando a task toca R2, R4 ou R6 |

## Seções obrigatórias no corpo

Os três blocos de [TASK_AUTHORING_RULES](TASK_AUTHORING_RULES.md) — Contexto, Escopo, Pronto
quando — mais a DoD colada.

## Delta em relação ao canônico

| Item | Regra do DRI |
|---|---|
| Vetores de teste | Task com label `critico` **precisa nomear a fonte externa** (RFC) |
| Cenário Gherkin | Link para o `.feature`, nunca cópia do texto do critério |
| PII | Task que toca PII aponta o campo no inventário da SPEC §9 |
| Contrato | Mudança não-aditiva exige ADR linkado |

## Limite de tamanho

A descrição estoura em ~65k de ADF, e o markdown infla cerca de 2,4× na conversão. Análise longa
vai em **comentário**, não na descrição.
