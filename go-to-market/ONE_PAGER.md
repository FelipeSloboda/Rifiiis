---
id: one-pager
etapa: 13
data: 2026-09-08
status: done
---

# Dream RI — one pager

## O problema

Rifa online funciona por confiança cega. O comprador paga, recebe um número e no dia do sorteio vê
um print. Ele não tem como saber se o número dele estava na lista quando o sorteio rodou, se a
lista foi editada depois, ou se o prêmio saiu.

**O operador honesto não tem como provar que é honesto** — e é isso que torna o mercado inteiro
suspeito.

## A solução

O sistema publica um compromisso criptográfico da lista de vendidos **antes** de a fonte de
aleatoriedade existir, carimbado por autoridade credenciada ICP-Brasil. A aleatoriedade vem da
Loteria Federal — pública, externa, fora do alcance do operador e nosso.

Qualquer pessoa, sem confiar em ninguém, verifica que:

1. a lista existia antes da extração (carimbo do tempo);
2. o número dela estava na lista (prova de inclusão Merkle);
3. o ganhador sai da regra publicada aplicada à extração oficial.

## Por que é difícil de copiar

Para fraudar seria preciso achar colisão de SHA-256 ou falsificar carimbo de autoridade
credenciada. Comparado com "confie no print do operador", é mudança de categoria — não de grau.

E o histórico é antifrágil: quanto mais campanhas verificadas acumulam, mais forte fica. Um
concorrente copia a tela; não copia carimbo já emitido.

## Para quem

| Quem | O que ganha |
|---|---|
| **Operador** | Prova de honestidade vira argumento de venda, não custo |
| **Comprador** | Comprovante que ele mesmo confere |
| **Órgão / auditor** | Recomputa o resultado com dados públicos |

## O que não fazemos, deliberadamente

- **Não custodiamos dinheiro.** O Pix cai direto na conta do operador.
- **Não sorteamos.** Aplicamos regra pública a uma extração oficial.
- **Não editamos apuração.** Erro se corrige por retificação pública, com a original preservada.

Cada uma dessas ausências é uma decisão registrada, não uma limitação.

## Estado

MVP em planejamento. Seis semanas até a primeira campanha real, com marco de verificação
independente em D+21.

## A frase

**O único sorteio que o comprador confere sozinho.**
