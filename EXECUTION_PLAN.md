---
id: execution-plan
etapa: 10
data: 2026-09-08
status: done
---

# PLANO DE EXECUÇÃO — Dream RI

## Estado atual: nada começou

| Pré-requisito | Estado |
|---|:-:|
| Repositório de código | ❌ |
| Board Jira `DRI` | ❌ |
| Conta PicPay | ❌ |
| ACT contratada | ❌ |
| Contas de loja | ❌ |
| Fonte secundária da Federal nomeada | ❌ |

**Nenhum item de engenharia pode começar antes dos dois primeiros.** Os quatro seguintes bloqueiam
épicos específicos, e três deles são espera por terceiro.

---

## Sequência de arranque (D0 → D+7)

| Dia | Ação | Dono | Bloqueia |
|:-:|---|---|---|
| D0 | Iniciar aprovação da conta PicPay | Operador | E04 |
| D0 | Iniciar contratação da ACT | Operador/Eng | **E05 e a tese** |
| D0 | Abrir contas Apple/Google | Eng | E09 |
| D+1 | Criar repositório com a estrutura da SPEC §1 | Eng | E01 |
| D+1 | Criar board `DRI` e importar o [BACKLOG](backlog/BACKLOG.md) | Eng | esteira |
| D+1 | **Corrigir o PRD** com o de-para de IDs (D1) | Produto | coerência |
| D+2 | E01 começa | Eng | — |
| D+10 | Nomear a fonte secundária da Federal | Eng | E06 |

> Os três primeiros são **em D0, não em D+5**. São espera por terceiro, e o PRD já os declara
> como marcos que param o cronograma.

---

## Como um ticket anda

Esteira de 20 etapas em [AI_WORKFLOW.md](AI_WORKFLOW.md). Resumo das raias:

```
lane:backlog → lane:pronto-p-dev → lane:em-dev → lane:review → lane:done
                      ↑                                ↓
                 po-reviewer                    gates bloqueantes
```

## Cadência

| Ritual | Quando | Saída |
|---|---|---|
| Revisão de invariante | Fim de E03, E05, E06 | Aprovação humana explícita (ADR-012) |
| Checkpoint de marco | D+7, D+21, D+28, D+35, D+42 | Vai / não vai |
| Run log | Por sessão de trabalho | `run-logs/YYYY-MM-DD-*.md` |

## Os três momentos em que o plano para para pensar

**D+7 — marcos duros.** Se PicPay, ACT ou lojas não fecharem, o cronograma é renegociado. Não é
"seguimos e vemos" — é parada formal.

**D+21 — a tese é testada.** Apuração ensaiada verificada por terceiro usando só o verificador
público. Se um estranho não consegue conferir sozinho, o produto não existe, por mais correto que
o código esteja.

**D+35 — feature freeze.** Nada novo entra. O app é submetido; a fila da loja começa a correr.

## O que fazer quando um gate bloquear

| Situação | Ação |
|---|---|
| Teste de concorrência falha intermitente | **Investigar, nunca skipar.** É o gate que existe para isso |
| Vetor externo não bate | A implementação está errada, não o vetor |
| ACT indisponível no congelamento | Bloqueia e alerta. Não improvisar carimbo |
| Fontes da Federal caem | `ApuracaoBloqueada` + entrada manual com dois responsáveis |
| Loja rejeita o app | Web mobile-first já está no ar. Responder e resubmeter |
