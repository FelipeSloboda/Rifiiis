---
id: event-catalog
etapa: 7
data: 2026-09-08
status: done
fonte: SPEC §2
---

# CATÁLOGO DE EVENTOS — Dream RI

Eventos de domínio publicados via **outbox transacional** (ADR-006): a linha em `evento_outbox` é
escrita na mesma transação do agregado, e drenada por worker. Sem isso, "pagamento confirmado mas
números não atribuídos" vira incidente de produção.

## Convenção

- Nome em **PascalCase no passado**: `PedidoPago`, não `PagarPedido`.
- Payload contém **ids e o mínimo necessário** — nunca PII em claro.
- Todo evento carrega `correlation_id` propagado do request ao worker.

---

## Acesso

| Evento | Disparado por | Consumidores | Payload |
|---|---|---|---|
| `OperadorProvisionado` | Provisionamento | auditoria | `operador_id`, `tenant_id` |
| `SegundoFatorAtivado` | Ativação de TOTP | auditoria | `operador_id` |
| `SessaoAutorizada` | 2FA verificado | auditoria | `sessao_id`, `operador_id` |
| `OperadorDesativado` | Desligamento | revogação de sessões, auditoria | `operador_id` |
| `OperadorAnonimizado` | Worker de retenção | auditoria | `operador_id` |

## Campanha

| Evento | Disparado por | Consumidores | Payload |
|---|---|---|---|
| `CampanhaCriada` | Criação | auditoria | `campanha_id` |
| `CampanhaPublicada` | Publicação | geração de estoque, auditoria | `campanha_id`, `total_numeros` |
| `EstoqueGerado` | Worker de geração | painel | `campanha_id`, `total` |
| `CampanhaCongelada` | Worker T-2h | snapshot, auditoria | `campanha_id`, `congelada_em` |
| `CampanhaCanceladaSemVendas` | Congelamento sem vendas | commitment vazio, notificação | `campanha_id` |
| `CampanhaEncerrada` | Entrega confirmada | auditoria | `campanha_id` |

## Venda

| Evento | Disparado por | Consumidores | Payload |
|---|---|---|---|
| `CompradorCadastrado` | Cadastro | auditoria | `comprador_id` |
| `PedidoCriado` | Checkout | emissão de cobrança | `pedido_id`, `campanha_id`, `qtd` |
| `NumerosReservados` | Alocação | painel | `pedido_id`, `quantidade` |
| `CobrancaEmitida` | Adapter do PSP | painel | `pedido_id`, `psp_cobranca_id` |
| `PedidoPago` | Confirmação **reconsultada** | atribuição, notificação | `pedido_id`, `valor_cents` |
| `NumerosAtribuidos` | Pós-pagamento | comprovante | `pedido_id`, `numeros[]` |
| `PedidoExpirado` | Worker de expiração | liberação de estoque | `pedido_id` |
| `NumerosLiberados` | Expiração | painel | `campanha_id`, `quantidade` |
| `EstornoAcionado` | Falha pós-pagamento | fila de estorno | `pedido_id`, `motivo` |
| `EstornoFalhou` | Adapter do PSP | fila com backoff | `pedido_id`, `motivo` |
| `EstornoConcluido` | Confirmação do PSP | auditoria | `pedido_id` |

## Prova

| Evento | Disparado por | Consumidores | Payload |
|---|---|---|---|
| `SnapshotGerado` | Pós-congelamento | árvore Merkle | `campanha_id`, `total_folhas`, `sha256` |
| `RaizCalculada` | Construção da árvore | carimbo | `campanha_id`, `raiz` |
| `CommitmentCarimbado` | ACT | publicação | `campanha_id`, `token`, `autoridade` |
| `CommitmentPublicado` | Publicação | página pública | `campanha_id`, `raiz` |
| `CarimboFalhou` | Falha na ACT | **alerta crítico** | `campanha_id`, `motivo` |

## Apuração e entrega

| Evento | Disparado por | Consumidores | Payload |
|---|---|---|---|
| `ExtracaoObtida` | Fonte primária/secundária | apuração | `campanha_id`, `fonte`, `extracao` |
| `ExtracaoFalhou` | Falha de fonte | cascata, painel | `campanha_id`, `fonte`, `motivo` |
| `ApuracaoBloqueada` | Ambas as fontes falharam | **notificação ao operador** | `campanha_id` |
| `EntradaManualSubmetida` | Operador | aguarda 2º responsável | `campanha_id`, `operador_id` |
| `GanhadorApurado` | Regra aplicada | publicação | `campanha_id`, `numero_apurado` |
| `ResultadoPublicado` | Publicação | página pública, notificação | `campanha_id` |
| `ApuracaoRetificada` | Retificação | página pública, auditoria | `campanha_id`, `causa` |
| `EntregaRegistrada` | Operador | notificação ao ganhador | `campanha_id` |
| `EntregaConfirmada` | Ganhador | encerramento | `campanha_id` |

---

## Regras que valem para todos

1. **Nenhum payload carrega PII em claro.** `comprador_id` sim; nome e CPF nunca.
2. **Publicação é transacional.** Escrita na mesma transação do agregado (outbox).
3. **Consumo é idempotente.** O worker pode processar o mesmo evento duas vezes.
4. **Auditoria consome tudo.** É a cadeia append-only, não um consumidor opcional.

## Os dois eventos que existem para o sistema não mentir

`ApuracaoBloqueada` e `EstornoFalhou`. Ambos representam **falha que não pode ser escondida**:
o primeiro impede resultado inventado, o segundo impede declarar devolvido um dinheiro que não
voltou. Nenhum dos dois tem retry silencioso — os dois viram estado visível.
