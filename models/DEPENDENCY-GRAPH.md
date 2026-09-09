---
id: dependency-graph
etapa: 10
data: 2026-09-08
status: done
---

# GRAFO DE DEPENDÊNCIAS — Dream RI

```mermaid
graph TD
    T0["Onda 0<br/>PicPay · ACT · lojas · repo · board"]:::ext

    E01["E01 Fundação<br/>e acesso"]
    E02["E02 Campanha<br/>e conta"]
    E03["E03 Estoque<br/>e alocação"]
    E04["E04 Checkout<br/>Pix"]
    E05["E05 Commitment<br/>e verificador"]
    E06["E06 Apuração<br/>e entrega"]
    E07["E07 Compliance<br/>e LGPD"]
    E08["E08 Painel<br/>e relatórios"]
    E09["E09 App e<br/>submissão"]
    E10["E10 Exceções<br/>carga · go-live"]

    T0 --> E01
    E01 --> E02
    E01 --> E03
    E02 --> E04
    E03 --> E04
    E02 --> E07
    E04 --> E05
    E04 --> E09
    E05 --> E06
    E06 --> E08
    E04 --> E08
    E06 --> E10
    E07 --> E10
    E08 --> E10
    E09 --> E10

    T0 -.->|PicPay| E04
    T0 -.->|ACT| E05
    T0 -.->|lojas| E09

    classDef ext fill:#fde,stroke:#c39
```

## Caminho crítico

```
Onda 0 → E01 → E03 → E04 → E05 → E06 → E10
```

Sete nós. Qualquer atraso neles empurra o go-live dia a dia.

## Análise de folga

| Épico | No caminho crítico? | Folga |
|---|:-:|---|
| E01 | ✅ | 0 |
| E02 | ❌ | Pode atrasar até E04 precisar |
| E03 | ✅ | 0 |
| E04 | ✅ | 0 |
| E05 | ✅ | 0 |
| E06 | ✅ | 0 |
| E07 | ❌ | Toda a semana 4 |
| E08 | ❌ | Até E10 |
| E09 | ❌ | **Mas a fila da loja é serial** — folga aparente, risco real |
| E10 | ✅ | Absorve a semana 6 |

## As três dependências externas, e o que fazer com cada uma

| Dependência | Bloqueia | Plano B | Ação |
|---|---|---|---|
| **ACT** | E05 → tudo depois | **Nenhum** | Iniciar em D0. É o item de maior alavancagem do projeto |
| **PicPay** | E04 → tudo depois | Nenhum no MVP (ADR-021) | Iniciar em D0 |
| **Lojas** | E09 | Web paritária (RNF-16) | Antecipar E09 logo após E04 |

> **E09 tem folga no grafo e não tem folga na realidade.** A fila de revisão da loja é serial,
> externa e imprevisível. Tratar E09 como "pode esperar" porque o grafo permite é o erro que a
> semana 6 acabaria pagando.

## O nó que não aparece no grafo

**G-15 — a fonte secundária da Federal não tem nome.** Ela é pré-requisito de E06, mas como não
existe ainda, não há nó para desenhar. É a dependência mais fácil de esquecer justamente porque
não está no diagrama.
