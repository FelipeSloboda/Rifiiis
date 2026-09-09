# ADR-025 — Derivado de CPF é Argon2id com salt por escopo

**Status:** aceita · **Data:** 2026-09-08 · **Contexto:** SPEC §9, inventário de PII

> Numeração: registrada primeiro como ADR-22, corrigida para 25 — 22 já era "reconsulta o PSP".

## Contexto

`cpf_indice` é o único campo que **precisa** sobreviver ao crypto-shredding: sem ele não há
limite por CPF (o comprador excluído voltaria a comprar sem teto) nem consulta "meus números".
É, por construção, um pseudônimo — e dado pseudonimizado segue sendo dado pessoal (LGPD art. 12
§2º). A proteção precisa vir da matemática, não do rótulo.

A v1.x usava HMAC-SHA256 com chave global, justificado como "não reversível sem a chave".

## Decisão

**Argon2id** (`m=64MiB, t=3, p=1`), com **salt por tenant** no índice e **salt por campanha** no
leaf do snapshot. Ambos os salts em coluna cifrada sob a KEK externa, nunca em variável de
ambiente.

## Por quê a justificativa anterior não se sustentava

| Premissa da v1.x | O que é de fato |
|---|---|
| "10¹¹ CPFs possíveis" | ~10⁹ — os dois dígitos verificadores são determinísticos |
| "não reversível sem a chave" | Correto e irrelevante: quem obtém o dump obtém a chave, ambos no mesmo ambiente |
| "HMAC basta" | HMAC-SHA256 é projetado para ser **rápido**; 10⁹ candidatos numa GPU são minutos |
| Chave **global** | Um comprometimento expõe todos os tenants, e nenhum shredding individual reduz o dano |

## Consequências

- ~50ms por derivação, no checkout e na consulta — ambos já com rate limit, nenhum em caminho
  quente de alocação.
- A construção do snapshot (1M de folhas) exige **pool de workers** na fase 2. Não dimensionado
  ainda — [G-13](../requirements/GAP_ANALYSIS.md).
- Salts nunca compartilhados: reusar permitiria cruzar o snapshot público com a base e
  reidentificar compradores por interseção. Há cenário no CI que falha se alguém unificar.

## O que isto **não** resolve

Contra alvo específico — "o CPF 123… está nesta base?" — nenhuma derivação protege: uma
verificação custa 50ms. A defesa é contra recuperação **em massa**, que é o cenário de vazamento
real. Confirmação pontual de um CPF já conhecido continua possível, e é risco aceito.
