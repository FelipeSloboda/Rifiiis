---
id: impact-map
etapa: 2
data: 2026-09-08
status: done
---

# IMPACT MAP — Dream RI

**Meta (Why):** *Campanhas apuradas sem intervenção manual e verificadas por terceiro* —
a métrica norte de [METRICS](../product/METRICS.md).

---

## Ator: Comprador (P2)

| Impacto desejado | Entregável | Requisito | Medida |
|---|---|---|---|
| Passa a **verificar** em vez de acreditar | Comprovante com prova de inclusão | R5 | ≥15% verificam |
| Compra sem abandonar | Checkout Pix < 60s, número na hora | R3, R2 | Pix pago ≥55% |
| Volta para conferir o resultado | Painel por código, sem senha | R7.5 | acessos pós-apuração |

**Hipótese mais frágil:** que ele *queira* verificar. Se as verificações ficarem < 5%, o
diferencial não está sendo percebido, e o problema é de comunicação do operador, não de produto.

---

## Ator: Operador (P1)

| Impacto desejado | Entregável | Requisito | Medida |
|---|---|---|---|
| Usa a prova como **argumento de venda** | Link público do verificador | R5, R4 | compartilhamentos |
| Publica sem violar regra | Guarda-corpos na publicação | R8, R10 | zero campanha irregular |
| Age sozinho quando a apuração trava | Tela de apurações com tentativas e reprocesso | R9.3 | tempo até destravar |
| Fecha o loop | Registro de entrega com comprovante | R8.5 | 100% com entrega |

---

## Ator: Auditor / órgão (P3)

| Impacto desejado | Entregável | Requisito | Medida |
|---|---|---|---|
| Recomputa sem nos pedir nada | Snapshot + raiz + carimbo públicos | R4 | verificação de terceiro em D+21 |
| Confia no histórico | Retificação pública quando houver | ADR-13 | zero retificação silenciosa |

---

## Ator: PSP / lojas (externos)

| Impacto desejado | Entregável | Medida |
|---|---|---|
| PicPay aprova a conta | Documentação de conformidade do operador | marco D+7 |
| Lojas não rejeitam o app | Conformidade com política de sorteio + web como plano B | E09 |

> Estes dois não são "impacto" no sentido usual — são **permissões**. A entrega não os
> convence; a documentação do operador sim. Por isso viraram marco duro, não tarefa.

---

## O que decidimos **não** impactar

| Não-alvo | Por quê |
|---|---|
| Aumentar ticket médio | Otimizar isso empurra contra o limite por CPF (R8) |
| Reduzir tempo de publicação | A fricção da publicação é o compliance funcionando |
| Volume de campanhas simultâneas | Multi-tenant é P2; escala aqui é falso progresso |
