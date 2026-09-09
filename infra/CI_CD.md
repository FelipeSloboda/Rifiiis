---
id: ci-cd
etapa: 9
data: 2026-09-08
status: done
---

# CI/CD — Dream RI

## Pipeline

```
lint → typecheck → test:unit → test:integration → build → migrate → deploy
                                      ↓
                        job separado: eas build (app)
```

## Gates que bloqueiam merge

| Gate | Critério | Por quê |
|---|---|---|
| Lint + typecheck | zero erro; **zero `any`** | Regra de engenharia da casa |
| Cobertura global | > 90% | RNF-03 |
| **Cobertura de domínio** | **100%** | O domínio não tem I/O — não há desculpa |
| Testes de concorrência | verdes, **sem skip** | RNF-01. `--force` é proibido (ADR-012) |
| Teste `crypto-shredding` | verde | RNF-07 |
| Vetores externos | RFC 6962/3161/9106 conferem | ADR-012 |
| `security-auditor` | zero crítico/alto | Etapa 11 da esteira |
| axe-core | zero critical/serious | RNF-09 |

## A regra que parece burocracia e não é

> **Nenhum `--force` ou skip em teste de concorrência.**

O teste de corrida é flaky por natureza, e a tentação de silenciá-lo aparece exatamente quando
ele começa a pegar algo. Um skip aqui é o começo do incidente — por isso é gate de CI, não
convenção de time.

## Migrations

- SQL puro versionado (`.sql`), sem ORM (ADR-024).
- **`migrate deploy` roda antes do smoke**, sempre.
- Toda migration é validada **do zero** em banco limpo — não só contra o de desenvolvimento.

> Aplicar migration num banco que já tem estado acumulado esconde a falha que aparece em
> produção. É o item da DoD que mais costuma ser pulado.

## Testes por nível

| Nível | Ferramenta | Escopo |
|---|---|---|
| Unitário | Vitest | Agregados, VOs, políticas, Merkle. **Sem mocks** — domínio é puro |
| Integração | Vitest + Testcontainers | Repositórios contra **Postgres real** (SQLite não faz `SKIP LOCKED`) |
| Contrato | Pact / fixtures gravadas | Adapters de PSP e Federal |
| E2E web | Playwright | comprar → pagar → verificar |
| E2E app | Maestro | Fluxo no emulador Android |
| Carga | k6 | 500 req/s no checkout por 60s |

## Ambientes e deploy

| Ambiente | Gatilho | Dados |
|---|---|---|
| Preview | PR aberto | Sintéticos |
| Homologação | merge em `main` | Sintéticos + campanha de ensaio |
| Produção | tag manual | Reais |

**O app não segue o mesmo ciclo.** `eas build` roda em job separado e a distribuição depende da
fila de revisão das lojas. Uma mudança de contrato incompatível quebra quem não atualizou — por
isso o contrato é aditivo por padrão (ver [contracts/CONVENTIONS.md](../contracts/CONVENTIONS.md)).

## Segredos no CI

Nenhum segredo no repositório. Injetados por variável de ambiente do runner. A KEK que embrulha
as DEKs dos titulares **nunca** entra no CI — o teste de shredding usa chave de teste.
