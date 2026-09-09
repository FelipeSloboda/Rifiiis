---
id: user-stories
etapa: 4
data: 2026-09-08
status: done
fonte: PRD §5
---

# USER STORIES — Dream RI

Formato: *Como \<persona\>, quero \<ação\>, para \<benefício\>.*
Critérios de aceite executáveis vivem em [cenarios/](../cenarios/) — aqui está a intenção.

---

## Operador (P1)

| ID | Story | Req | Épico | Pontos |
|---|---|---|---|---|
| US-001 | Como operador, quero receber acesso provisionado e ativar meu segundo fator, para operar com a conta protegida desde o primeiro dia | R0.5 | E01 | 5 |
| US-002 | Como operador, quero entrar com senha e TOTP, para que senha vazada sozinha não dê acesso ao painel | R0 | E01 | 5 |
| US-003 | Como operador, quero recuperar o acesso com código de uso único, para não ficar travado se perder o celular | R0.5 | E01 | 3 |
| US-004 | Como operador, quero cadastrar minha conta de recebimento, para o dinheiro cair direto comigo | R10 | E02 | 5 |
| US-005 | Como operador, quero que a titularidade da conta seja conferida, para não conseguir cadastrar conta de terceiro por engano | R10 | E02 | 5 |
| US-006 | Como operador, quero cadastrar uma campanha com prêmio, preço e regra, para colocá-la à venda | R1 | E02 | 8 |
| US-007 | Como operador, quero que a publicação seja bloqueada sem autorização válida, para não publicar campanha irregular | R8 | E07 | 5 |
| US-008 | Como operador, quero ver a visão geral da campanha, para saber quanto vendi e quanto falta | R9.1 | E08 | 5 |
| US-009 | Como operador, quero buscar e filtrar pedidos, para achar o de um comprador que me procurou | R9.2 | E08 | 8 |
| US-010 | Como operador, quero ver o estado das apurações e as tentativas, para agir quando travar | R9.3 | E08 | 8 |
| US-011 | Como operador, quero reprocessar a apuração na fonte oficial, para destravar sem abrir chamado | R9.3 | E06 | 5 |
| US-012 | Como operador, quero fazer entrada manual da extração com dupla conferência, para apurar quando as duas fontes caem | R6 | E06 | 8 |
| US-013 | Como operador, quero exportar o relatório de arrecadação, para prestar contas ao órgão | R9.4 | E08 | 5 |
| US-014 | Como operador, quero registrar a entrega do prêmio com comprovante, para fechar a campanha com prova | R8.5 | E06 | 5 |
| US-015 | Como operador, quero ver estornos pendentes e o total devido, para regularizar o saldo e reprocessar | R10 | E02 | 5 |
| US-016 | Como operador, quero retificar uma apuração feita sobre insumo errado, para corrigir sem apagar a original | R6 | E06 | 8 |
| US-017 | Como operador, quero ser alertado quando a autorização estiver perto de vencer, para renovar antes de travar | R8 | E07 | 3 |
| US-018 | Como operador, quero desligar um operador da minha organização, para revogar o acesso dele na hora | R0.5 | E01 | 3 |

## Comprador (P2)

| ID | Story | Req | Épico | Pontos |
|---|---|---|---|---|
| US-020 | Como comprador, quero ver a campanha e o preço sem cadastro, para decidir antes de me comprometer | R1 | E02 | 3 |
| US-021 | Como comprador, quero escolher um pacote de bilhetes, para comprar rápido | R3 | E04 | 3 |
| US-022 | Como comprador, quero me cadastrar com o mínimo de dados, para não abandonar no meio | R7 | E04 | 5 |
| US-023 | Como comprador, quero pagar por Pix copia-e-cola, para concluir sem sair do celular | R3 | E04 | 8 |
| US-024 | Como comprador, quero receber meus números imediatamente após o pagamento, para ter certeza de que a compra valeu | R2, R3 | E04 | 8 |
| US-025 | Como comprador, quero acessar meus números por código enviado ao meu canal, para não criar mais uma senha | R7.5 | E04 | 5 |
| US-026 | Como comprador, quero ver o comprovante com a prova de inclusão, para conferir que meu número está na lista | R5 | E05 | 8 |
| US-027 | Como comprador, quero verificar meu comprovante sem depender do operador, para não precisar confiar nele | R5 | E05 | 8 |
| US-028 | Como comprador, quero ver o resultado e se eu ganhei, para não depender de post em rede social | R6 | E06 | 5 |
| US-029 | Como comprador ganhador, quero confirmar o recebimento do prêmio, para encerrar formalmente | R8.5 | E06 | 3 |
| US-030 | Como comprador, quero entender o que houve quando algo dá errado, para não achar que fui roubado | R9.6 | E10 | 5 |
| US-031 | Como comprador, quero solicitar a exclusão dos meus dados, para exercer meu direito | RNF-07 | E07 | 8 |

## Auditor (P3)

| ID | Story | Req | Épico | Pontos |
|---|---|---|---|---|
| US-040 | Como auditor, quero baixar o snapshot da campanha, para recomputar a raiz por mim mesmo | R4 | E05 | 5 |
| US-041 | Como auditor, quero conferir o carimbo do tempo, para saber que a lista existia antes da extração | R4 | E05 | 5 |
| US-042 | Como auditor, quero recomputar o ganhador a partir da regra e da extração, para validar o resultado | R6 | E06 | 5 |
| US-043 | Como auditor, quero ver a apuração original quando houve retificação, para julgar a correção | R6 | E06 | 3 |

## Sistema / operação

| ID | Story | Req | Épico | Pontos |
|---|---|---|---|---|
| US-050 | Como sistema, quero expirar reservas consultando o PSP antes, para não perder pagamento tardio | R3 | E04 | 5 |
| US-051 | Como sistema, quero congelar a campanha em T-2h, para fechar a lista antes da extração | R4 | E05 | 5 |
| US-052 | Como sistema, quero carimbar a raiz Merkle em ACT credenciada, para dar validade probatória | R4 | E05 | 8 |
| US-053 | Como sistema, quero expurgar IP e user-agent de sessão em D+90, para cumprir a retenção | RNF-10 | E07 | 3 |
| US-054 | Como sistema, quero anonimizar operador desligado após o prazo, para cumprir o art. 16 sem quebrar auditoria | ADR-23 | E07 | 5 |
| US-055 | Como sistema, quero suportar 500 req/s no checkout, para aguentar o pico de fim de campanha | RNF-02 | E10 | 8 |

---

## Totais

| Persona | Stories | Pontos |
|---|---:|---:|
| Operador | 18 | 98 |
| Comprador | 12 | 69 |
| Auditor | 4 | 18 |
| Sistema | 6 | 34 |
| **Total** | **40** | **219** |

> Pontos são referência relativa para sequenciamento, **não** promessa de prazo. O cronograma
> do PRD §10 é por entregável verificável, não por velocity — e é ele que vale.
