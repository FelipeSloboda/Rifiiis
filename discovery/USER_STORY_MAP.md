---
id: user-story-map
etapa: 2
data: 2026-09-08
status: done
---

# USER STORY MAP — Dream RI

Colunas = passos da jornada (backbone). Linhas = fatias de release.

---

## Backbone — Operador

```
Provisionar → Configurar     → Publicar    → Acompanhar  → Congelar  → Apurar      → Entregar
   conta        campanha        campanha      vendas        campanha    resultado     prêmio
```

| Fatia | Provisionar | Configurar | Publicar | Acompanhar | Congelar | Apurar | Entregar |
|---|---|---|---|---|---|---|---|
| **MVP (E01–E08)** | 1º acesso + TOTP | dados, prêmio, regra, autorização | guarda de compliance + conta | visão geral, pedidos | automático T-2h | automática + tentativas | registrar + comprovante |
| **v1.1** | recuperação por códigos | duplicar campanha | agendar publicação | notificação WhatsApp (R11) | — | — | lembrete ao ganhador |
| **v2** | multi-operador (R16) | template de campanha | — | BI | — | — | — |

---

## Backbone — Comprador

```
Descobrir → Escolher    → Cadastrar → Pagar     → Receber   → Acompanhar → Verificar → Conferir
 campanha    quantidade                 Pix       números      pedido       comprovante  resultado
```

| Fatia | Descobrir | Escolher | Cadastrar | Pagar | Receber | Acompanhar | Verificar | Conferir |
|---|---|---|---|---|---|---|---|---|
| **MVP** | página pública + app | pacotes | CPF, nome, contato | Pix copia-e-cola | números na hora | "meus números" por código | prova Merkle | resultado público |
| **v1.1** | contador de urgência (R12) | — | — | lembrete de Pix (R13) | WhatsApp (R11) | — | — | — |
| **v2** | — | — | login social | cartão (R17) | — | — | API pública (R19) | — |

---

## Backbone — Auditor

```
Achar a campanha → Baixar snapshot → Conferir carimbo → Recomputar raiz → Aplicar regra → Comparar
```

Tudo no MVP, tudo público, **nenhum passo exige contato conosco** — é o critério de aceite da
persona P3.

---

## O corte do MVP, e a razão de cada exclusão

| Fora do MVP | Por quê |
|---|---|
| Notificação WhatsApp (R11) | Depende de provedor externo; o número aparece na tela na hora, então a notificação é conveniência |
| Contador de urgência (R12) | Puro marketing; não sustenta a tese |
| Recuperação de carrinho (R13) | Otimização de conversão sem baseline — não há dado para calibrar ainda |
| PDF do órgão (R14) | Formato varia por órgão; exportação genérica cobre a obrigação |
| Multi-tenant self-service (R16) | `tenant_id` existe desde o dia 1, mas onboarding e billing são produto inteiro |

## A linha que não se corta

Do PRD §10: **R0, R10, R2, R4, R6, R8, R8.5, R9.3, R9.6.** Retirar qualquer um destes não encolhe
o MVP — muda o produto para outro que não é este. R2/R4/R6 são a tese; R8/R8.5 são a licença
para operar; R0/R10 são a operação; R9.3/R9.6 são o que salva o operador quando algo trava.
