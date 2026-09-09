---
id: parallel-tracks
etapa: 10
data: 2026-09-08
status: done
---

# TRILHAS PARALELAS — Dream RI

## As quatro trilhas

| Trilha | Escopo | Acopla com |
|---|---|---|
| **T1 · Núcleo** | Domínio, alocação, commitment, apuração | Todas — é o caminho crítico |
| **T2 · Integrações** | PSP, Federal, ACT, storage | T1 nas portas |
| **T3 · Superfícies** | App Expo, web pública, admin | T1 pelo contrato OpenAPI |
| **T4 · Terceiros** | PicPay, ACT, lojas, jurídico | **Não acopla — só bloqueia** |

## Como T3 desacopla de T1

O contrato OpenAPI é gerado dos decorators e o cliente TS é gerado dele. Isso permite que a
superfície seja construída contra o contrato **antes** da implementação estar pronta — desde que
o DTO exista. Na prática: definir os DTOs cedo é o que libera o paralelismo.

## O que **não** pode ser paralelizado

| Sequência | Por quê |
|---|---|
| Teste de concorrência **antes** do alocador | ADR-012 — o teste precisa ser visto falhando contra a implementação ingênua |
| Congelar → snapshot → raiz → carimbo | A ordem é a prova; inverter destrói a tese |
| Cadastro de conta → publicação | Guarda de compliance |
| Entrada manual → segunda confirmação | Dois responsáveis distintos (ADR-016) |

## Risco do paralelismo neste projeto

Com uma equipe pequena e agentes, o gargalo não é execução — é **revisão de invariante**. O
ADR-012 exige revisão humana da invariante em R2, R4 e R6, e essa revisão não paraleliza: é a
mesma cabeça olhando três coisas que não podem estar erradas.

**Consequência de planejamento:** não agendar E03, E05 e E06 para revisão na mesma semana. Eles
já estão em semanas distintas (2, 3 e 4) no roadmap — e essa separação é deliberada, não acidental.
