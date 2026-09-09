---
id: catalogo-agentes
etapa: 0
data: 2026-09-08
status: done
---

# Catálogo de agentes e especialistas — D0

Snapshot dos recursos do ai-squad-os disponíveis para este projeto na data do bootstrap.

## Agentes da esteira (AI_WORKFLOW.md)

| Etapa | Agente | Bloqueia merge |
|---|---|:-:|
| 1 | `po-reviewer` | avanço de raia |
| 2 | `tech-reviewer` | avanço de raia |
| 3 | `repo-health` | ✅ |
| 4 | `tdd-writer` | avanço de raia |
| 5 | `feature-dev` | — |
| 7 | `i18n-auditor` | avanço de raia |
| 8 | `telemetry-checker` | avanço de raia |
| 9 | `pr-author` | — |
| 10 | `code-reviewer` | ✅ |
| 11 | `security-auditor` | ✅ |
| 12 | `integration-tester` | ✅ |
| 13 | `perf-auditor` | ✅ |
| 14 | `a11y-auditor` | ✅ |
| 15 | `e2e-web` · `e2e-mobile` | ✅ |
| 16 | `acceptance-validator` | ✅ |
| 17 | `release-notes` | — |
| 18 | `docs-updater` | — |
| 19 | `task-reporter` | — |
| 20 | `release-manager` | ✅ |

**Variante deste projeto:** E09 (app Expo) usa `e2e-mobile` (Maestro); os demais usam `e2e-web`
(Playwright). E03 e E05 exigem `perf-auditor` mesmo sem mudança de endpoint — a regressão que
importa ali é de concorrência e de construção da árvore.

## Especialistas consultáveis (RAG)

Consultados via `rag_search` antes de decisão de arquitetura. Relevantes ao domínio:

| Slug | Uso previsto |
|---|---|
| `juridico-contratos` | LGPD, base legal, retenção (SPEC §9) |
| `seguranca-appsec` | STRIDE, OWASP, cripto (E05, E07) |
| `arquitetura-software` | fronteiras de BC, portas/adapters |
| `qa-testes` | estratégia de teste, dados sintéticos |

> **Pendência.** O snapshot não foi tirado com `kg_agents`/`rag_list_specialists` — o MCP
> `alter-ego-gl` não foi consultado neste bootstrap. Os slugs acima são os esperados pelo
> padrão da casa e **devem ser confirmados** antes da primeira sessão de council da E06.
