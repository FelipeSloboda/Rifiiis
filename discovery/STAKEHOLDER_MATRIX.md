---
id: stakeholder-matrix
etapa: 1
data: 2026-09-08
status: done
---

# STAKEHOLDER MATRIX — Dream RI

## Poder × Interesse

| Stakeholder | Poder | Interesse | Estratégia | Quem fala com ele |
|---|:-:|:-:|---|---|
| **Operador (cliente)** | Alto | Alto | **Gerir de perto** — decide escopo, paga, opera | Wanderson |
| **Órgão autorizador** | Alto | Médio | **Manter satisfeito** — a autorização é pré-requisito de publicação | Operador |
| **PicPay (PSP)** | Alto | Baixo | **Manter satisfeito** — aprovação da conta é marco duro D+7 | Operador |
| **Apple / Google** | Alto | Baixo | **Manter satisfeito** — podem rejeitar app de sorteio; mitigado pela web | Eng |
| **ACT (carimbo do tempo)** | Médio | Baixo | **Monitorar** — contrato é marco duro D+7 | Eng |
| **Comprador** | Baixo | Alto | **Manter informado** — é quem usa a prova | Produto |
| **Auditor / imprensa** | Baixo | Alto | **Manter informado** — o verificador público é feito para ele | Produto |
| **CAIXA (Loteria Federal)** | Alto | Nenhum | **Monitorar** — fonte de aleatoriedade; indisponibilidade trava apuração | Eng |
| **bit4devs** | Alto | Alto | **Gerir de perto** — fornecedor; ADR-17 limita a exposição regulatória | — |

## Os três que param o cronograma

PRD §10 nomeia marcos duros em D+7, todos com stakeholder externo e **nenhum acelerável por IA**:

| Marco | Stakeholder | Se falhar |
|---|---|---|
| Conta PicPay aprovada | PicPay | Sem checkout — E04 para |
| ACT contratada | Autoridade de carimbo | Sem commitment — E05 para, e a tese cai |
| Contas de loja ativas | Apple/Google | E09 para; web mobile-first é o plano B |

> Os dois primeiros não têm plano B. O terceiro tem, e é por isso que a web mobile-first é
> requisito, não conveniência (RNF-16).

## Conflito de interesse a vigiar

O **operador** é cliente *e* é a parte cuja honestidade o sistema verifica. Ele pode pedir
features que enfraqueçam a prova ("dá pra editar o ganhador?", "dá pra tirar aquele número?").
A resposta é arquitetural, não diplomática: não existe caminho de código que produza resultado
sintético (SPEC §7) e a retificação exige causa fechada, dupla autorização e preserva a original
(ADR-13). O produto protege o operador honesto **de si mesmo** e do desonesto que virá depois.
