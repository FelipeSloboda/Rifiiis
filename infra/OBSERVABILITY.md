---
id: observability
etapa: 9
data: 2026-09-08
status: done
fonte: SPEC §10
---

# OBSERVABILIDADE — Dream RI

## Logs

JSON estruturado, `correlation_id` propagado do request ao worker.

**Regra inegociável:** redator de CPF/telefone/e-mail **no transporte**, não no call site. Um
redator no call site depende de cada desenvolvedor lembrar; no transporte, é impossível vazar por
esquecimento (BR-127, RNF-06).

## Métricas (Prometheus)

| Métrica | Tipo | Para quê |
|---|---|---|
| `pedidos_criados_total` | counter | Denominador da conversão |
| `pedidos_pagos_total` | counter | Numerador — taxa Pix gerado→pago |
| `numeros_alocados_duration_seconds` | histogram | Saúde da alocação sob concorrência |
| `webhook_processamento_duration_seconds` | histogram | Fila do PSP |
| `estoque_disponivel_gauge` | gauge | Escassez real |
| `sessoes_pendentes_expurgo_gauge` | gauge | **Retenção sem monitor é declaração de intenção** |
| `extracao_tentativas_total{fonte,resultado}` | counter | Saúde da cascata de fontes |
| `estornos_pendentes_gauge` | gauge | Dinheiro devido não devolvido |

**Nenhuma métrica segmenta por titular identificado.** Segmentação usa `campanha_id` e
`tenant_id` (RNF-06).

## Tracing

OpenTelemetry no caminho **checkout → PSP → webhook → atribuição**. É o percurso onde uma falha
silenciosa vira "paguei e não recebi número" — o pior incidente possível do produto.

## Health checks

| Endpoint | Verifica |
|---|---|
| `/health/live` | Processo vivo |
| `/health/ready` | Postgres, Redis, PSP |

> Probe é HTTP/socket, nunca cliente que inicializa runtime pesado. Um healthcheck caro roda
> milhares de vezes por dia e derrapa o intervalo real.

## Alertas

| Condição | Severidade | Por quê |
|---|:-:|---|
| Taxa Pix gerado→pago < 30% em 1h | Alta | Checkout quebrado ou preço errado |
| Webhook não processado > 5 min | **Crítica** | Comprador pagou e não tem número |
| **Falha ao carimbar commitment** | **Crítica** | A tese daquela campanha cai |
| Fonte da Federal indisponível em dia de apuração | **Crítica** | Apuração vai bloquear |
| Autorização da campanha vence em < 7 dias | Média | Publicação vai travar |
| `sessoes_pendentes_expurgo_gauge` > 0 por 48h | Média | Expurgo não está rodando |
| `estornos_pendentes_gauge` > 0 por 24h | Alta | Dinheiro de terceiro retido |

## O alerta que não existe, e deveria ser discutido

Não há alerta para **"apuração concluída sem verificação externa"**. A métrica norte é campanhas
verificadas por terceiro, mas não há como instrumentar "alguém conferiu" além do hit no
verificador — que é proxy fraco (pode ser o próprio operador). Fica registrado como limitação
consciente da instrumentação.
