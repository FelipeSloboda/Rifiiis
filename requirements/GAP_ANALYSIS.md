---
id: gap-analysis
etapa: 4
data: 2026-09-08
status: done
---

# GAP ANALYSIS — Dream RI

> **Método.** Este documento compara o que os documentos *prometem* com o que existe. Não há
> código ainda, então todo gap de implementação é trivialmente "tudo falta" — e dizer isso não
> ajuda. O que segue são as lacunas **de planejamento**: promessa sem contrapartida, decisão
> pendente, e dependência não iniciada.

---

## 1. Gaps entre PRD e SPEC

| # | Gap | Severidade | Ação |
|---|---|:-:|---|
| G-01 | PRD usa `R10` para dois requisitos | **Alta** | Resolvido em [D1](../DECISION_LOG.md); PRD precisa ser corrigido |
| G-02 | PRD §6 não numera RNFs | Média | Resolvido: RNF-01..16 criados em CONVENCOES-IDS |
| G-03 | PRD cita "R9.5" no cronograma sem defini-lo em §6 | Baixa | Inferido como entrega do prêmio pela visão do operador |

## 2. Gaps entre protótipo e requisitos

| # | Gap | Severidade | Ação |
|---|---|:-:|---|
| G-04 | Navegação mostra "Configurações" sem requisito | Média | Remover do protótipo (PRD §6.1 já registra) |
| G-05 | R2 não tem tela | — | Correto: é backend puro |
| G-06 | Não há tela para exclusão de dados (US-031) | Média | Definir: canal de atendimento ou tela? **Decisão pendente** |
| G-07 | Não há tela de desativação de operador (US-018) | Média | A rota existe na SPEC §8; falta a tela |

## 3. Gaps de dependência externa

| # | Gap | Severidade | Bloqueia |
|---|---|:-:|---|
| G-08 | Conta PicPay não aprovada | **Crítica** | E04 |
| G-09 | ACT não contratada | **Crítica** | E05 — e a tese |
| G-10 | Contas de loja não abertas | Alta | E09 |
| G-11 | Repositório de código não criado | Alta | E01 |
| G-12 | Board Jira `DRI` não existe | Alta | Etapa 11 da esteira |

## 4. Gaps de definição técnica

| # | Gap | Severidade | Ação |
|---|---|:-:|---|
| G-13 | Pool de workers da fase 2 (Argon2id em 1M de folhas) não dimensionado | Média | Medir no hardware alvo antes de E05 |
| G-14 | Parâmetros do Argon2id não benchmarkados no hardware de produção | Média | RFC 9106 dá o piso; subir `t` se houver folga |
| G-15 | Fonte secundária da Loteria Federal não identificada nominalmente | **Alta** | Definir antes de E06 — a cascata depende disso |
| G-16 | Regra de aproximação tem casos degenerados listados mas não exaustivos | Média | Fechar a tabela em E06 com o operador |
| G-17 | Prazo de anonimização (5 anos) é premissa, não decisão do contrato | Baixa | Confirmar no contrato de operação |

## 5. Gaps de processo

| # | Gap | Severidade | Ação |
|---|---|:-:|---|
| G-18 | Snapshot de especialistas (`ai-agent/catalogo-D0.md`) não foi tirado do MCP | Baixa | Rodar antes da 1ª sessão de council |
| G-19 | Nenhuma sessão de council rodou ainda | Média | E06 exige 6 especialistas (perfil full) |

---

## Os três que realmente importam

Ignorando os administrativos, o que muda o resultado do projeto:

1. **G-09 (ACT)** — sem carimbo não há prova, e não há plano B. É o gap mais caro do projeto.
2. **G-15 (fonte secundária)** — a cascata primária→secundária→manual está desenhada, mas a
   secundária não tem nome. Uma cascata com um degrau indefinido é uma cascata de dois degraus.
3. **G-06 (exclusão de dados)** — a SPEC tem o mecanismo completo (crypto-shredding), mas não há
   caminho definido para o titular *pedir*. Mecanismo sem porta de entrada não atende o art. 18.
