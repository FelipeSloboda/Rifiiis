---
id: mvp-scope
etapa: 4
data: 2026-09-08
status: done
---

# MVP SCOPE — Dream RI

## A pergunta que define o corte

*Qual é a menor coisa que prova que um sorteio pode ser verificado por quem não confia em ninguém?*

Resposta: **uma campanha real, vendida, congelada, carimbada, apurada pela Federal e conferida
por um terceiro que só teve acesso ao que é público.** Tudo que não serve a essa frase é candidato
a corte.

## Dentro

| Bloco | Requisitos | Justificativa |
|---|---|---|
| Operação mínima | R0, R0.5, R10 | Sem acesso e sem conta não há campanha |
| Campanha | R1, R8 | Publicável e legal |
| Venda | R2, R3, R7, R7.5 | O caminho do dinheiro e do número |
| **Prova** | R4, R5 | A tese |
| **Apuração** | R6, R8.5 | O que a prova protege |
| Operação diária | R9.1..R9.6 | Sem painel o operador não opera |
| Superfícies | app + web mobile-first | Web é o caminho garantido (RNF-16) |

## Fora, e por quê

| Fora | Razão |
|---|---|
| Notificação WhatsApp (R11) | O número aparece na tela na hora |
| Contador de urgência (R12) | Marketing; não sustenta a tese |
| Recuperação de carrinho (R13) | Sem baseline para calibrar |
| PDF do órgão (R14) | Formato varia; exportação genérica cobre |
| Todo o P2 (R15..R20) | Arquitetado para, não construído |
| Multi-campanha simultânea | Suportado tecnicamente, não é objetivo do MVP |

## O teste do MVP

Não é "todos os requisitos entregues". É o **marco D+21**: apuração ensaiada com dados sintéticos
e verificada por terceiro usando apenas o verificador público. Se isso passa, o MVP existe mesmo
que R9.4 esteja pela metade. Se falha, nenhum outro requisito compensa.

## O que assumimos e pode estar errado

| Suposição | Se errada |
|---|---|
| Uma campanha real basta para provar o produto | Precisaremos de 3–5 para ter caso comercial |
| O operador vende a prova ao comprador | RSK-01 se materializa; o valor fica só no lado dele |
| 6 semanas com folga é suficiente | A folga da semana 6 já tem dois donos prováveis (loja e imprevisto) |
