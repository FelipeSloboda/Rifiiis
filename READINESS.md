---
id: readiness
etapa: 0
perfil: full
projeto: Dream RI
sigla: DRI
data: 2026-09-08
status: done
---

# READINESS — Dream RI (DRI)

Perfil escolhido: **full** — produto crítico (dinheiro de terceiro, sorteio regulado, LGPD com
titular vulnerável) com prazo de 6 semanas e superfície tripla (app, web, API).

---

## Por que full, e não standard

| Critério do `_template/READINESS.md` | Situação no DRI |
|---|---|
| Regulado | ✅ Sorteio exige autorização de órgão; SPEC §9 trata LGPD com crypto-shredding |
| Crítico | ✅ Dinheiro de terceiro, irreversibilidade por design, prova pública |
| Squad | 🟡 Time pequeno, mas a esteira de 20 etapas roda com agentes |
| Superfície múltipla | ✅ app Expo + web + API + verificador público |

Três dos quatro critérios batem. O que empurra decisivamente é o **custo do erro**: uma apuração
errada não é bug, é o produto inteiro perdendo a tese.

---

## Council obrigatório (perfil full)

| Etapa | Sessão | Especialistas | Status |
|---|---|---|:-:|
| 6 Arquitetar | `E06-arquitetura.md` | 6 | ✅ |
| 9 Infra | `E09-infra.md` | 4 | ✅ |
| 11 Executar | por PR crítico (E03, E05, E06) | 3 | 🟡 na execução |
| 13 Lançar | `E13-go-live.md` | 4 | ✅ |

---

## Gates de qualidade

| Gate | Alvo | Onde se mede | Bloqueia |
|---|---|---|---|
| Cobertura global | > 90% | CI | merge |
| Cobertura de domínio | **100%** | CI | merge |
| Concorrência (RNF-01) | zero número duplicado em 500 req/s | `qa/load-tests/` | merge |
| Crypto-shredding (RNF-07) | cadeia válida antes e depois | CI | merge |
| a11y (RNF-09) | axe-core sem critical/serious | `a11y-auditor` | merge |
| Segurança | zero crítico/alto | `security-auditor` | merge |
| Verificação externa | apuração conferida por terceiro só com o verificador | marco D+21 | go-live |

> **A regra que não se negocia** (SPEC §11): em R2, R4 e R6 os vetores de teste vêm de fonte
> externa (RFC 6962, RFC 3161). Implementação errada e teste errado concordam entre si; vetor
> publicado não concorda com nenhum dos dois.

---

## Promoção de perfil

Não se aplica — o projeto **nasce** full. O caminho inverso (rebaixar para standard) só faria
sentido se o escopo perdesse a apuração verificável, que é a tese do produto.
