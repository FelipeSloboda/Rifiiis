---
id: ai-workflow
etapa: 11
data: 2026-09-08
status: done
---

# AI WORKFLOW — esteira de entrega · Dream RI

20 etapas por ticket. **Gate bloqueante** impede merge; **gate de raia** impede avanço no board.

## Raias

```
lane:backlog → lane:pronto-p-dev → lane:em-dev → lane:review → lane:done
```

## A esteira

| # | Etapa | Agente | Bloqueia | Variante DRI |
|:-:|---|---|:-:|---|
| 1 | Refinamento | `po-reviewer` | raia | Exige linha na matriz de rastreabilidade |
| 2 | Plano técnico | `tech-reviewer` | raia | — |
| 3 | Smoke do ambiente | `repo-health` | merge | — |
| 4 | Testes red-first | `tdd-writer` | raia | **Em R2/R4/R6, vetor externo obrigatório** |
| 5 | Implementação | `feature-dev` | — | — |
| 6 | Council (PR crítico) | — | raia | E03, E05, E06 |
| 7 | i18n | `i18n-auditor` | raia | PT-BR apenas no MVP; `n/a` em backend |
| 8 | Telemetria | `telemetry-checker` | raia | **Confirma ausência de PII em log** |
| 9 | Abrir PR | `pr-author` | — | — |
| 10 | Revisão de código | `code-reviewer` | merge | — |
| 11 | Segurança | `security-auditor` | merge | Crítico/alto bloqueia |
| 12 | Integração | `integration-tester` | merge | Testcontainers com Postgres real |
| 13 | Performance | `perf-auditor` | merge | **E03/E05 sempre, mesmo sem endpoint novo** |
| 14 | Acessibilidade | `a11y-auditor` | merge | axe-core nos dois temas; `n/a` em backend |
| 15 | E2E | `e2e-web` / `e2e-mobile` | merge | **Maestro em E09**, Playwright no resto |
| 16 | Aceite | `acceptance-validator` | merge | Cruza contra o `.feature` |
| 17 | Changelog | `release-notes` | — | Keep a Changelog |
| 18 | Docs | `docs-updater` | — | Inclui `graphify update .` |
| 19 | Evidências | `task-reporter` | — | — |
| 20 | Merge e transição | `release-manager` | merge | Squash + delete branch |

---

## Gates específicos deste produto

### Etapa 4 — o teste vem antes, e precisa falhar

Em R2, R4 e R6 (label `critico`):

1. O teste é escrito **antes** da implementação.
2. Os vetores vêm de **fonte externa** nomeada no ticket (RFC 6962, 3161, 9106).
3. Para concorrência: o teste roda contra implementação ingênua e **é visto falhando**.

Sem o passo 3, o teste pode estar medindo serialização acidental — e um teste de corrida que
nunca falhou não prova nada.

### Etapa 13 — performance em E03 e E05 mesmo sem endpoint

O que degrada nesses épicos não é latência de rota: é **contenção de lock** (E03) e **tempo de
construção da árvore** (E05). O `perf-auditor` roda com budget próprio.

### Etapa 11 — segurança com foco nas 22 críticas

O `security-auditor` cruza contra [security/THREAT_MODEL.md](security/THREAT_MODEL.md). As
ameaças 🔴 que tocam o ticket precisam ter mitigação demonstrada, não declarada.

---

## O que a esteira **não** substitui

**Revisão humana da invariante** (ADR-012). Nenhum agente aprova R2, R4 ou R6 sozinho: a IA
acerta a sintaxe do lock e erra qual predicado precisa ser atômico. A revisão é de uma pessoa,
sobre a invariante, não sobre o diff.

Isso está aqui porque a esteira é convincente o bastante para criar a ilusão de que cobre tudo.

## Council obrigatório (perfil full)

| Etapa | Sessão | Especialistas |
|---|---|---|
| 6 Arquitetura | `E06-arquitetura.md` | 6 |
| 9 Infra | `E09-infra.md` | 4 |
| 11 PR crítico | por PR de E03/E05/E06 | 3 |
| 13 Go-live | `E13-go-live.md` | 4 |
