---
id: waves
etapa: 10
data: 2026-09-08
status: done
---

# WAVES — bandas topológicas · Dream RI

Ondas derivadas do DAG de dependências. Tudo dentro de uma onda pode correr em paralelo; a onda
seguinte só começa quando a anterior fecha.

## Onda 0 — Destravar terceiros (começa em D0, fora da engenharia)

| Item | Dono | Prazo | Bloqueia |
|---|---|---|---|
| Aprovar conta PicPay | Operador | D+7 | E04 |
| Contratar ACT | Operador/Eng | D+7 | E05 — **e a tese** |
| Abrir contas Apple/Google | Eng | D+7 | E09 |
| Criar repositório de código | Eng | D+1 | E01 |
| Criar board Jira `DRI` | Eng | D+1 | toda a esteira |
| **Nomear a fonte secundária da Federal** | Eng | D+10 | E06 (G-15) |

> Esta onda **não tem código** e é a que mais atrasa projetos. Começar em D+5 é o erro clássico:
> os três primeiros itens são espera por terceiro, e a espera não comprime.

## Onda 1 — Fundação

| Épico | Paralelizável com |
|---|---|
| E01 Fundação e acesso | E02 (partes) |

## Onda 2 — Campanha e estoque

| Épico | Depende de |
|---|---|
| E02 Campanha e conta | E01 |
| E03 Estoque e alocação | E01 |

E02 e E03 correm em paralelo — tocam agregados diferentes.

## Onda 3 — Venda

| Épico | Depende de |
|---|---|
| E04 Checkout Pix | E02, E03, **conta PicPay** |

## Onda 4 — Prova

| Épico | Depende de |
|---|---|
| E05 Commitment e verificador | E04, **ACT** |

## Onda 5 — Resultado e operação

| Épico | Depende de | Paralelizável |
|---|---|---|
| E06 Apuração e entrega | E05 | com E07, E08 |
| E07 Compliance e LGPD | E02 | com E06, E08 |
| E08 Painel e relatórios | E02, E04, E06 | com E07 |

Maior janela de paralelismo do projeto — três frentes independentes na semana 4.

## Onda 6 — Superfície

| Épico | Depende de |
|---|---|
| E09 App, build e submissão | E04 |

E09 poderia começar antes (depende só de E04), e **deveria**: a fila da loja é serial e não
espera o resto ficar pronto. Antecipar a submissão é a otimização de cronograma mais barata
disponível.

## Onda 7 — Fechamento

| Épico | Depende de |
|---|---|
| E10 Exceções, carga, hardening, go-live | E06, E08, E09 |

---

## Caminho crítico

```
Onda 0 (ACT) → E01 → E03 → E04 → E05 → E06 → E10
```

**A ACT está no caminho crítico e é a única sem plano B.** Um atraso na contratação empurra E05,
que empurra E06 e E10 — o go-live inteiro. É o item de maior alavancagem do cronograma, e não
depende de engenharia nenhuma.

## Onde o paralelismo ajuda de verdade

| Oportunidade | Ganho |
|---|---|
| E09 antecipado logo após E04 | Tira a fila da loja do caminho crítico |
| E07 em paralelo com E06 | Compliance não depende de apuração |
| Onda 0 iniciada em D0 | Evita o atraso mais provável do projeto |
