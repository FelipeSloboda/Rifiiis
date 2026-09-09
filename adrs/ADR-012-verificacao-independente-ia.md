# ADR-012 — Código de concorrência e cripto não é aceito contra teste da mesma sessão de IA

**Status:** aceita · **Data:** 2026-08 · **Contexto:** SPEC §11

## Contexto

Todo o código deste projeto é escrito com assistência de IA. Isso é ganho real na maior parte do
sistema — boilerplate, DTO, telas, adapters, migrations. Mas cria um modo de falha específico:

> **O gerador e o verificador compartilham o ponto cego** quando a mesma sessão escreve o código
> e o teste. O teste passa porque testa o que o autor pensou, não o que o requisito exige.

Onde isso é apenas incômodo (CRUD, tela), segue o fluxo normal. Onde o erro é **silencioso e
destrói o produto** — R2 (concorrência), R4 (commitment), R6 (apuração) — não é aceitável.

## Decisão

Nesses três requisitos vale o protocolo:

| Regra | Motivo |
|---|---|
| Vetores de teste **externos** (RFC 6962, RFC 3161, RFC 9106) | Implementação errada e teste errado concordam entre si. Vetor publicado não concorda com nenhum dos dois |
| Teste de concorrência escrito **antes** do alocador, rodado contra implementação deliberadamente ingênua | Teste de corrida que nunca falhou não prova nada — pode estar medindo serialização acidental |
| Revisão humana da **invariante**, não do diff | A IA acerta a sintaxe do lock e erra qual predicado precisa ser atômico |
| Nenhum `--force` ou skip em teste de concorrência no CI | O teste é flaky por natureza; silenciá-lo é o começo do incidente |
| Cripto comparada com implementação de referência independente (ex.: recomputar a raiz em Python) | Duas implementações independentes concordando é evidência; uma passando no próprio teste não é |

## Alternativa recusada

**Confiar na suíte gerada junto com o código.** É o fluxo normal e funciona na maior parte do
sistema — mas em R2/R4/R6 o custo do erro não é um bug, é o produto perdendo a tese.

## Consequências

- 44 cenários marcados `@critico` em [cenarios/](../cenarios/) seguem este protocolo.
- O cronograma **não** aplicou ganho de produtividade de IA nesses três pontos (PRD §0).
- A DoD tem itens específicos: vetor externo nomeado, teste de corrida provado contra ingênua.

## A frase que resume

**A IA escreve; a aceitação vem de fonte que a IA não produziu.**
