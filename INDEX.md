# INDEX — Dream RI (DRI)

> **Sigla:** DRI
> **Tipo:** app Expo (superfície primária) + web mobile-first + API
> **Perfil:** full
> **Data D0:** 2026-09-08
> **Repositório de planejamento:** `plan-project/dream-ri/`
> **Repositório de código:** ainda não criado — a SPEC §1 define a estrutura em `apps/{api,app,web}`
> **Espelho público:** [github.com/FelipeSloboda/Rifiiis](https://github.com/FelipeSloboda/Rifiiis) — PRD, SPEC, protótipo **e o plano full** (D5)
> **Board Jira:** `DRI` — **ainda não criado**
> **Índice narrativo:** [DOCUMENTATION.md](DOCUMENTATION.md) — *por onde começar a ler*
> (este arquivo responde **o que falta**; o `DOCUMENTATION.md` responde **por onde eu começo**)

---

## O que este produto é, em uma frase

Plataforma de rifa em que o sorteio é **verificável por terceiro** — commitment criptográfico
carimbado antes da extração da Loteria Federal, comprovante com prova de inclusão Merkle, e
nenhuma custódia de dinheiro de terceiro.

---

## Changelog de decisões

- **2026-09-08 (D1)** — plano full materializado a partir do PRD v1.6 + SPEC v1.6 + 18 telas hi-fi.
  Colisão de `R10` resolvida a favor do P0 (conta de recebimento); P1 renumerado para R11..R14 e
  P2 para R15..R20 — ver [CONVENCOES-IDS.md §0](CONVENCOES-IDS.md).
- **2026-09-08 (D0)** — perfil **full**, tipo app+web+api. Fontes: PRD v1.6, SPEC v1.6.
  Ver [DECISION_LOG.md](DECISION_LOG.md).

---

## Números do plano

| Artefato | Quantidade |
|---|---:|
| Requisitos P0 (`R##`) | 15 (14 + 6 subrequisitos de R9) |
| Requisitos P1/P2 | 4 / 6 |
| Requisitos não funcionais (`RNF-NN`) | 16 |
| Regras de negócio (`BR-NNN`) | 110 |
| Features (`F##`) | 10 |
| Épicos (`E##`) | 10 |
| User stories (`US-NNN`) | 40 |
| Cenários Gherkin | 136 em 21 arquivos (44 `@critico`) |
| ADRs | 26 na SPEC §12 · 9 em formato longo |
| Ameaças STRIDE (`TH-NNN`) | 45 (22 críticas) |
| Riscos (`RSK-NN`) | 12 |
| Telas hi-fi | 18 |
| Questões abertas (`Q##`) | 9 (herdadas do PRD §9) |

---

## Pendências que bloqueiam

| # | Pendência | Dono | Bloqueia |
|---|---|---|---|
| 1 | **Corrigir o PRD**: aplicar o de-para de IDs da [CONVENCOES-IDS §0](CONVENCOES-IDS.md) | produto | rastreabilidade coerente |
| 2 | **Board Jira `DRI` não existe** — o plano não tem destino de importação | operador | Etapa 11 |
| 3 | **Conta PicPay não aprovada** — marco duro D+7 do PRD §10 | operador | E04 |
| 4 | **ACT (carimbo do tempo) não contratada** — marco duro D+7 | operador | E05 |
| 5 | **Contas Apple/Google não abertas** — marco duro D+7 | operador | E09 |
| 6 | **Repositório de código não criado** | eng | E01 |
| 7 | Protótipo promete "Configurações" sem requisito (PRD §6.1) | design | E08 |

> As pendências 3, 4 e 5 são **espera por terceiro** — a assistência de IA não as encurta,
> e o PRD §10 já as declara como marcos duros que param o cronograma.

---

## Mapa de artefatos por etapa

`✅ pronto` · `🟡 gabarito (preenche na execução)` · `⬜ todo`

### Etapa 0 — Bootstrap
| Artefato | Status |
|---|:-:|
| [INDEX.md](INDEX.md) | ✅ |
| [CONVENCOES-IDS.md](CONVENCOES-IDS.md) | ✅ |
| [DECISION_LOG.md](DECISION_LOG.md) | ✅ |
| [READINESS.md](READINESS.md) | ✅ |
| [DOCUMENTATION.md](DOCUMENTATION.md) | ✅ |
| [CLAUDE.md](CLAUDE.md) | ✅ |
| [ai-agent/catalogo-D0.md](ai-agent/catalogo-D0.md) | ✅ |

### Etapa 1 — Idealizar
| Artefato | Status |
|---|:-:|
| [product/VISION.md](product/VISION.md) | ✅ |
| [discovery/LEAN_CANVAS.md](discovery/LEAN_CANVAS.md) | ✅ |
| [discovery/STAKEHOLDER_MATRIX.md](discovery/STAKEHOLDER_MATRIX.md) | ✅ |
| [product/METRICS.md](product/METRICS.md) | ✅ |

### Etapa 2 — Descobrir
| Artefato | Status |
|---|:-:|
| [discovery/EVENT_STORMING.md](discovery/EVENT_STORMING.md) | ✅ |
| [discovery/GLOSSARIO_UBIQUO.md](discovery/GLOSSARIO_UBIQUO.md) | ✅ |
| [product/PERSONAS.md](product/PERSONAS.md) | ✅ |
| [discovery/USER_STORY_MAP.md](discovery/USER_STORY_MAP.md) | ✅ |
| [discovery/IMPACT_MAP.md](discovery/IMPACT_MAP.md) | ✅ |

### Etapa 3 — Viabilizar
| Artefato | Status |
|---|:-:|
| [RISKS.md](RISKS.md) | ✅ |
| [REFERENCIAS.md](REFERENCIAS.md) | ✅ |
| [MARKET.md](MARKET.md) | ✅ |

### Etapa 4 — Especificar
| Artefato | Status |
|---|:-:|
| [PRD-plataforma-rifa-mvp.md](PRD-plataforma-rifa-mvp.md) | ✅ (v1.6, pendência 1) |
| [requirements/SRS.md](requirements/SRS.md) | ✅ |
| [requirements/USER_STORIES.md](requirements/USER_STORIES.md) | ✅ |
| [requirements/BUSINESS_RULES.md](requirements/BUSINESS_RULES.md) | ✅ |
| [requirements/MOSCOW_BACKLOG.md](requirements/MOSCOW_BACKLOG.md) | ✅ |
| [requirements/DOR_DOD.md](requirements/DOR_DOD.md) | ✅ |
| [requirements/TRACEABILITY_MATRIX.md](requirements/TRACEABILITY_MATRIX.md) | ✅ |
| [requirements/GAP_ANALYSIS.md](requirements/GAP_ANALYSIS.md) | ✅ |
| [requirements/ACCEPTANCE_CRITERIA_GHERKIN.md](requirements/ACCEPTANCE_CRITERIA_GHERKIN.md) | ✅ |
| [cenarios/](cenarios/) — 21 `.feature` | ✅ |
| [product/MVP_SCOPE.md](product/MVP_SCOPE.md) | ✅ |

### Etapa 5 — Prototipar
| Artefato | Status |
|---|:-:|
| [prototipacao/hi-fi/](prototipacao/hi-fi/) — 18 telas | ✅ |
| [prototipacao/DESIGN.md](prototipacao/DESIGN.md) | ✅ |
| [prototipacao/UX_REVIEW.md](prototipacao/UX_REVIEW.md) | ✅ |
| [pages-model/PAGES.md](pages-model/PAGES.md) | ✅ |

### Etapa 6 — Arquitetar ★
| Artefato | Status |
|---|:-:|
| [SPEC-TECNICA-plataforma-rifa-mvp.md](SPEC-TECNICA-plataforma-rifa-mvp.md) | ✅ (v1.6) |
| [adrs/](adrs/) — 26 na SPEC §12; 9 em formato longo | ✅ |
| [models/c4/](models/c4/) — C1, C2, C3-apuração | ✅ |
| [models/erd/ERD-CONCEITUAL.md](models/erd/ERD-CONCEITUAL.md) | ✅ |
| [models/state-machines/](models/state-machines/) | ✅ |
| [models/use-cases/USE-CASES.md](models/use-cases/USE-CASES.md) | ✅ |
| [security/THREAT_MODEL.md](security/THREAT_MODEL.md) | ✅ |
| [ai-agent/council-sessions/](ai-agent/council-sessions/) — 3 pautas | 🟡 |

### Etapa 7 — Contratar
| Artefato | Status |
|---|:-:|
| `contracts/openapi/` — gerado do build, não versionado | 🟡 |
| [contracts/events/CATALOG.md](contracts/events/CATALOG.md) | ✅ |
| [contracts/CONVENTIONS.md](contracts/CONVENTIONS.md) | ✅ |
| [contracts/diagrams/sequence/SEQUENCES.md](contracts/diagrams/sequence/SEQUENCES.md) | ✅ |
| [contracts/providers/PARITY-MATRIX.md](contracts/providers/PARITY-MATRIX.md) | ✅ |

### Etapa 8 — Modelar dados
| Artefato | Status |
|---|:-:|
| [DATA_DICTIONARY.md](DATA_DICTIONARY.md) | ✅ |
| [models/erd/ERD-LOGICO.md](models/erd/ERD-LOGICO.md) | ✅ |

### Etapa 9 — Infra ★
| Artefato | Status |
|---|:-:|
| [infra/CI_CD.md](infra/CI_CD.md) | ✅ |
| [infra/ENVIRONMENTS.md](infra/ENVIRONMENTS.md) | ✅ |
| [infra/OBSERVABILITY.md](infra/OBSERVABILITY.md) | ✅ |
| [infra/SECRETS.md](infra/SECRETS.md) | ✅ |
| [infra/COST_MODEL.md](infra/COST_MODEL.md) | ✅ |

### Etapa 10 — Planejar
| Artefato | Status |
|---|:-:|
| [backlog/ROADMAP.md](backlog/ROADMAP.md) | ✅ |
| [backlog/EPICS.md](backlog/EPICS.md) | ✅ |
| [backlog/BACKLOG.md](backlog/BACKLOG.md) | ✅ |
| [backlog/TASK_DETAILS.md](backlog/TASK_DETAILS.md) | ✅ |
| [backlog/waves/WAVES.md](backlog/waves/WAVES.md) | ✅ |
| [backlog/PARALLEL_TRACKS.md](backlog/PARALLEL_TRACKS.md) | ✅ |
| [models/DEPENDENCY-GRAPH.md](models/DEPENDENCY-GRAPH.md) | ✅ |
| [EXECUTION_PLAN.md](EXECUTION_PLAN.md) | ✅ |
| [TASK_AUTHORING_RULES.md](TASK_AUTHORING_RULES.md) | ✅ |
| [backlog/BACKLOG.md](backlog/BACKLOG.md) — 63 itens por épico | ✅ |

### Etapa 11 — Executar
| Artefato | Status |
|---|:-:|
| [AI_WORKFLOW.md](AI_WORKFLOW.md) | ✅ |
| [PADRAO_ESCRITA_JIRA.md](PADRAO_ESCRITA_JIRA.md) | ✅ |
| [dispatch/README.md](dispatch/README.md) | 🟡 gabarito |
| [run-logs/README.md](run-logs/README.md) | 🟡 gabarito |
| [review/REVIEW_REPORT.md](review/REVIEW_REPORT.md) | 🟡 gabarito |

### Etapa 12 — Validar
| Artefato | Status |
|---|:-:|
| [qa/QA_STRATEGY.md](qa/QA_STRATEGY.md) | ✅ |
| [qa/TEST_DATA_STRATEGY.md](qa/TEST_DATA_STRATEGY.md) | ✅ |
| [qa/GHERKIN_BY_BR.md](qa/GHERKIN_BY_BR.md) | ✅ |
| [qa/EXPLORATORY_TEST_CHARTERS.md](qa/EXPLORATORY_TEST_CHARTERS.md) | ✅ |
| [qa/load-tests/README.md](qa/load-tests/README.md) — scripts em E10 | 🟡 |
| [TEST_EVIDENCE_POLICY.md](TEST_EVIDENCE_POLICY.md) | ✅ |
| [security/SECURITY_CHECKLIST_BY_FEATURE.md](security/SECURITY_CHECKLIST_BY_FEATURE.md) | ✅ |

### Etapa 13 — Lançar ★
| Artefato | Status |
|---|:-:|
| [release/ROLLOUT_PLAN.md](release/ROLLOUT_PLAN.md) | ✅ |
| [release/SMOKE_TESTS.md](release/SMOKE_TESTS.md) | ✅ |
| [release/RELEASE_NOTES.md](release/RELEASE_NOTES.md) | 🟡 gabarito |
| [go-to-market/ONE_PAGER.md](go-to-market/ONE_PAGER.md) | ✅ |
| [go-to-market/DECK_EXECUTIVO.md](go-to-market/DECK_EXECUTIVO.md) | ✅ |
| [go-to-market/CALCULADORA_ROI.md](go-to-market/CALCULADORA_ROI.md) | ✅ |

### Etapa 14 — Atender
| Artefato | Status |
|---|:-:|
| [client/ONBOARDING_CLIENTE.md](client/ONBOARDING_CLIENTE.md) | ✅ |
| [client/FAQ.md](client/FAQ.md) | ✅ |
| [ops/runbooks/](ops/runbooks/) — 3 runbooks | ✅ |

---

## Convenção de status

Artefato marcado 🟡 **gabarito** descreve o que *será* registrado quando a execução acontecer.
Ele traz estrutura, campos e critérios — **nunca** afirma execução que não ocorreu. Um
`RELEASE_NOTES.md` que descreve uma release inexistente é ficção, e envelhece como tal.
