---
id: convencoes-ids
etapa: 0
perfil_minimo: full
projeto: Dream RI
sigla: DRI
tipo: web + mobile (app Expo primário) + api
data: 2026-09-08
owner: Wanderson Lima
status: done
---

# CONVENÇÕES DE IDENTIFICADORES — Dream RI (DRI)

> **Status:** canônico e vinculante. Todo artefato deste plano usa estes IDs.
> Qualquer novo identificador nasce aqui **antes** de aparecer em outro documento.
> Fontes: [PRD-plataforma-rifa-mvp.md](PRD-plataforma-rifa-mvp.md) v1.6 ·
> [SPEC-TECNICA-plataforma-rifa-mvp.md](SPEC-TECNICA-plataforma-rifa-mvp.md) v1.6.

---

## 0. Decisão de numeração — a colisão do R10

O PRD v1.6 usa **`R10` duas vezes**: como P0 (§6, "Conta de recebimento do operador") e como
P1 (§6, "Notificação WhatsApp"). Um plano com IDs ambíguos produz rastreabilidade que mente:
`TRACEABILITY_MATRIX` teria duas linhas com a mesma chave e prioridades diferentes.

**Resolução (D1, 2026-09-08):** `R10` fica com o **P0**. Razões, em ordem de peso:

1. O P0 é citado nominalmente na lista **"nunca cortar"** do PRD §10 e no entregável da semana 1.
2. A SPEC referencia `R10` como conta de recebimento em §3 (`conta_recebimento`), §7 e ADR-17.
3. O protótipo tem a tela `10-conta-recebimento`, cujo próprio nome carrega o número.

O bloco P1 é renumerado. **De-para vinculante** — o PRD deve ser corrigido para refletir:

| PRD v1.6 (colidente) | ID canônico | Requisito |
|---|---|---|
| R10 (P1) | **R11** | Notificação WhatsApp de compra confirmada e de resultado |
| R11 (P1) | **R12** | Contador de urgência (números restantes) |
| R12 (P1) | **R13** | Recuperação de carrinho: lembrete de Pix pendente em 10 min |
| R13 (P1) | **R14** | Relatório de prestação de contas em PDF no layout do órgão |
| R14..R19 (P2) | **R15..R20** | Deslocados em +1, preservando a ordem |

> Enquanto o PRD não for corrigido, **este arquivo vence**. Divergência entre PRD e este
> documento é defeito do PRD, e está registrada como pendência em [INDEX.md](INDEX.md).

---

## 1. Requisitos (R##)

Numeração **herdada do PRD §6** — não renumerar além do de-para acima. O vocabulário `R##` é
compartilhado por PRD, SPEC e protótipo; trocá-lo por `RF-NNN` custaria a coerência dos três
sem ganho real.

### P0 — Must have (15 requisitos)

| ID | Requisito | Feature | Épico | Tela |
|---|---|---|---|---|
| **R0** | Acesso do operador ao sistema | F01 | E01 | `00-login` |
| **R0.5** | Provisionamento da conta do operador | F01 | E01 | `00a-provisionamento` |
| **R1** | Cadastro e publicação de campanha | F02 | E02 | `01a-campanha-admin` |
| **R2** | Estoque e alocação atômica de números | F03 | E03 | — (backend) |
| **R3** | Checkout Pix com reserva temporária | F04 | E04 | `02-checkout-pix` |
| **R4** | Congelamento e commitment criptográfico | F05 | E05 | `04-apuracao` |
| **R5** | Comprovante verificável do comprador | F05 | E05 | `03-meus-numeros` · `05-verificador` |
| **R6** | Apuração automática | F06 | E06 | `04-apuracao` |
| **R7** | Cadastro do comprador | F04 | E04 | `02a-cadastro` |
| **R7.5** | Acesso e painel do comprador | F04 | E04 | `03a-acesso-comprador` · `03-meus-numeros` |
| **R8** | Guarda-corpos de compliance | F07 | E07 | `01-campanha` |
| **R8.5** | Entrega do prêmio e encerramento | F06 | E06 | `04-apuracao` |
| **R9** | Painel do operador (R9.1..R9.6) | F08 | E08 | `06-painel-operador` |
| **R10** | Conta de recebimento do operador | F02 | E02 | `10-conta-recebimento` |

