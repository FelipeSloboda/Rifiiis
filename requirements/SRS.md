---
id: srs
etapa: 4
data: 2026-09-08
status: done
---

# SRS — Especificação de Requisitos de Software · Dream RI

> Este documento **não substitui** o [PRD](../PRD-plataforma-rifa-mvp.md) nem a
> [SPEC](../SPEC-TECNICA-plataforma-rifa-mvp.md). Ele é a visão normalizada dos requisitos para
> quem precisa da lista formal — auditoria, contrato, prestação de contas. Onde divergir, PRD e
> SPEC vencem.

## 1. Escopo

Plataforma de rifa com apuração verificável por terceiro. Superfícies: app Expo (primária), web
mobile-first (paritária) e API. Um operador por instância; multi-tenant é P2.

**Fora de escopo:** custódia de valores, split, afiliados, cartão de crédito, marketplace,
campanhas acima de 1M de números.

## 2. Perspectiva do produto

| Interface externa | Natureza | Criticidade |
|---|---|---|
| PSP (PicPay) | REST + webhook não assinado | Alta — sem ela não há venda |
| Loteria Federal | Leitura pública, sem SLA | Alta — sem ela não há apuração |
| ACT (RFC 3161) | Carimbo do tempo | Alta — sem ela não há prova |
| Lojas (Apple/Google) | Distribuição | Média — web é o plano B |

## 3. Requisitos funcionais

Catálogo completo em [CONVENCOES-IDS §1](../CONVENCOES-IDS.md); comportamento verificável em
[cenarios/](../cenarios/). Resumo por capacidade:

| # | Capacidade | Requisitos |
|---|---|---|
| 1 | Acesso e provisionamento do operador | R0, R0.5 |
| 2 | Ciclo de vida da campanha | R1, R4 |
| 3 | Estoque e alocação | R2 |
| 4 | Compra e pagamento | R3, R7, R7.5 |
| 5 | Prova e verificação | R4, R5 |
| 6 | Apuração e entrega | R6, R8.5 |
| 7 | Compliance | R8 |
| 8 | Operação e relatórios | R9.1..R9.6 |
| 9 | Recebimento e estorno | R10 |

## 4. Requisitos não funcionais

16 RNFs em [CONVENCOES-IDS §2](../CONVENCOES-IDS.md). Agrupados:

| Categoria | RNFs | Alvo resumido |
|---|---|---|
| Desempenho | RNF-02, RNF-04 | 500 req/s; árvore de 1M em < 2s |
| Confiabilidade | RNF-01, RNF-08 | Zero colisão; webhook idempotente |
| Segurança | RNF-05, RNF-11, RNF-12, RNF-14 | TLS 1.3, 2FA, rate limit, Argon2id |
| Privacidade | RNF-06, RNF-07, RNF-10 | Zero PII em log; shredding; expurgo D+90 |
| Qualidade | RNF-03 | > 90% global, 100% no domínio |
| Acessibilidade | RNF-09 | WCAG 2.2 AA |
| Observabilidade | RNF-13 | Log + trace + métrica por fluxo |
| Distribuição | RNF-15, RNF-16 | Duas lojas + web paritária |

## 5. Restrições de projeto

| Restrição | Origem |
|---|---|
| Sem custódia de valores | ADR-17 — risco regulatório |
| Apuração irreversível, corrigível só por retificação | ADR-13 |
| Resultado sintético impossível por construção | SPEC §7 |
| `tenant_id` em todas as tabelas desde o dia 1 | Preparação para P2 |
| Alocador é porta com implementação `TabelaPreSorteada` | Escape hatch Feistel (R20) |
| Prazo de 6 semanas com folga nomeada na semana 6 | PRD §10 |

## 6. Suposições e dependências

| # | Suposição | Se falsa |
|---|---|---|
| S1 | O operador tem autorização válida do órgão | Não publica — bloqueio por design |
| S2 | PicPay aprova a conta em D+7 | Cronograma para (RSK-11) |
| S3 | ACT contratada em D+7 | A tese não se sustenta (RSK-05) |
| S4 | A Federal publica a extração no dia | Modo degradado manual (RSK-04) |
| S5 | O comprador tem CPF e usa Pix | Fora do escopo do MVP |
| S6 | O comprador valoriza a verificabilidade | RSK-01 — a mais frágil |

## 7. Verificação

Todo requisito tem cenário executável. A matriz completa está em
[TRACEABILITY_MATRIX](TRACEABILITY_MATRIX.md). Requisito sem cenário não entra em
desenvolvimento — é a regra do `po-reviewer`.
