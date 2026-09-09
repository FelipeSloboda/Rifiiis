---
id: vision
etapa: 1
data: 2026-09-08
status: done
fonte: PRD §1-§4
---

# VISION — Dream RI

## O problema, sem eufemismo

Rifa online no Brasil funciona por **confiança cega**. O comprador paga, recebe um número, e no
dia do sorteio vê um print, um vídeo ou um post dizendo quem ganhou. Ele não tem como saber:

- se o número dele estava mesmo na lista quando o sorteio rodou;
- se o ganhador foi escolhido antes de a lista ser fechada;
- se a lista foi editada depois da extração;
- se o prêmio foi entregue.

Nenhuma dessas perguntas tem resposta verificável. O operador honesto **não tem como provar**
que é honesto, e é isso que torna o mercado inteiro suspeito — a fraude é barata e a honestidade
é indistinguível dela.

## A tese

**Trocar confiança por verificação.** O sistema publica um compromisso criptográfico da lista de
números vendidos **antes** de a fonte de aleatoriedade existir, carimbado por autoridade
credenciada (RFC 3161 / ICP-Brasil). A aleatoriedade vem da Loteria Federal — pública, externa,
não manipulável pelo operador nem pela plataforma.

Consequência: qualquer pessoa, sem confiar em nós, consegue verificar que:

1. a lista existia antes da extração (carimbo do tempo);
2. o número dela estava na lista (prova de inclusão Merkle);
3. o ganhador sai da regra publicada aplicada à extração oficial (recomputação).

> Para fraudar seria preciso achar colisão de SHA-256 ou falsificar carimbo de autoridade
> credenciada. Comparado com "confie no print do operador", é uma mudança de categoria.

## O que isso exige que a maioria não faz

| Decisão | Consequência |
|---|---|
| Irreversibilidade por design | Apuração não se edita — corrige-se por retificação pública (ADR-13) |
| Sem custódia | O Pix cai direto na conta do operador; a plataforma nunca segura dinheiro (ADR-17) |
| Prova sobrevive à LGPD | Crypto-shredding: apagar a chave do titular não quebra a cadeia (SPEC §9) |
| Prova de entrega é pública | O que era público (número, data, status) continua; quem ganhou fica ilegível |

## Para quem

| Persona | O que ganha |
|---|---|
| **P1 Operador** | Consegue **provar** honestidade — vira argumento de venda, não custo |
| **P2 Comprador** | Comprovante que ele mesmo verifica, sem pedir licença a ninguém |
| **P3 Auditor / órgão** | Recomputa o resultado com dados públicos, sem acesso ao sistema |

## O que NÃO é

- Não é marketplace de rifas — é a plataforma de **um** operador por vez (multi-tenant é P2).
- Não é carteira digital: não custodia, não faz split, não guarda saldo.
- Não substitui a autorização do órgão regulador — ela é **pré-requisito** para publicar.

## Como saberemos que funcionou

O marco que importa não é técnico: **D+21, apuração ensaiada verificada por um terceiro usando
apenas o verificador público.** Se um estranho não consegue conferir sozinho, a tese não se
sustenta, por mais correto que o código esteja.

Métricas em [product/METRICS.md](METRICS.md).