`R9` desdobra em subrequisitos, todos P0:

| ID | Subrequisito | Tela |
|---|---|---|
| **R9.1** | Visão geral da campanha | `06-painel-operador` |
| **R9.2** | Pedidos: busca, filtro e detalhe | `08-pedidos-admin` |
| **R9.3** | Apurações: estado, tentativas, reprocesso | `07-apuracoes-admin` |
| **R9.4** | Relatórios e exportação | `09-relatorios` |
| **R9.5** | Entrega do prêmio pela visão do operador | `04-apuracao` (admin) |
| **R9.6** | Estados de exceção visíveis ao público | `11-estados-excecao` |

### P1 — Should have (renumerados)

| ID | Requisito |
|---|---|
| **R11** | Notificação WhatsApp de compra confirmada e de resultado |
| **R12** | Contador de urgência (números restantes) |
| **R13** | Recuperação de carrinho: lembrete de Pix pendente em 10 min |
| **R14** | Prestação de contas em PDF no layout do órgão autorizador |

### P2 — Future considerations (arquitetar para, não construir)

| ID | Requisito |
|---|---|
| **R15** | Bilhetes premiados instantâneos com sigilo verificável |
| **R16** | Multi-tenant self-service com onboarding e billing |
| **R17** | Cartão de crédito com split |
| **R18** | Sistema de afiliados com split no PSP |
| **R19** | API pública de verificação para terceiros |
| **R20** | Permutação por cifra Feistel acima de 5M de números |

---

## 2. Requisitos não funcionais (RNF-NN)

Derivados da SPEC §10, §11 e §14 — o PRD não os numerava.

| ID | RNF | Origem | Verificação |
|---|---|---|---|
| **RNF-01** | Alocação de números atômica sob concorrência | SPEC §4 | Teste de concorrência (SPEC §11.2) |
| **RNF-02** | 500 req/s no checkout por 60s | SPEC §11 | k6 (`qa/load-tests/`) |
| **RNF-03** | Cobertura > 90% global, 100% no domínio | SPEC §11 | CI |
| **RNF-04** | Snapshot de 1M de folhas construído em < 2s (fase 3) | SPEC §6 | Bench |
| **RNF-05** | TLS 1.3 + HSTS + CSP em todo tráfego | SPEC §9 | Smoke de headers |
| **RNF-06** | Zero PII em log (redator no transporte) | SPEC §9 | `telemetry-checker` |
| **RNF-07** | Crypto-shredding não quebra a cadeia de auditoria | SPEC §9 | Teste `crypto-shredding` no CI |
| **RNF-08** | Idempotência de webhook por `(provedor, evento_id)` | SPEC §7 | Teste de integração |
| **RNF-09** | Acessibilidade AA (axe-core sem critical/serious) | `prototipacao/UX_REVIEW.md` | `a11y-auditor` |
| **RNF-10** | Expurgo de IP/user-agent de sessão em D+90 | SPEC §9 | Teste com relógio adiantado |
| **RNF-11** | Sessão sem 2º fator não autoriza rota admin | SPEC §9 | Teste de autorização |
| **RNF-12** | Rate limit: 10 req/min por IP no checkout, 5/min na consulta | SPEC §9 | Teste de integração |
| **RNF-13** | Observabilidade: log estruturado + trace + métrica por fluxo | SPEC §10 | `telemetry-checker` |
| **RNF-14** | Derivado de CPF resistente a enumeração (Argon2id) | SPEC §9 / ADR-22 | Teste de salts distintos |
| **RNF-15** | App publicável nas duas lojas | PRD §10 | Build EAS + submissão |
| **RNF-16** | Web mobile-first paritária como caminho de compra | PRD §10 | E2E Playwright |

---

## 3. Features (F##)

Fatias verticais entregáveis que agrupam requisitos.

