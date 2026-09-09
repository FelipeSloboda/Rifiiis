# ADR-017 — Sem custódia: o Pix cai direto na conta do operador

**Status:** aceita · **Data:** 2026-08 · **Contexto:** PRD R10, SPEC §7

## Contexto

O documento definia como cobrar, mas não **para onde o dinheiro vai**. Sem decisão explícita, ela
seria tomada por omissão na semana 2, por quem estivesse escrevendo o adapter do PSP — e o padrão
do mercado é custodiar.

## Decisão

**A plataforma não custodia dinheiro de terceiro.** A cobrança é emitida sempre com o operador
como recebedor. O Pix do comprador cai direto na conta dele no PSP. A plataforma cria a cobrança,
acompanha o pagamento e atribui os números — o dinheiro nunca passa por conta da bit4devs.

## Alternativa recusada

**Conta da plataforma com repasse (escrow).** É o modelo mais comum, e traria controle sobre o
estorno — que hoje pode falhar por saldo do operador.

## Por quê

Custodiar recurso de terceiro em operação de sorteio aproxima a bit4devs do **risco regulatório
do operador** — mais gravemente do que o percentual sobre arrecadação que a Q5 do PRD já recusa.
Exige licença de instituição de pagamento e controles que o prazo do MVP não comporta.

A decisão troca conveniência operacional por **redução de superfície regulatória**. Não é a
escolha mais confortável; é a que mantém o fornecedor fora da exposição do cliente.

## Consequências

| Consequência | Natureza |
|---|---|
| Estorno **pode falhar de verdade** por saldo do operador | Direta e cara — gerou o ADR-18 (`ESTORNO_PENDENTE`) |
| Não há receita por percentual sobre arrecadação | Limita o modelo comercial à licença/mensalidade |
| Titularidade da conta precisa ser conferida contra o CNPJ | BR-141, BR-142 |
| Publicação bloqueada sem conta verificada | BR-144 |
| Split e afiliados (R18) reabrem esta discussão | Empurrado para P2 |
| Reduz o custo de venda | O operador não confia faturamento a nós |

## O que invalidaria esta decisão

Se a plataforma vier a operar múltiplos operadores com repasse automático (R16), a custódia
volta à mesa — mas aí acompanhada da licença que hoje não temos. **Não** reabrir por conveniência
de estorno: o `ESTORNO_PENDENTE` já resolve o problema de forma honesta.
