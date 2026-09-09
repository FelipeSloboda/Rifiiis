---
id: pages
etapa: 5
data: 2026-09-08
status: done
fonte: prototipacao/hi-fi/ (18 telas) + PRD §6.1
---

# PAGES — inventário de telas · Dream RI

Toda tela tem requisito. Todo requisito P0 com interface tem tela. Divergência aqui é defeito de
planejamento, não detalhe de design — a regra é do [PRD §6.1](../PRD-plataforma-rifa-mvp.md).

Legenda de superfície: **📱** app Expo · **🌐** web · **🔓** público (sem login)

---

## Público — comprador e auditor

| # | Tela | Req | Superfície | Estados | Cenário |
|---|---|---|---|---|---|
| 01 | `01-campanha` | R1, R8, R12 | 📱🌐🔓 | à venda · congelada · esgotada · encerrada | `R01-campanha` |
| 02 | `02-checkout-pix` | R3 | 📱🌐 | gerando · aguardando · pago · expirado | `R03-checkout-pix` |
| 02a | `02a-cadastro` | R7 | 📱🌐 | vazio · validando · erro · aceite 18+ | `R07-cadastro-comprador` |
| 03 | `03-meus-numeros` | R5, R7.5 | 📱🌐 | lista · comprovante com prova · vazio | `R07.5-painel-comprador` |
| 03a | `03a-acesso-comprador` | R7.5 | 📱🌐🔓 | pedir código · aguardando · expirado | `R07.5-painel-comprador` |
| 04 | `04-apuracao` | R4, R6, R8.5 | 📱🌐🔓 | aguardando · commitment publicado · apurada · entregue | `R04-commitment`, `R06-apuracao` |
| 05 | `05-verificador` | R5 | 🌐🔓 | entrada · válido · inválido | `R05-comprovante` |
| 08 | `08-home-app` | — | 📱 | campanhas ativas · vazio | — |
| 11 | `11-estados-excecao` | R9.6 | 📱🌐🔓 | 6 cenários de exceção | `R09.6-estados-excecao` |

## Administrativo — operador (2FA obrigatório)

| # | Tela | Req | Superfície | Estados | Cenário |
|---|---|---|---|---|---|
| 00 | `00-login` | R0 | 🌐 | senha · desafio 2FA · bloqueado | `R00-acesso-operador` |
| 00a | `00a-provisionamento` | R0.5 | 🌐 | 1º acesso · ativar TOTP · códigos · concluído | `R00.5-provisionamento` |
| 01a | `01a-campanha-admin` | R1, R8 | 🌐 | rascunho · portão de publicação · gerando · publicada | `R01-campanha` |
| 06 | `06-painel-operador` | R9.1 | 🌐 | com dados · vazio | `R09.1-visao-geral` |
| 07 | `07-apuracoes-admin` | R9.3 | 🌐 | lista · bloqueada · manual aguardando 2º responsável | `R09.3-apuracoes-admin` |
| 08 | `08-pedidos-admin` | R9.2 | 🌐 | lista · busca · filtro · detalhe | `R09.2-pedidos-admin` |
| 09 | `09-relatorios` | R9.4 | 🌐 | com dados · período vazio | `R09.4-relatorios` |
| 10 | `10-conta-recebimento` | R10 | 🌐 | sem conta · verificando · verificada · estornos pendentes | `R10-conta-recebimento` |

## Auxiliares

| # | Arquivo | Papel |
|---|---|---|
| — | `index.html` | Índice navegável do protótipo |
| — | `_tokens.css` | Tokens de design — fonte única de cor, espaçamento e tipografia |
| — | `_logo-preview.html` | Estudo de marca |

---

## Lacunas de tela (do [GAP_ANALYSIS](../requirements/GAP_ANALYSIS.md))

| Lacuna | Requisito órfão | Severidade |
|---|---|---|
| Não há tela para o titular **pedir** exclusão de dados | US-031 / RNF-07 | Média — o mecanismo existe, a porta de entrada não |
| Não há tela de desativação de operador | US-018 / R0.5 | Média — a rota existe na SPEC §8 |
| Navegação mostra "Configurações" sem requisito | — | Média — remover |

## Regras de tela deste produto

1. **O verde é reservado.** `--verify` só aparece onde algo foi criptograficamente provado.
   Verde decorativo destrói o significado do selo — é a regra mais forte do
   [DESIGN.md](../prototipacao/DESIGN.md).
2. **Estado de exceção é tela, não toast.** Um comprador que não entende o que houve conclui que
   foi roubado. Por isso R9.6 tem tela própria com 6 cenários.
3. **Nenhuma tela pública exige login.** O verificador (05) e a apuração (04) precisam funcionar
   para quem não confia em nós — exigir cadastro anularia a persona P3.
4. **Mobile-first sem exceção.** O tráfego chega de link de WhatsApp e Instagram.
5. **CPF mascarado por padrão** nas telas administrativas; revelação é ação explícita.
