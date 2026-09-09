---
id: market
etapa: 3
data: 2026-09-08
status: done
---

# MARKET — Dream RI

> **Aviso de honestidade.** Este documento não tem pesquisa primária. Nenhum número de mercado
> aqui foi medido — são observações qualitativas do comportamento público do setor. Onde não há
> dado, está escrito que não há. Um MARKET.md com número inventado é pior que um vazio.

---

## O mercado, como ele opera hoje

Rifa online no Brasil é majoritariamente informal e roda sobre três substratos:

| Substrato | Como funciona | Verificabilidade |
|---|---|---|
| WhatsApp + planilha | Operador anota, cobra por Pix, posta o resultado | Nenhuma |
| Plataformas de rifa | Site que gera números e sorteia internamente | Nenhuma — o sorteio é do próprio site |
| Vinculado à Loteria Federal | Usa a extração como fonte, mas sem commitment | Parcial — a lista pode mudar depois |

O terceiro é o mais próximo do nosso, e é exatamente onde está a brecha: **usar a Federal não
prova nada se a lista de participantes puder ser editada depois da extração.**

---

## Onde nos posicionamos

| Eixo | Concorrente típico | Dream RI |
|---|---|---|
| Fonte de aleatoriedade | Interna ou Federal | Federal, sempre |
| Lista de participantes | Editável, privada | Congelada e carimbada antes |
| Prova ao comprador | Print/live | Prova de inclusão Merkle |
| Verificação por terceiro | Impossível | Sem contato conosco |
| Custódia do dinheiro | Frequentemente sim | **Nunca** (ADR-17) |
| Compliance | Variável | Bloqueio na publicação |

**A frase de posicionamento:** *o único em que o comprador confere sozinho.*

---

## Por que a não-custódia é posição de mercado, não só arquitetura

Custodiar dinheiro de terceiro em sorteio aproxima a bit4devs do risco regulatório do operador,
exige licença e controles fora do prazo do MVP. A decisão (ADR-17) tem efeito comercial duplo:

1. **Reduz o custo de venda** — o operador não precisa confiar seu faturamento a nós.
2. **Limita o modelo de receita** — sem custódia, não há percentual sobre arrecadação. A receita
   é licença/mensalidade. Ver Q5 do PRD, que recusa o percentual conscientemente.

---

## Segmento inicial

**Operador que já foi acusado publicamente de fraude.** É quem tem dor aguda e para quem a prova
vale preço. Segmento pequeno — e é vantagem: o produto precisa de **uma** campanha real bem
verificada para ter caso de uso demonstrável.

## O que precisaria ser pesquisado antes de escalar

| Pergunta | Por que importa | Como responder |
|---|---|---|
| Quantos operadores autorizados existem por UF? | Dimensiona o TAM real | Consulta aos órgãos autorizadores |
| Qual o ticket médio de uma campanha? | Define licença vs. mensalidade | Entrevista com 5 operadores |
| O comprador percebe a diferença? | Valida RSK-01 | Teste A/B na 1ª campanha |
| Órgãos aceitariam a prova como prestação de contas? | Abriria canal institucional | Conversa com um órgão |

Nenhuma dessas está respondida. Antes da segunda campanha, a terceira é a que mais muda o produto.
