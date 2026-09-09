---
id: parity-matrix
etapa: 7
data: 2026-09-08
status: done
---

# MATRIZ DE PARIDADE DE PROVEDORES — Dream RI

A porta `GatewayDePagamento` existia antes da troca de PSP, e foi ela que fez a migração
Asaas/Celcoin → PicPay custar **o adapter, não a arquitetura** (ADR-021). Esta matriz existe para
manter essa propriedade.

## Capacidades exigidas pela porta

| # | Capacidade | Obrigatória | Por quê |
|---|---|:-:|---|
| C1 | Criar cobrança Pix com recebedor terceiro | ✅ | ADR-017 — sem custódia |
| C2 | Copia-e-cola + QR | ✅ | R3 |
| C3 | Consultar status por id da cobrança | ✅ | **ADR-022** — é a fonte de verdade |
| C4 | Webhook de confirmação | ✅ | Gatilho (não fonte de verdade) |
| C5 | Webhook **assinado** | ⚠️ desejável | PicPay não tem — daí a reconsulta |
| C6 | Estorno por API | ✅ | R10, `ESTORNO_PENDENTE` |
| C7 | Verificar titularidade da conta contra CNPJ | ✅ | BR-141 |
| C8 | Idempotência na criação | ✅ | Evita cobrança duplicada |

## Provedores

| Capacidade | **PicPay** (MVP) | Asaas | Celcoin |
|---|:-:|:-:|:-:|
| C1 recebedor terceiro | ✅ | ✅ | ✅ |
| C2 copia-e-cola + QR | ✅ | ✅ | ✅ |
| C3 consulta de status | ✅ | ✅ | ✅ |
| C4 webhook | ✅ | ✅ | ✅ |
| **C5 webhook assinado** | ❌ token estático | ✅ | ✅ |
| C6 estorno por API | ✅ | ✅ | ✅ |
| C7 titularidade | ✅ | ✅ | ⚠️ a confirmar |
| C8 idempotência | ✅ | ✅ | ✅ |

> **Nota de fonte.** As colunas Asaas e Celcoin refletem o levantamento da spec anterior e **não
> foram reverificadas** para esta versão. Antes de qualquer migração, reverificar contra a
> documentação vigente — capacidade de provedor muda sem aviso.

## A ausência que virou decisão de arquitetura

O PicPay **não assina** o webhook — autentica por token estático, que prova o chamador, não a
integridade do corpo. Isso obrigou a reconsulta do ADR-022.

Efeito colateral positivo: a reconsulta é **mais segura que a assinatura** contra uma classe de
ataque — mesmo um webhook assinado corretamente pode carregar um estado desatualizado. Consultar
a API sempre devolve o estado atual. Se migrarmos para um PSP com assinatura, **manter a
reconsulta** é a recomendação; desligá-la exige ADR próprio.

## Critérios para trocar de PSP

1. Todas as capacidades obrigatórias atendidas.
2. Adapter novo passa nos mesmos testes de contrato (Pact/fixtures gravadas).
3. Reconsulta mantida, independentemente de o webhook ser assinado.
4. Conta do operador aprovada **antes** do corte — é marco duro, não tarefa.
