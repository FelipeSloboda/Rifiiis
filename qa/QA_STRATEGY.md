---
id: qa-strategy
etapa: 12
data: 2026-09-08
status: done
fonte: SPEC §11
---

# ESTRATÉGIA DE QA — Dream RI

## Meta

**> 90% global, 100% no domínio.** O domínio não tem I/O — não há desculpa para menos que 100%.

## Pirâmide

| Nível | Ferramenta | Escopo | Mocks |
|---|---|---|---|
| Unitário | Vitest | Agregados, VOs, políticas, Merkle | **Nenhum** — o domínio é puro |
| Integração | Vitest + Testcontainers | Repositórios contra Postgres real | — |
| Contrato | Pact / fixtures gravadas | Adapters de PSP e Federal | — |
| E2E web | Playwright | comprar → pagar → verificar | PSP em sandbox |
| E2E app | Maestro | Fluxo em emulador Android | — |
| Carga | k6 | 500 req/s no checkout por 60s | — |

**SQLite não é opção** nos testes de integração: não reproduz `SKIP LOCKED`, que é exatamente a
propriedade sob teste.

---

## A regra que define este projeto

> **A IA escreve; a aceitação vem de fonte que a IA não produziu.**

| Regra | Onde se aplica | Por quê |
|---|---|---|
| Vetores externos (RFC 6962, 3161, 9106) | R4, R6, cripto | Implementação errada e teste errado concordam entre si |
| Teste de concorrência **antes** do alocador, provado contra ingênua | R2 | Teste que nunca falhou pode medir serialização acidental |
| Revisão humana da **invariante** | R2, R4, R6 | A IA acerta a sintaxe do lock e erra o predicado atômico |
| Implementação de referência independente (recomputar a raiz em Python) | R4 | Duas implementações concordando é evidência |
| **Zero skip/`--force` em concorrência no CI** | R2 | Silenciar o flaky é o começo do incidente |

---

## Testes obrigatórios que não são de feature

| Teste | O que prova | Roda em |
|---|---|---|
| `crypto-shredding` | Apagar a chave não quebra a cadeia de auditoria | CI, toda build |
| Concorrência de alocação | Zero colisão sob 100 pedidos simultâneos | CI |
| Concorrência **contra ingênua** | O teste tem poder de detecção | CI |
| Salts distintos | Índice e leaf nunca coincidem | CI |
| Retenção com relógio adiantado | Expurgo em D+90 funciona | CI |
| Migration em banco limpo | A migration roda do zero | CI |
| Recomputação da raiz por script independente | A árvore está correta | CI |

## Dados de teste

Sintéticos sempre. Nunca CPF real, mesmo em homologação — o CPF sintético precisa passar no
dígito verificador para exercitar o `cpf_indice` de verdade.

## O que não está coberto por automação

| Lacuna | Mitigação |
|---|---|
| A ACT responde de verdade | Ensaio no marco D+21, ambiente de homologação com ACT real |
| A Federal publica no formato esperado | Fixture gravada + ensaio real |
| Loja aceita o app | Nenhuma — é decisão de terceiro |
| **O comprador entende a prova** | Nenhuma. RSK-01 continua aberto |

O último item é o mais importante e o menos testável: nenhuma suíte responde se a verificabilidade
tem valor percebido. Só a primeira campanha real responde.
