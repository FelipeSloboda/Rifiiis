---
id: calculadora-roi
etapa: 13
data: 2026-09-08
status: done
---

# CALCULADORA DE ROI — Dream RI

> **Aviso.** Nenhum valor foi cotado nem medido. Este documento entrega o **modelo** e as variáveis
> — não números. Preencher com dados reais antes de usar comercialmente. Uma calculadora de ROI
> com número inventado é pior que nenhuma.

## Para o operador

### Variáveis de entrada

| Variável | Símbolo | Como obter |
|---|---|---|
| Arrecadação média por campanha | `A` | Histórico do operador |
| Campanhas por ano | `N` | Histórico |
| Custo da plataforma | `C` | Nossa proposta |
| Taxa Pix | `T` | PSP (paga por ele, com ou sem nós) |

### Ganhos difíceis de medir, e por quê

O ROI real está em coisas que o operador não mede hoje:

| Ganho | Por que não é medido | Como estimar |
|---|---|---|
| **Venda não perdida por desconfiança** | Ninguém registra quem desistiu por achar que era golpe | Perguntar: "quanto você acha que perde?" |
| Tempo em atendimento de "meu número apareceu?" | Não cronometrado | Horas/campanha × custo/hora |
| Risco de sanção do órgão | Evento raro, custo alto | Probabilidade × custo da sanção |
| Reputação após acusação | Não quantificável | Qualitativo |

**A honestidade aqui vale mais que a precisão:** apresentar um ROI com números inventados a um
operador que conhece o próprio negócio destrói a credibilidade — que é exatamente o que estamos
vendendo.

### Modelo

```
Custo com a plataforma  = C + (T × A × N)
Custo sem a plataforma  = (T × A × N) + tempo_atendimento + risco_sanção + venda_perdida
```

O termo decisivo é `venda_perdida`, e é o único que o operador consegue estimar melhor que nós.
**A conversa de venda deve começar por ele.**

## Para nós

| Item | Natureza |
|---|---|
| Receita | Licença/mensalidade — **não escala com o tamanho da campanha** (ADR-017) |
| Custo variável principal | **Carimbo por campanha** |
| Custo fixo | VPS, banco, storage, contas de loja |

### A restrição de precificação

O carimbo custa o mesmo numa campanha de 100 e numa de 1 milhão de números. Isso define um
**piso**: o preço precisa cobrir o carimbo mesmo na campanha menor, ou campanhas pequenas dão
prejuízo.

Se esse piso ficar alto demais para o segmento, a saída é agregar carimbos (ver
[ADR-005](../adrs/ADR-005-carimbo-rfc3161.md)) — não abandonar o carimbo.

## O que precisa ser cotado antes de vender

1. ⚠️ Preço unitário do carimbo na ACT
2. ⚠️ Infra mensal
3. ⚠️ Arrecadação e frequência típicas do operador-alvo
