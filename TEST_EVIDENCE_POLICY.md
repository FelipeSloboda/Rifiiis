---
id: test-evidence-policy
etapa: 12
data: 2026-09-08
status: done
---

# POLÍTICA DE EVIDÊNCIA — Dream RI

## Princípio

**Afirmação sem evidência não fecha ticket.** "Testei e funciona" não é evidência; a saída do
teste é.

## O que conta como evidência

| Tipo | Aceita | Não aceita |
|---|---|---|
| Teste automatizado | Saída do runner com nome do cenário | "Os testes passam" |
| Cobertura | Relatório com o número | "Está acima de 90%" |
| Concorrência | Saída mostrando **a falha contra a ingênua** e o sucesso contra a real | Só o sucesso |
| Cripto | Comparação com o vetor da RFC, com os dois valores | "Bate com o esperado" |
| E2E | Vídeo ou trace do Playwright/Maestro | Screenshot de tela verde |
| a11y | Relatório do axe-core, dois temas | "Sem violações" |
| Performance | Saída do k6 com percentis | "Rápido o suficiente" |
| Migration | Log da aplicação **em banco limpo** | Log no banco de desenvolvimento |

## A evidência que mais falta

**A falha contra a implementação ingênua.** Anexar só o teste passando prova que a implementação
boa funciona — não prova que o teste detectaria a ruim. Sem as duas metades, o teste de
concorrência é decoração.

## Onde a evidência vive

- No comentário do Jira, postado pelo `task-reporter` (Etapa 19).
- Artefatos grandes (vídeo, trace) como anexo ou link do CI, nunca colados na descrição — o
  limite de ADF estoura.

## Retenção

Evidência de ticket fechado fica no Jira. Evidência dos **marcos** (D+21 especialmente) vai para
`run-logs/`, versionada — é o que sustenta a afirmação de que a apuração foi verificada por
terceiro.
