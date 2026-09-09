---
id: acceptance-criteria
etapa: 4
data: 2026-09-08
status: done
---

# CRITÉRIOS DE ACEITE — índice

> **Este arquivo é índice, não fonte.** Os critérios executáveis vivem em
> [cenarios/](../cenarios/), um `.feature` por requisito. Quando esta página divergir de um
> `.feature`, o `.feature` vence — é ele que o `acceptance-validator` executa.

## Por que a separação existe

Critério de aceite escrito em prosa dentro da issue envelhece: alguém edita a issue, o teste
continua o mesmo, e a divergência só aparece no fim. Mantendo o critério num arquivo versionado
e executável, a issue **aponta** para ele em vez de copiá-lo.

## Índice por requisito

| Requisito | Arquivo | Cenários | Críticos |
|---|---|---:|---:|
| R0 | [R00-acesso-operador.feature](../cenarios/R00-acesso-operador.feature) | 8 | 3 |
| R0.5 | [R00.5-provisionamento.feature](../cenarios/R00.5-provisionamento.feature) | 6 | 2 |
| R1 | [R01-campanha.feature](../cenarios/R01-campanha.feature) | 7 | 2 |
| R2 | [R02-alocacao-atomica.feature](../cenarios/R02-alocacao-atomica.feature) | 8 | 4 |
| R3 | [R03-checkout-pix.feature](../cenarios/R03-checkout-pix.feature) | 9 | 4 |
| R4 | [R04-commitment.feature](../cenarios/R04-commitment.feature) | 8 | 5 |
| R5 | [R05-comprovante.feature](../cenarios/R05-comprovante.feature) | 6 | 2 |
| R6 | [R06-apuracao.feature](../cenarios/R06-apuracao.feature) | 10 | 5 |
| R7 | [R07-cadastro-comprador.feature](../cenarios/R07-cadastro-comprador.feature) | 5 | 0 |
| R7.5 | [R07.5-painel-comprador.feature](../cenarios/R07.5-painel-comprador.feature) | 6 | 0 |
| R8 | [R08-compliance.feature](../cenarios/R08-compliance.feature) | 7 | 3 |
| R8.5 | [R08.5-entrega-premio.feature](../cenarios/R08.5-entrega-premio.feature) | 6 | 1 |
| R9.1 | [R09.1-visao-geral.feature](../cenarios/R09.1-visao-geral.feature) | 4 | 0 |
| R9.2 | [R09.2-pedidos-admin.feature](../cenarios/R09.2-pedidos-admin.feature) | 5 | 0 |
| R9.3 | [R09.3-apuracoes-admin.feature](../cenarios/R09.3-apuracoes-admin.feature) | 6 | 0 |
| R9.4 | [R09.4-relatorios.feature](../cenarios/R09.4-relatorios.feature) | 4 | 0 |
| R9.6 | [R09.6-estados-excecao.feature](../cenarios/R09.6-estados-excecao.feature) | 6 | 0 |
| R10 | [R10-conta-recebimento.feature](../cenarios/R10-conta-recebimento.feature) | 7 | 2 |
| RNF | [RNF-concorrencia](../cenarios/RNF-concorrencia.feature) · [RNF-lgpd](../cenarios/RNF-lgpd.feature) · [RNF-seguranca](../cenarios/RNF-seguranca.feature) | 18 | 8 |

**Total: 136 cenários, 44 marcados `@critico`.**

## O que `@critico` significa

Erro silencioso que destrói o produto. Nesses cenários:

- vetor de teste vem de **fonte externa**, nunca gerado na sessão que escreveu o código;
- a revisão humana é da **invariante**, não do diff;
- `--force` ou skip no CI é proibido.

A concentração está onde se espera: R2 (alocação), R4 (commitment), R6 (apuração) e os RNFs de
LGPD e segurança somam 26 dos 41.
