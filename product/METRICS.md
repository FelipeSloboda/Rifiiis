---
id: metrics
etapa: 1
data: 2026-09-08
status: done
fonte: PRD §7
---

# METRICS — Dream RI

## Métrica norte

**Campanhas apuradas sem intervenção manual e verificadas por terceiro.**
Não é receita, não é GMV: é a única métrica que mede se a *tese* funciona. Uma campanha que
arrecada bem mas precisa de entrada manual da extração é um sinal de que o produto ainda depende
de confiança.

---

## Leading — medir em D+7 após a 1ª campanha

| Métrica | Alvo | Instrumento | Por que importa |
|---|---|---|---|
| Taxa Pix gerado → pago | ≥ 55% | `pedidos_pagos_total / pedidos_criados_total` | Abaixo de 30% dispara alerta (SPEC §10): checkout quebrado ou preço errado |
| Tempo mediano checkout → número atribuído | < 60s | trace OTel | O comprador não confia no que demora |
| Verificações do comprovante | ≥ 15% dos compradores | hit no `05-verificador` | **A métrica da tese.** Se ninguém verifica, o diferencial não é percebido |
| Reservas expiradas / criadas | < 40% | worker de expiração | Alto = fricção no Pix ou TTL curto demais |
| Erro 5xx no checkout | < 0,5% | métrica HTTP | — |

---

## Lagging — medir em D+30

| Métrica | Alvo | Por que importa |
|---|---|---|
| Apurações sem intervenção manual | 100% | Entrada manual é o modo degradado; recorrência = fonte primária instável |
| Campanhas com entrega registrada | 100% | R8.5 fecha o loop da tese — sem isso a prova para no sorteio |
| Estornos pendentes ao fim da campanha | 0 | Estorno preso é dinheiro do comprador retido (R10) |
| Reclamação pública de fraude | 0 | O produto existe para isto |
| Retificações de apuração | 0 | Uma já é sinal; duas é defeito de insumo, não azar |

---

## Contra-métricas — o que vigiar para não otimizar errado

| Se subir… | Pode significar |
|---|---|
| Conversão, com verificações caindo | Estamos vendendo rifa comum. A tese está sendo diluída |
| Velocidade de publicação de campanha | Guarda-corpos de compliance (R8) sendo contornados |
| Volume por comprador | Limite por CPF não está sendo aplicado — risco regulatório |

---

## O que **não** medimos

Nada que exija PII em telemetria. A SPEC §9 proíbe PII em log, e isso vale para métrica: nenhum
gauge por CPF, nenhum funil por titular identificado. Segmentação, quando necessária, usa
`campanha_id` e `tenant_id`.