| Feature | Nome | Requisitos | Épico |
|---|---|---|---|
| **F01** | Acesso e provisionamento do operador | R0, R0.5 | E01 |
| **F02** | Campanha e conta de recebimento | R1, R10 | E02 |
| **F03** | Estoque e alocação atômica | R2 | E03 |
| **F04** | Compra: cadastro, checkout Pix e painel do comprador | R3, R7, R7.5 | E04 |
| **F05** | Commitment e comprovante verificável | R4, R5 | E05 |
| **F06** | Apuração e entrega do prêmio | R6, R8.5, R9.5 | E06 |
| **F07** | Compliance e guarda-corpos | R8 | E07 |
| **F08** | Painel do operador e relatórios | R9.1..R9.4, R9.6 | E08 |
| **F09** | App Expo e submissão às lojas | RNF-15, RNF-16 | E09 |
| **F10** | Hardening, carga e go-live | RNF-02, RNF-05 | E10 |

---

## 4. Épicos (E##)

Alinhados ao cronograma de 6 semanas do PRD §10 / SPEC §13.

| Épico | Nome | Semana | Feature |
|---|---|---|---|
| **E01** | Fundação, domínio e acesso do operador | 1 | F01 |
| **E02** | Campanha publicável e conta de recebimento | 1 | F02 |
| **E03** | Estoque de 1M e alocação atômica | 1–2 | F03 |
| **E04** | Checkout Pix fim a fim pelo app | 2 | F04 |
| **E05** | Congelamento, commitment e verificador | 3 | F05 |
| **E06** | Apuração automática e entrega do prêmio | 4 | F06 |
| **E07** | Compliance e guarda-corpos | 4 | F07 |
| **E08** | Painel do operador e relatórios | 4 | F08 |
| **E09** | App: deep link, E2E, build EAS e submissão | 5 | F09 |
| **E10** | Estados de exceção, carga, hardening e go-live | 6 | F10 |

---

## 5. Regras de negócio (BR-NNN)

Faixas por domínio. Catálogo em [requirements/BUSINESS_RULES.md](requirements/BUSINESS_RULES.md).

| Faixa | Domínio |
|---|---|
| BR-001..019 | Acesso, sessão e autorização |
| BR-020..039 | Campanha e publicação |
| BR-040..059 | Estoque, reserva e alocação |
| BR-060..079 | Pedido, pagamento e estorno |
| BR-080..099 | Commitment e verificação |
| BR-100..119 | Apuração, retificação e entrega |
| BR-120..139 | Compliance e LGPD |
| BR-140..159 | Conta de recebimento |

---

## 6. Demais identificadores

| Tipo | Formato | Exemplo | Onde nasce |
|---|---|---|---|
| ADR | `ADR-NNN` | `ADR-022` | `adrs/` — a SPEC §12 tem 26 resumidas (ADR-01..23 + 3); as individualizadas herdam o número |
| User story | `US-NNN` | `US-014` | `requirements/USER_STORIES.md` |
| Cenário Gherkin | `<REQ>.feature` | `cenarios/R04-commitment.feature` | um arquivo por requisito |
| Ameaça STRIDE | `TH-NNN` | `TH-007` | `security/THREAT_MODEL.md` |
| Risco | `RSK-NN` | `RSK-03` | `RISKS.md` |
| Questão aberta | `Q##` | `Q5` | herdado do PRD §9 |
| Decisão | `D##` | `D1` | `DECISION_LOG.md` |
| Tela | `NN[a]-<slug>` | `03a-acesso-comprador` | `prototipacao/hi-fi/` — numeração já existente |
| Issue Jira | `DRI-###` | `DRI-042` | board `DRI` |
| Evento de domínio | `PascalCase` no passado | `PedidoPago` | SPEC §2 |

---

## 7. Agregados e bounded contexts

Herdados da SPEC §1–§2. Vinculantes para `models/c4/` e `models/erd/per-service/`.

| BC | Agregado raiz | Requisitos |
|---|---|---|
| **Identity & Access** | `Operador`, `Sessao` | R0, R0.5 |
| **Campanha** | `Campanha` | R1, R8, R10 |
| **Estoque** | `NumeroSorte` | R2 |
| **Pedido** | `Pedido` | R3, R7, R7.5 |
| **Pagamento** | `WebhookEvento`, `EstornoPendente` | R3 |
| **Verificação** | `Commitment` | R4, R5 |
| **Apuração** | `Apuracao`, `ExtracaoTentativa` | R6, R9.3 |
| **Entrega** | `EntregaPremio` | R8.5, R9.5 |
| **Auditoria** | `Auditoria` (append-only) | transversal |
