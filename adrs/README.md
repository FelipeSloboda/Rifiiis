# ADRs — Dream RI

As 26 decisões estão **resumidas** na [SPEC §12](../SPEC-TECNICA-plataforma-rifa-mvp.md), que é a
fonte. Esta pasta traz o formato longo apenas das decisões cujo *raciocínio* precisa sobreviver —
aquelas em que alguém, daqui a seis meses, vai perguntar "por que não fizeram o óbvio?".

| ADR | Decisão | Formato longo |
|---|---|:-:|
| 01 | Monolito modular | — |
| 02 | Números pré-embaralhados em tabela | — |
| 03 | `FOR UPDATE SKIP LOCKED` | [✅](ADR-003-skip-locked.md) |
| 04 | Merkle RFC 6962 | [✅](ADR-004-merkle-rfc6962.md) |
| 05 | Carimbo RFC 3161 (ICP-Brasil) | [✅](ADR-005-carimbo-rfc3161.md) |
| 06 | Outbox transacional | — |
| 07 | Pix exclusivo | — |
| 08 | `tenant_id` desde o dia 1 | — |
| 09 | Enquadramento como dado | — |
| 10 | Campanha encerra na entrega | [✅](ADR-010-encerra-na-entrega.md) |
| 11 | Teto de 1M com `CHECK` como fonte única | — |
| 12 | Cripto não é aceita contra teste da mesma sessão de IA | [✅](ADR-012-verificacao-independente-ia.md) |
| 13 | Retificação pública, nunca edição | [✅](ADR-013-retificacao-publica.md) |
| 14 | `fillfactor` antes de particionar | — |
| 15 | Sessão só autoriza após 2º fator | — |
| 16 | Entrada manual exige dois responsáveis | — |
| 17 | Sem custódia | [✅](ADR-017-sem-custodia.md) |
| 18 | `ESTORNO_PENDENTE` de primeira classe | — |
| 19 | Comprador entra por código de uso único | — |
| 20 | App Expo como superfície primária | — |
| 21 | PicPay como PSP único | — |
| 22 | Confirmação reconsulta o PSP | [✅](ADR-022-reconsulta-psp.md) |
| 23 | Node 24 LTS + TS 5.9 | — |
| 24 | SQL parametrizado, sem ORM | — |
| 25 | Derivado de CPF em Argon2id | [✅](ADR-025-argon2id-cpf.md) |
| 26 | Operador se anonimiza, não se apaga | [✅](ADR-026-operador-anonimiza.md) |

> **Nota de numeração.** ADR-25 e ADR-26 foram registradas em 2026-09-08 e receberam esses
> números após uma colisão: na primeira escrita saíram como 22 e 23, que já estavam ocupados por
> "reconsulta o PSP" e "Node 24". Corrigido na mesma data.
