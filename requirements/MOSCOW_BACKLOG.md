---
id: moscow-backlog
etapa: 4
data: 2026-09-08
status: done
---

# MOSCOW — Dream RI

## Must have — sem isso não sobe

| Req | Por quê é Must |
|---|---|
| R0, R0.5 | Sem acesso não há operação |
| R1 | Sem campanha não há produto |
| R2 | Colisão de número destrói a credibilidade |
| R3, R7 | Sem compra não há receita |
| R4 | **É a tese.** Sem commitment, é rifa comum |
| R5 | A prova que o comprador usa |
| R6 | Sem apuração não há sorteio |
| R7.5 | O comprador precisa achar os números dele |
| R8 | Licença para operar |
| R8.5 | Fecha o loop — prova que o prêmio saiu |
| R9.1..R9.4 | Operação diária |
| R9.6 | Estado de exceção invisível = comprador achando que foi roubado |
| R10 | Define para onde o dinheiro vai |

**Os nove que nunca se cortam** (PRD §10): R0, R10, R2, R4, R6, R8, R8.5, R9.3, R9.6.

## Should have — entra se sobrar semana

| Req | Valor | Custo de adiar |
|---|---|---|
| R11 · WhatsApp | Alto na percepção | Baixo — o número já aparece na tela |
| R12 · contador de urgência | Conversão | Nenhum estrutural |
| R13 · recuperação de carrinho | Conversão | Nenhum |
| R14 · PDF do órgão | Comodidade na prestação de contas | Exportação genérica cobre |

## Could have — não planejado, aceito se surgir grátis

- Duplicar campanha a partir de outra
- Tema claro/escuro no painel (o protótipo já tem tokens)
- Exportar snapshot direto da tela pública

## Won't have (nesta versão) — e a razão

| Item | Por que não agora |
|---|---|
| R15 · premiados instantâneos | Exige segundo commitment; a arquitetura aceita, o prazo não |
| R16 · multi-tenant self-service | Onboarding + billing é produto inteiro |
| R17 · cartão de crédito | Chargeback num sorteio é problema jurídico, não técnico |
| R18 · afiliados com split | Split reabre a discussão de custódia (ADR-17) |
| R19 · API pública de verificação | O verificador web já atende P3; API é conveniência |
| R20 · Feistel acima de 5M | O alocador atual cobre até 1M — sem demanda real |

## A ordem de corte, se atrasar

Do PRD §10, na ordem: **P1 inteiro → app adiado para v1.1 (mantendo a web) → R9.4 além da
exportação básica → R9.2 sem busca por CPF → e-mail em vez de WhatsApp → confirmação de entrega
só pelo operador.**

> O corte do app é o de **maior alívio e menor dano** porque o caminho de compra continua de pé
> pela web. Essa é a razão de RNF-16 ser requisito e não conveniência.
