---
id: roadmap
etapa: 10
data: 2026-09-08
status: done
fonte: PRD §10, SPEC §13
---

# ROADMAP — Dream RI

## 6 semanas, por entregável verificável

| Semana | Entregável **verificável** | Épicos |
|:-:|---|---|
| **1** | Domínio testado; acesso do operador; conta de recebimento; campanha publicável; 1M de números gerados. **E, fora da engenharia: PicPay aprovado, ACT contratada, contas de loja abertas** | E01, E02, E03 |
| **2** | Cadastrar → comprar → Pix → números atribuídos, fim a fim em homologação **pelo app** | E03, E04 |
| **3** | Congelamento, commitment carimbado, comprovante com prova, verificador público | E05 |
| **4** | Apuração automática, entrega, compliance, painel completo, relatórios | E06, E07, E08 |
| **5** | App fechado: deep link, E2E Maestro, build EAS, **submissão às duas lojas**; web paritária | E09 |
| **6** | Estados de exceção, carga, hardening, deploy, **campanha real no ar** — e a folga | E10 |

## Marcos duros

| Marco | O quê | Se falhar |
|---|---|---|
| **D+7** | PicPay aprovado **e** ACT contratada **e** contas de loja ativas | **O cronograma para e é renegociado.** Todos são espera por terceiro — IA não encurta |
| **D+21** | Apuração ensaiada com dados sintéticos, **verificada por terceiro usando só o verificador público** | A tese não está provada |
| **D+28** | Apuração e compliance fechados | — |
| **D+35** | Feature freeze **e** app submetido | Nada novo entra depois |
| **D+42** | Campanha real publicada | — |

> **D+42 não espera aprovação de loja.** A compra pela web é o caminho garantido (RNF-16).

## A semana 6 não é gordura

Um cronograma com zero buffer não é agressivo — é um cronograma que já falhou e ainda não sabe.
A folga tem **dois donos prováveis**: um ciclo de resposta a rejeição de loja, e o imprevisto
ordinário.

## Ordem de corte, se atrasar

1. P1 inteiro (R11..R14)
2. **App adiado para v1.1**, mantendo a web mobile-first ← *maior alívio, menor dano*
3. R9.4 além da exportação básica
4. R9.2 reduzido a listagem sem busca por CPF
5. E-mail em vez de WhatsApp
6. Confirmação de entrega vira registro só do operador

**Nunca cortar:** R0, R10, R2, R4, R6, R8, R8.5, R9.3, R9.6.

## Pós-MVP

| Versão | Conteúdo | Gatilho |
|---|---|---|
| **v1.1** | App (se cortado), R11 WhatsApp, R12 contador | Após a 1ª campanha |
| **v1.2** | R13 recuperação de carrinho, R14 PDF do órgão | Dado de conversão real |
| **v2** | R16 multi-tenant, R15 premiados instantâneos | Segundo operador contratado |

> **O gatilho da v2 é comercial, não técnico.** `tenant_id` já existe desde o dia 1 (ADR-008);
> o que falta é onboarding e billing, e isso só se justifica com demanda real.
