---
id: test-data-strategy
etapa: 12
data: 2026-09-08
status: done
---

# ESTRATÉGIA DE DADOS DE TESTE — Dream RI

## Princípio

**Nenhum dado real em ambiente não-produtivo.** Não é preferência: o produto trata CPF, e um
vazamento em homologação tem o mesmo peso legal que em produção.

## Geração

| Dado | Como gerar | Cuidado |
|---|---|---|
| CPF | Sintético **com dígito verificador válido** | Um CPF inválido não exercita o `cpf_indice` de verdade |
| Nome, telefone, e-mail | Faker com seed fixa | Seed fixa = teste reproduzível |
| Campanha | Fixture por cenário | Uma por estado da máquina |
| Extração da Federal | **Fixture gravada de extração real** | O formato precisa ser o de verdade |
| Snapshot | Gerado a partir das fixtures | — |
| Vetores Merkle | **RFC 6962 — nunca gerados** | ADR-012 |
| Token RFC 3161 | Exemplo da RFC + ACT real em homologação | — |

## Volumes

| Cenário | Volume | Para quê |
|---|---|---|
| Unitário | 10–100 números | Rapidez |
| Integração | 1.000 números | Cobre o índice parcial |
| Concorrência | 100 pedidos × 10 números | A invariante de RNF-01 |
| Carga | 1M números, 500 req/s | RNF-02 |
| Merkle | 1M folhas | RNF-04 e o pool de Argon2id |

## Chaves criptográficas

| Ambiente | KEK |
|---|---|
| Teste / CI | **Chave de teste**, descartável |
| Homologação | Chave própria de homologação |
| Produção | Gerenciador externo, jamais no CI |

É a chave de teste que permite ao CI apagar DEKs livremente no teste `crypto-shredding` — o teste
só é possível porque as chaves são isoladas.

## Limpeza

Testcontainers sobe banco novo por suíte. Nenhum teste depende de estado deixado por outro.

> **Estado residual é a causa de falha E2E que "muda de lugar".** Quando um E2E falha em pontos
> diferentes a cada execução, o suspeito é armazenamento local ou banco sujo — não timing.
