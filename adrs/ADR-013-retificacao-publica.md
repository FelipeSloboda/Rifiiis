# ADR-013 — Apuração errada se corrige por retificação pública, nunca por edição

**Status:** aceita · **Data:** 2026-08 · **Contexto:** PRD R6, SPEC §6

## Contexto

A apuração é irreversível por construção, e isso é a tese do produto. Mas **irreversível não pode
significar incorrigível**. A apuração pode rodar sobre insumo errado:

- fonte primária devolvendo a extração de outra data;
- regra do regulamento cadastrada errada;
- extração oficial posteriormente anulada pela CAIXA.

## Decisão

Existe **retificação**, com três amarras: causa de **lista fechada**, **dupla autorização** por
operadores distintos, e **preservação pública da apuração original**. A retificada passa a ser a
vigente; a original continua visível.

## Alternativa recusada

**Imutabilidade absoluta, sem caminho de correção.**

## Por quê

Imutável sem saída **não é rigor, é decisão por omissão**. Os dois lados perdem:

- o **operador honesto** cuja apuração rodou sobre extração errada fica sem caminho;
- o **operador desonesto** ganha o argumento perfeito: "o sistema travou, não fui eu".

A retificação com causa fechada, dupla autorização e original preservada corrige o erro legítimo
**sem** abrir espaço para fraude — porque nenhuma das três amarras pode ser satisfeita
silenciosamente.

## O que a retificação nunca pode fazer

| Proibido | Por quê |
|---|---|
| Apagar a apuração original | Ela é a prova de que houve correção, não ocultação |
| Ser autorizada por um só operador | Reduz a ação unilateral a um clique |
| Ter causa livre em texto | Causa fechada impede racionalizar qualquer coisa |
| Rodar sem registro em auditoria | O ato de corrigir é ele próprio auditável |

## Consequências

- A máquina de estados tem `APURADA → APURADA`, não um estado novo (ver
  [STATE-MACHINES](../models/state-machines/STATE-MACHINES.md)).
- A tela pública mostra resultado vigente **e** original, com a causa (R9.6).
- Retificação é métrica de alarme: uma já é sinal, duas é defeito de insumo, não azar.
