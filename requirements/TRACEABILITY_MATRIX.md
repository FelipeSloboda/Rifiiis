---
id: traceability-matrix
etapa: 4
data: 2026-09-08
status: done
---

# TRACEABILITY MATRIX — Dream RI

Cadeia completa: **Requisito → Story → Regra → Cenário → Tela → Épico → Teste**.
Uma linha sem cenário é requisito não verificável; uma linha sem tela em requisito com interface
é lacuna de design. Ambos são defeitos de planejamento.

---

## P0 — cobertura completa

| Req | Stories | BRs | Cenário | Tela | Épico | Nível de teste |
|---|---|---|---|---|---|---|
| **R0** | US-002 | BR-001..006, 009, 014 | `R00-acesso-operador` | `00-login` | E01 | unit + integração |
| **R0.5** | US-001, 003, 018 | BR-007, 008, 010..012 | `R00.5-provisionamento` | `00a-provisionamento` | E01 | unit + integração |
| **R1** | US-006, 020 | BR-020..023, 027, 028 | `R01-campanha` | `01a-campanha-admin`, `01-campanha` | E02 | unit + E2E |
| **R2** | US-024 | BR-040..050 | `R02-alocacao-atomica` | — (backend) | E03 | **concorrência** + carga |
| **R3** | US-021, 023, 050 | BR-045, 046, 060..073 | `R03-checkout-pix` | `02-checkout-pix` | E04 | integração + E2E |
| **R4** | US-051, 052, 040, 041 | BR-030..034, 080..091 | `R04-commitment` | `04-apuracao` | E05 | **vetor externo** |
| **R5** | US-026, 027 | BR-092, 093 | `R05-comprovante` | `03-meus-numeros`, `05-verificador` | E05 | unit + E2E |
| **R6** | US-011, 012, 016, 028, 042, 043 | BR-035, 100..111 | `R06-apuracao` | `04-apuracao` | E06 | **vetor externo** + integração |
| **R7** | US-022 | BR-120, 123, 124, 128, 038 | `R07-cadastro-comprador` | `02a-cadastro` | E04 | unit + integração |
| **R7.5** | US-025 | BR-015..018 | `R07.5-painel-comprador` | `03a-acesso-comprador`, `03-meus-numeros` | E04 | integração + E2E |
| **R8** | US-007, 017 | BR-025, 026, 029, 037, 038, 127 | `R08-compliance` | `01-campanha` | E07 | unit + integração |
| **R8.5** | US-014, 029 | BR-039, 112..115 | `R08.5-entrega-premio` | `04-apuracao` | E06 | integração + E2E |
| **R9.1** | US-008 | — | `R09.1-visao-geral` | `06-painel-operador` | E08 | E2E + a11y |
| **R9.2** | US-009 | BR-124, 127 | `R09.2-pedidos-admin` | `08-pedidos-admin` | E08 | E2E + a11y |
| **R9.3** | US-010 | BR-102, 104 | `R09.3-apuracoes-admin` | `07-apuracoes-admin` | E08 | E2E + a11y |
| **R9.4** | US-013 | BR-127 | `R09.4-relatorios` | `09-relatorios` | E08 | E2E |
| **R9.5** | US-014 | BR-112..114 | `R08.5-entrega-premio` | `04-apuracao` (admin) | E06 | E2E |
| **R9.6** | US-030 | — | `R09.6-estados-excecao` | `11-estados-excecao` | E10 | E2E |
| **R10** | US-004, 005, 015 | BR-063, 070, 071, 140..145 | `R10-conta-recebimento` | `10-conta-recebimento` | E02 | integração + E2E |

## RNFs

| RNF | Cenário | Épico | Como se prova |
|---|---|---|---|
| RNF-01 | `RNF-concorrencia`, `R02-alocacao-atomica` | E03 | Teste de corrida com implementação ingênua de controle |
| RNF-02 | `RNF-concorrencia` | E10 | k6, 500 req/s por 60s |
| RNF-03 | — (gate de CI) | todos | Cobertura > 90% / 100% no domínio |
| RNF-04 | `RNF-concorrencia` | E05 | Bench da fase 3 |
| RNF-05 | `RNF-seguranca` | E10 | Smoke de cabeçalhos |
| RNF-06 | `RNF-seguranca`, `R08-compliance` | E07 | `telemetry-checker` |
| RNF-07 | `RNF-lgpd` | E07 | Teste `crypto-shredding` no CI |
| RNF-08 | `R03-checkout-pix` | E04 | Integração |
| RNF-09 | `R09.*` | E08 | axe-core nos dois temas |
| RNF-10 | `RNF-lgpd` | E07 | Relógio adiantado 91 dias |
| RNF-11 | `R00-acesso-operador`, `RNF-seguranca` | E01 | Integração |
| RNF-12 | `R07.5-painel-comprador`, `RNF-seguranca` | E04 | Integração |
| RNF-13 | — | todos | `telemetry-checker` |
| RNF-14 | `RNF-lgpd` | E07 | Salts distintos |
| RNF-15 | — | E09 | Build EAS + submissão |
| RNF-16 | — | E09 | E2E Playwright |

---

## Lacunas conhecidas

| Lacuna | Natureza | Ação |
|---|---|---|
| R2 não tem tela | Correto — é backend puro | Nenhuma. Registrado no PRD §6.1 |
| Protótipo tem "Configurações" sem requisito | Defeito do protótipo | Remover da navegação (pendência 7) |
| RNF-03 e RNF-13 sem cenário Gherkin | São gates de CI, não comportamento | Verificados pela esteira, não por `.feature` |
| R9.5 compartilha cenário com R8.5 | Mesma capacidade, visões diferentes | Aceito — evita duplicação |

## Regra de manutenção

Requisito novo entra **primeiro** em [CONVENCOES-IDS](../CONVENCOES-IDS.md), depois aqui, e só
então vira issue. Issue sem linha nesta matriz não passa no `po-reviewer` (Etapa 1 da esteira).
