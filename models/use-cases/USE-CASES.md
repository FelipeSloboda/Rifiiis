---
id: use-cases
etapa: 6
data: 2026-09-08
status: done
---

# CASOS DE USO — Dream RI

## Ator: Operador

| UC | Caso de uso | Pré-condição | Pós-condição | Requisito |
|---|---|---|---|---|
| UC-01 | Ativar segundo fator | Conta provisionada | TOTP ativo + códigos emitidos | R0.5 |
| UC-02 | Autenticar | TOTP ativo | Sessão com `segundo_fator_em` | R0 |
| UC-03 | Cadastrar conta de recebimento | Sessão autorizada | Conta pendente de verificação | R10 |
| UC-04 | Criar campanha | Sessão autorizada | Campanha em `RASCUNHO` | R1 |
| UC-05 | Publicar campanha | Conta verificada + autorização + regulamento | `PUBLICADA` + estoque enfileirado | R1, R8, R10 |
| UC-06 | Acompanhar vendas | Campanha publicada | — | R9.1 |
| UC-07 | Localizar pedido | — | — | R9.2 |
| UC-08 | Reprocessar apuração | Apuração bloqueada | Nova tentativa registrada | R9.3 |
| UC-09 | Informar extração manualmente | Apuração bloqueada | Aguarda 2º responsável | R6 |
| UC-10 | Confirmar entrada de outro responsável | Entrada submetida por **outra** pessoa | Apuração concluída | R6 |
| UC-11 | Retificar apuração | Resultado publicado + causa fechada + 2ª autorização | Retificada; original preservada | R6 |
| UC-12 | Registrar entrega | Apuração concluída | Aguarda confirmação do ganhador | R8.5 |
| UC-13 | Reprocessar estorno | Estorno pendente + saldo | Estorno concluído | R10 |
| UC-14 | Exportar relatório | — | Arquivo gerado | R9.4 |
| UC-15 | Desligar operador | Sessão autorizada | Acesso revogado; FKs íntegras | R0.5 |

## Ator: Comprador

| UC | Caso de uso | Pré-condição | Pós-condição | Requisito |
|---|---|---|---|---|
| UC-20 | Ver campanha | Campanha publicada | — | R1 |
| UC-21 | Cadastrar-se | Aceite 18+ e do regulamento | Comprador com PII cifrada | R7 |
| UC-22 | Comprar | Campanha publicada + dentro do limite | Pedido + números reservados + Pix | R3, R2 |
| UC-23 | Pagar | Pedido criado | Números atribuídos | R3 |
| UC-24 | Acessar meus números | CPF cadastrado | Sessão de 30 dias | R7.5 |
| UC-25 | Verificar comprovante | Commitment publicado | Inclusão confirmada | R5 |
| UC-26 | Confirmar recebimento | Ser o ganhador + entrega registrada | Campanha encerrada | R8.5 |
| UC-27 | Solicitar exclusão de dados | Ser titular | PII ilegível; prova preservada | RNF-07 |

> **UC-27 não tem interface definida** — G-06. O mecanismo existe; a porta de entrada, não.

## Ator: Auditor

| UC | Caso de uso | Pré-condição | Requisito |
|---|---|---|---|
| UC-30 | Baixar snapshot | Commitment publicado | R4 |
| UC-31 | Recomputar a raiz | Snapshot baixado | R4 |
| UC-32 | Validar o carimbo | Token publicado | R4 |
| UC-33 | Recomputar o ganhador | Snapshot + regra + extração oficial | R6 |

**Nenhum destes exige autenticação ou contato conosco.** É o critério de aceite da persona P3 —
se algum exigisse, deixaria de ser verificação independente.

## Ator: Sistema

| UC | Caso de uso | Gatilho | Requisito |
|---|---|---|---|
| UC-40 | Gerar estoque | Campanha publicada | R2 |
| UC-41 | Expirar reservas | A cada 30s, **após consultar o PSP** | R3 |
| UC-42 | Congelar campanha | T-2h da extração | R4 |
| UC-43 | Gerar snapshot e carimbar | Pós-congelamento | R4 |
| UC-44 | Apurar | Dia da extração | R6 |
| UC-45 | Expurgar sessões | Diário, D+90 | RNF-10 |
| UC-46 | Anonimizar operadores | Diário, após o prazo | ADR-026 |
