---
id: erd-logico
etapa: 8
data: 2026-09-08
status: done
---

# ERD LÓGICO — Dream RI

O DDL completo está na [SPEC §3](../../SPEC-TECNICA-plataforma-rifa-mvp.md), que é a fonte.
Aqui estão as **decisões de modelagem** que o DDL sozinho não explica.

## Índices e por que cada um existe

| Índice | Tabela | Tipo | Existe para |
|---|---|---|---|
| `idx_numero_alocacao` | `numero_sorte` | Parcial `WHERE DISPONIVEL` | O índice encolhe conforme a campanha vende — a alocação fica mais rápida no fim, não mais lenta |
| `idx_numero_expiracao` | `numero_sorte` | Parcial `WHERE RESERVADO` | Worker de expiração varre só o relevante |
| `idx_comprador_cpf` | `comprador` | Único `(tenant_id, cpf_indice)` | Limite por CPF e consulta; **sobrevive ao shredding** |
| `idx_operador_email_ativo` | `operador` | Único parcial `WHERE anonimizado_em IS NULL` | Libera o e-mail após anonimizar, permitindo recontratar |
| `idx_sessao_ativa` | `sessao` | Parcial `WHERE revogada_em IS NULL` | Sessões vivas |
| `idx_sessao_a_purgar` | `sessao` | Parcial `WHERE purgada_em IS NULL` | Fila do worker de retenção |
| `idx_pedido_psp` | `pedido` | Único parcial | Liga ao PSP sem colidir com pedidos sem cobrança |
| `UNIQUE(provedor, evento_id)` | `webhook_evento` | Único | **É** a idempotência, não um índice de consulta |

**O padrão:** quase todo índice é **parcial**. Não é micro-otimização — é o que mantém a alocação
com desempenho constante numa tabela de 1M de linhas em que 99% eventualmente sai do índice.

## Constraints que carregam regra de negócio

| Constraint | Tabela | Regra |
|---|---|---|
| `CHECK (total_numeros BETWEEN 100 AND 1000000)` | `campanha` | ADR-011: **fonte única** do limite. Elevar exige trocar o alocador |
| `CHECK (preco_bilhete_cents > 0)` | `campanha` | — |
| `CHECK ((chave_apagada_em IS NULL) = (chave_dek_cifrada IS NOT NULL))` | `comprador` | Estado pós-shredding coerente |
| `CHECK (anonimizado_em IS NULL OR desativado_em IS NOT NULL)` | `operador` | Não anonimiza quem ainda faz login |
| `UNIQUE (tenant_id, slug)` | `campanha` | — |
| `UNIQUE (campanha_id, numero)` | `numero_sorte` | — |
| `UNIQUE campanha_id` | `commitment` | **Um commitment por campanha** — impede recarimbar |

> Regra de negócio no banco não é redundância: é a camada que sobrevive a um bug de aplicação. As
> quatro primeiras são invariantes que, se violadas, produzem estado do qual não se recupera.

## Chaves estrangeiras que impedem apagar

| FK | Impede |
|---|---|
| `auditoria.operador_id` | `DELETE` no operador — destruiria a atribuição do ato |
| `extracao_tentativa.operador_id` | Idem, para a entrada manual (o controle do ADR-016) |
| `pedido.comprador_id` | Preservada mesmo após o shredding — o registro fica ilegível, não ausente |

**Esta é a diferença entre shredding e delete:** as FKs continuam resolvendo. O grafo de dados
permanece íntegro; o que some é a legibilidade.

## Auditoria append-only

```
auditoria(id, tenant_id, entidade, entidade_id, acao, dados, operador_id,
          hash_anterior, hash, ocorrida_em)
```

`hash = SHA256(hash_anterior ‖ registro_serializado_cifrado)`.

**O registro serializado é o cifrado.** Se o hash fosse do texto claro, apagar a chave do titular
quebraria a cadeia — e o crypto-shredding seria incompatível com a auditoria. É a decisão de
modelagem mais importante do esquema, e a menos visível.

Nenhum `UPDATE`, nenhum `DELETE`. A permissão da aplicação nesta tabela é `INSERT` e `SELECT`.

## Crescimento e o gatilho de particionamento

| Tabela | Linhas por campanha | Gatilho |
|---|---|---|
| `numero_sorte` | até 1M | `fillfactor` + autovacuum por tabela primeiro (ADR-014) |
| `auditoria` | ~10 por pedido | Cresce sem limite; arquivamento futuro |
| `webhook_evento` | ~2 por pedido | Retenção definida por auditoria |

ADR-014 adia o particionamento **com critério medido**: 1M por campanha e um cliente não
justificam a complexidade. O gatilho fica registrado para quando justificar.
