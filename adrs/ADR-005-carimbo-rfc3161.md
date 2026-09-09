# ADR-005 — Carimbo do tempo RFC 3161 com autoridade ICP-Brasil

**Status:** aceita · **Contexto:** SPEC §6 fase 4

## Decisão

A raiz Merkle é enviada a uma Autoridade de Carimbo do Tempo credenciada ICP-Brasil, conforme
RFC 3161. O token é armazenado e publicado com a raiz.

## Alternativa recusada

**Ancoragem em blockchain** (OpenTimestamps, Bitcoin, Ethereum).

## Por quê

Sob a **MP 2.200-2/2001**, o carimbo de autoridade credenciada tem validade probatória no Brasil.
Isso é decisivo porque o interlocutor deste produto é **o fiscal do órgão autorizador e o juiz
brasileiro** — não a comunidade cripto.

Uma âncora em blockchain é tecnicamente elegante e provavelmente mais barata, mas exigiria
explicar a um auditor por que uma transação numa rede pública prova anterioridade. O carimbo
ICP-Brasil já tem esse caminho pavimentado em lei.

> Escolhemos o mecanismo que o **destinatário da prova** reconhece, não o que a engenharia acha
> mais bonito. É o mesmo critério que recusou a estética de cassino no design.

## Consequências

| Consequência | Natureza |
|---|---|
| Dependência de fornecedor pago, por campanha | Custo operacional em [COST_MODEL](../infra/COST_MODEL.md) |
| **Sem plano B** se a ACT estiver indisponível | O gap mais caro do projeto — [G-09](../requirements/GAP_ANALYSIS.md) |
| Contratar a ACT é marco duro D+7 | RSK-05, RSK-11 |
| Falha ao carimbar bloqueia o avanço e alerta como crítico | BR-091 |

## O que reabriria a discussão

Se o custo por carimbo inviabilizar campanhas pequenas, a alternativa não é blockchain — é
**agregar**: um carimbo cobrindo a raiz de várias campanhas. Isso preserva a validade legal e
dilui o custo, ao preço de acoplar o cronograma de campanhas distintas.
