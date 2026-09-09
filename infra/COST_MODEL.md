---
id: cost-model
etapa: 9
data: 2026-09-08
status: done
---

# MODELO DE CUSTO — Dream RI

> **Aviso.** Nenhum valor aqui foi cotado. São **estruturas de custo** e os fatores que os
> dirigem, não preços. Antes de precificar o produto, cotar cada linha marcada ⚠️.

## Custos recorrentes de operação

| Item | Natureza | Dirigido por | Cotado? |
|---|---|---|:-:|
| VPS (API + workers) | Fixo | — | ⚠️ |
| Postgres gerenciado | Fixo | Volume de `numero_sorte` | ⚠️ |
| Redis gerenciado | Fixo | — | ⚠️ |
| Object storage | Variável | Tamanho e retenção dos snapshots | ⚠️ |
| **Carimbo do tempo (ACT)** | **Por campanha** | Nº de campanhas | ⚠️ **crítico** |
| Contas de loja (Apple/Google) | Anual | — | ⚠️ |
| Taxa Pix | Por transação | **Paga pelo operador**, não por nós | — |

## O custo que pode inviabilizar campanhas pequenas

**O carimbo é por campanha, não por venda.** Uma campanha de 100 números paga o mesmo carimbo que
uma de 1 milhão. Se o preço unitário for alto, campanhas pequenas ficam inviáveis.

Se isso acontecer, a saída **não** é trocar por blockchain (perderia a validade da MP 2.200-2) —
é **agregar**: um carimbo cobrindo a raiz de várias campanhas. Preserva a validade legal e dilui
o custo, ao preço de acoplar cronogramas de campanhas distintas. Registrado em
[ADR-005](../adrs/ADR-005-carimbo-rfc3161.md).

## Dimensionamento técnico

| Recurso | Driver | Ordem de grandeza |
|---|---|---|
| Linhas em `numero_sorte` | 1 por número por campanha | 1M por campanha grande |
| Snapshot | ~80 bytes por número pago | ~40 MB em 500k pagos |
| Argon2id na fase 2 | 64 MiB × paralelismo | **Não dimensionado** — [G-13](../requirements/GAP_ANALYSIS.md) |
| Pico de checkout | 500 req/s por 60s | RNF-02 |

> **G-13 é a lacuna de custo mais concreta:** Argon2id com `m=64MiB` em 1M de folhas exige pool
> de workers, e o tamanho desse pool define quanta RAM a máquina precisa no dia do congelamento.
> Isso não foi medido, e é o tipo de coisa que aparece como surpresa na semana 3.

## Receita — o que a arquitetura permite

ADR-017 (sem custódia) **elimina** o percentual sobre arrecadação: o dinheiro nunca passa por nós.
Restam licença por campanha ou mensalidade do operador — o que também é a posição do PRD §11 e da
Q5, que recusa o percentual conscientemente.

Isso tem consequência de precificação: a receita **não escala com o sucesso da campanha**. Uma
rifa de R$ 500 mil paga o mesmo que uma de R$ 5 mil. Vantagem: o operador não teme o crescimento.
Desvantagem: o upside é limitado, e o preço precisa cobrir o custo do carimbo mesmo na campanha
menor.
