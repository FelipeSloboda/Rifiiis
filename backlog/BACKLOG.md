---
id: backlog
etapa: 10
data: 2026-09-08
status: done
---

# BACKLOG — Dream RI

> **Estado:** nenhuma issue criada. O board `DRI` não existe ainda (pendência 2 do
> [INDEX](../INDEX.md)). Este arquivo é a fonte da importação — cada linha vira uma issue com o
> corpo definido em [TASK_DETAILS.md](TASK_DETAILS.md).

## Convenção

- Chave: `DRI-###`, atribuída na importação.
- Épico como parent; label `epic:E0N`.
- Label de raia: `lane:backlog` → `lane:pronto-p-dev` → `lane:em-dev` → `lane:review` → `lane:done`.
- Pontos conforme [USER_STORIES](../requirements/USER_STORIES.md).

---

## E01 — Fundação e acesso · 8 itens · 29 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 1 | Estrutura do monorepo, CI e migrations base | — | 5 | — |
| 2 | Agregados, VOs e políticas do domínio | — | 5 | — |
| 3 | Provisionamento de operador | US-001 | 3 | `R00.5` |
| 4 | Ativação de TOTP + códigos de recuperação | US-001, US-003 | 5 | `R00.5` |
| 5 | Login em dois estados (desafio → sessão) | US-002 | 5 | `R00` |
| 6 | Guard de rota admin com 2º fator | US-002 | 3 | `R00` |
| 7 | Bloqueio por tentativas + resposta indistinguível | US-002 | 2 | `R00` |
| 8 | Desativação de operador com revogação de sessões | US-018 | 3 | `R00.5` |

## E02 — Campanha e conta · 7 itens · 31 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 9 | CRUD de campanha com validações | US-006 | 8 | `R01` |
| 10 | Conta de recebimento: cadastro | US-004 | 5 | `R10` |
| 11 | Verificação de titularidade contra CNPJ | US-005 | 5 | `R10` |
| 12 | Portão de publicação (conta + autorização + regulamento) | US-007 | 5 | `R01`, `R08` |
| 13 | Geração assíncrona de estoque | — | 3 | `R01` |
| 14 | Fila de estornos pendentes | US-015 | 5 | `R10` |
| 15 | Página pública da campanha | US-020 | 3 | `R01` |

## E03 — Estoque e alocação · 5 itens · 29 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 16 | **Teste de concorrência (escrito primeiro)** | — | 8 | `R02` |
| 17 | Geração pré-embaralhada com COPY binário | — | 5 | `R02` |
| 18 | Alocador com `SKIP LOCKED` | US-024 | 8 | `R02` |
| 19 | Worker de expiração em lote | US-050 | 5 | `R02` |
| 20 | Consulta ao PSP antes de expirar | US-050 | 3 | `R02` |

> O item 16 vem **antes** do 18 no board, não por preferência — por ADR-012.

## E04 — Checkout · 8 itens · 45 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 21 | Cadastro do comprador com PII cifrada (DEK) | US-022 | 8 | `R07` |
| 22 | Derivação do `cpf_indice` (Argon2id) | US-022 | 5 | `R07` |
| 23 | Criação de pedido com idempotência | US-021 | 5 | `R03` |
| 24 | Adapter PicPay: emissão de cobrança | US-023 | 8 | `R03` |
| 25 | Webhook + idempotência `(provedor, evento_id)` | — | 5 | `R03` |
| 26 | **Reconsulta ao PSP na confirmação** | — | 5 | `R03` |
| 27 | Atribuição de números pós-pagamento | US-024 | 5 | `R03` |
| 28 | Acesso do comprador por código de uso único | US-025 | 5 | `R07.5` |

## E05 — Commitment · 6 itens · 42 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 29 | Worker de congelamento T-2h | US-051 | 5 | `R04` |
| 30 | Snapshot NDJSON + derivação em pool | — | 8 | `R04` |
| 31 | **Árvore Merkle RFC 6962 (vetores externos)** | — | 8 | `R04` |
| 32 | Adapter da ACT (RFC 3161) | US-052 | 8 | `R04` |
| 33 | Comprovante com prova de inclusão | US-026 | 8 | `R05` |
| 34 | Verificador público | US-027 | 5 | `R05` |

## E06 — Apuração e entrega · 7 itens · 45 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 35 | Adapter da fonte primária | — | 5 | `R06` |
| 36 | Adapter da fonte secundária ⚠️ **G-15 pendente** | — | 5 | `R06` |
| 37 | Cascata + bloqueio | US-011 | 5 | `R06` |
| 38 | `RegraDeApuracao` (VO puro, 100% coberto) | US-042 | 8 | `R06` |
| 39 | Entrada manual com dois responsáveis | US-012 | 8 | `R06` |
| 40 | Retificação com causa fechada | US-016 | 8 | `R06` |
| 41 | Registro e confirmação de entrega | US-014, US-029 | 6 | `R08.5` |

## E07 — Compliance e LGPD · 6 itens · 32 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 42 | Limite por CPF, maioridade, consentimento | — | 5 | `R08` |
| 43 | Alerta de autorização vencendo | US-017 | 3 | `R08` |
| 44 | Crypto-shredding + **teste no CI** | US-031 | 8 | `RNF-lgpd` |
| 45 | Worker de retenção (expurgo D+90) | US-053 | 5 | `RNF-lgpd` |
| 46 | Anonimização de operador por prazo | US-054 | 5 | `RNF-lgpd` |
| 47 | Redator de PII no transporte | — | 6 | `R08` |

## E08 — Painel · 5 itens · 31 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 48 | Visão geral da campanha | US-008 | 5 | `R09.1` |
| 49 | Pedidos: busca por índice cego, filtro, detalhe | US-009 | 8 | `R09.2` |
| 50 | Apurações: tentativas e reprocesso | US-010 | 8 | `R09.3` |
| 51 | Relatórios e exportação | US-013 | 5 | `R09.4` |
| 52 | Estado vazio e a11y em todas as telas admin | — | 5 | `R09.*` |

## E09 — App e submissão · 6 itens · 37 pts

| # | Item | Pts |
|---|---|---:|
| 53 | Onboarding e navegação do app | 8 |
| 54 | Telas de campanha, pacotes e checkout | 8 |
| 55 | Tela de Pix com copia-e-cola | 5 |
| 56 | Deep link do link compartilhável | 5 |
| 57 | E2E Maestro em emulador | 5 |
| 58 | Build EAS e submissão às duas lojas | 6 |

## E10 — Fechamento · 5 itens · 29 pts

| # | Item | Story | Pts | Cenário |
|---|---|---|---:|---|
| 59 | Estados de exceção públicos (6 cenários) | US-030 | 8 | `R09.6` |
| 60 | Teste de carga k6 | US-055 | 8 | `RNF-concorrencia` |
| 61 | Hardening: headers, rate limit, ASVS | — | 5 | `RNF-seguranca` |
| 62 | Deploy de produção e runbooks | — | 5 | — |
| 63 | Campanha real | — | 3 | — |

---

## Totais

| Épico | Itens | Pontos |
|---|---:|---:|
| E01 | 8 | 29 |
| E02 | 7 | 31 |
| E03 | 5 | 29 |
| E04 | 8 | 45 |
| E05 | 6 | 42 |
| E06 | 7 | 45 |
| E07 | 6 | 32 |
| E08 | 5 | 31 |
| E09 | 6 | 37 |
| E10 | 5 | 29 |
| **Total** | **63** | **350** |

> Pontos são referência **relativa** para sequenciamento, não promessa de prazo. O cronograma que
> vale é o do PRD §10, por entregável verificável.
