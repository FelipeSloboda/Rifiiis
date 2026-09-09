---
id: secrets
etapa: 9
data: 2026-09-08
status: done
---

# SEGREDOS — Dream RI

## Inventário

| Segredo | Onde vive | Rotação | Se vazar |
|---|---|---|---|
| **KEK** (embrulha as DEKs dos titulares) | Gerenciador externo, **nunca no banco** | Anual ou sob incidente | Toda a PII fica exposta — o pior caso |
| `salt_cpf_tenant` | Coluna cifrada sob a KEK | Não rotacionável (quebraria o índice) | Enumeração de CPF fica viável no tenant |
| `salt_campanha` | Coluna cifrada sob a KEK | Por campanha, gerado uma vez | Reidentificação a partir do snapshot público |
| Chave do TOTP dos operadores | Coluna cifrada sob a KEK | Por reativação | 2º fator comprometido |
| Token do PSP | Variável de ambiente | Sob incidente | Cobranças em nome do operador |
| Credencial da ACT | Variável de ambiente | Sob contrato | Carimbos indevidos |
| JWT signing key | Variável de ambiente | Trimestral | Falsificação de sessão |
| Credencial do storage | Variável de ambiente | Trimestral | Leitura de snapshots (públicos) e comprovantes (cifrados) |

## Regras

1. **Nenhum segredo no repositório.** Varredura no CI.
2. **A KEK nunca entra no banco nem no CI.** É o que torna o crypto-shredding real: quem tem o
   dump não tem como decifrar.
3. Segredos de aplicação em variável de ambiente; **segredos de dados** (salts) em coluna cifrada.
4. Um dump do Postgres sozinho não carrega salt nem KEK.

## Por que os salts não ficam no ambiente

Se `salt_cpf_tenant` estivesse em variável de ambiente, ele estaria no mesmo lugar que o token do
PSP — e um comprometimento do runner entregaria dump **e** salt. Guardá-lo cifrado sob a KEK
significa que o atacante precisa de três coisas (dump, acesso ao gerenciador de chaves e a KEK),
não duas.

## O que fazer se a KEK vazar

Não há shredding retroativo possível: quem copiou o dump antes decifra tudo. O procedimento é:

1. Rotacionar a KEK e re-embrulhar todas as DEKs (não muda os dados cifrados).
2. Notificar a ANPD e os titulares — art. 48 da LGPD.
3. Registrar como incidente com postmortem.

A rotação **não desfaz** o vazamento anterior. Isso está escrito aqui para que ninguém acredite
que rotacionar resolve.
