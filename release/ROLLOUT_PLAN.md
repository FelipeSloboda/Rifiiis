---
id: rollout-plan
etapa: 13
data: 2026-09-08
status: done
---

# PLANO DE ROLLOUT — Dream RI

## O que torna este go-live diferente

Não é software que se sobe e observa. **A primeira campanha real envolve dinheiro de terceiro e
uma promessa pública de verificabilidade.** Um rollback depois que o commitment foi carimbado não
desfaz o carimbo — a prova é permanente por design.

Consequência: o ensaio (D+21) não é opcional, e o go-live é por campanha, não por deploy.

## Fases

### Fase 0 — Ensaio (D+21)

| Item | Critério |
|---|---|
| Campanha sintética completa | Congelada, carimbada, apurada |
| Carimbo | **ACT real**, não mock |
| Extração | Federal real |
| Verificação | **Por terceiro, usando só o verificador público** |

**Critério de avanço:** o terceiro chega ao mesmo ganhador sem nos perguntar nada. Se falhar,
não se ajusta a documentação — se ajusta o produto.

### Fase 1 — Campanha piloto (D+42)

| Item | Limite |
|---|---|
| Total de números | ≤ 10.000 |
| Operador | Um, acompanhado de perto |
| Superfície | Web garantida; app se aprovado |
| Monitoramento | Alertas críticos com resposta imediata |

**Por que campanha pequena:** o custo do carimbo é o mesmo, mas a exposição financeira e
reputacional é menor. Se algo der errado, o número de pessoas afetadas é gerenciável.

### Fase 2 — Operação normal

Após uma campanha completa com entrega confirmada e zero incidente crítico.

## Checklist de go-live

### Infra
- [ ] Object-lock ativo no storage de produção
- [ ] PITR do Postgres verificado com **restore de teste**
- [ ] KEK no gerenciador externo, fora do CI
- [ ] Alertas críticos com destinatário real e testados

### Produto
- [ ] Ensaio D+21 aprovado por terceiro
- [ ] Conta de recebimento do operador verificada
- [ ] Autorização do órgão válida, com validade > 30 dias
- [ ] Regulamento publicado e versionado

### Operação
- [ ] Runbooks escritos e lidos pelo operador
- [ ] Operador treinado (apuração bloqueada, estorno pendente, retificação)
- [ ] Canal de suporte definido
- [ ] Plano de resposta a rejeição de loja

## Rollback — o que dá e o que não dá

| Situação | Reversível? |
|---|---|
| Bug na tela | ✅ Deploy anterior |
| Bug no checkout | ✅ Deploy anterior; pedidos pendentes expiram |
| **Commitment carimbado errado** | ❌ **Irreversível.** O carimbo existe. Caminho: retificação (ADR-013) |
| **Apuração publicada errada** | ❌ Só retificação pública |
| Dinheiro recebido, número não entregue | ⚠️ `ESTORNO_PENDENTE` — reversível com saldo |

> **A coluna que importa é a segunda linha vermelha.** Depois do carimbo, não existe "voltar" —
> só existe "corrigir publicamente". É por isso que o ensaio precede a campanha real.

## Critérios de parada

Parar a campanha se: apuração bloqueada por mais de 24h sem caminho manual; estorno pendente
acima de 24h; qualquer indício de colisão de número; ou falha ao carimbar.
