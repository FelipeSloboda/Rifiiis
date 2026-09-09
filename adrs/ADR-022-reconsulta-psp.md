# ADR-022 — A confirmação de pagamento reconsulta o PSP

**Status:** aceita · **Contexto:** SPEC §7, RSK-06

## Contexto

O webhook do PicPay é autenticado por **token estático** e **não é assinado**. Token estático
prova o *chamador*; assinatura provaria a *integridade do corpo*. Não são a mesma coisa.

## Decisão

Ao receber `PAID`, o worker **consulta a API do PSP** para obter o valor e o status reais. O
corpo do webhook serve apenas como *gatilho*, nunca como fonte de verdade para valor.

A idempotência usa `(provedor, evento_id)`, que não é PII e não depende do conteúdo.

## Alternativa recusada

**Confiar no payload autenticado pelo token.** É o que a maioria faz, e funciona — até alguém
descobrir a URL.

## Por quê

Sem a reconsulta, quem forjar o POST **define quanto foi pago**. Um corpo com `valor: 0.01` e
`status: PAID` vira número entregue sem dinheiro. Como o webhook não é assinado, não há nada no
corpo que impeça isso.

Este é o risco de **maior exposição do projeto** (RSK-06: P5 × I4 = 20). A mitigação é
arquitetural, não configurável — não existe flag que a desligue.

## Consequências

- Uma chamada extra ao PSP por confirmação. Custo aceito.
- O worker de expiração aproveita o mesmo mecanismo: consulta o PSP **antes** de expirar uma
  reserva, para não perder pagamento tardio (BR-046).
- O webhook responde rápido e o processamento é assíncrono — o PSP faz retry por timeout e
  geraria evento duplicado se processássemos de forma síncrona.
- O payload bruto é cifrado na gravação: pode conter nome e CPF.

## Se o PSP mudar

A porta `GatewayDePagamento` isola o adapter. Um PSP com webhook **assinado** permitiria dispensar
a reconsulta — mas a decisão deve ser reavaliada explicitamente, nunca herdada por omissão ao
trocar de adapter.
