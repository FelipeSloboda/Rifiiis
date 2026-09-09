---
id: task-details
etapa: 10
data: 2026-09-08
status: done
---

# CORPO DAS ISSUES — Dream RI

Fonte da importação para o board `DRI`. Cada item do [BACKLOG](BACKLOG.md) vira uma issue com o
corpo montado por este modelo, seguindo [TASK_AUTHORING_RULES](../TASK_AUTHORING_RULES.md).

## Modelo

```markdown
## Contexto
Realiza **R##** / **US-NNN**.
Cenários: `cenarios/<arquivo>.feature`
Regras: BR-NNN, BR-NNN
Tela: `NN-slug` (ou: backend-only)

## Escopo
**Entra:** …
**NÃO entra:** …
**Depende de:** DRI-###

## Pronto quando
- [ ] Cenário "<nome exato>" passa
- [ ] <gates aplicáveis da DoD>

---
<DoD colada de requirements/DOR_DOD.md>
```

Labels: `epic:E0N` · `req:R##` · `lane:backlog` · `critico` quando aplicável.

---

## Corpos dos itens críticos

Os demais seguem o modelo diretamente. Estes três estão escritos por extenso porque a redação
errada neles produz trabalho errado.

### Item 16 · Teste de concorrência da alocação `critico`

```markdown
## Contexto
Realiza RNF-01. Precede o alocador (item 18) por exigência do ADR-012.
Cenários: `cenarios/R02-alocacao-atomica.feature`
Regras: BR-042, BR-043
Backend-only.

## Escopo
**Entra:** teste de 100 pedidos concorrentes × 10 números com Testcontainers (Postgres real);
implementação ingênua de controle, sem SKIP LOCKED.
**NÃO entra:** o alocador de produção (item 18).
**Depende de:** item 17 (geração do estoque).

## Pronto quando
- [ ] O cenário "A implementação ingênua falha o mesmo teste" **FALHA** contra a versão ingênua
- [ ] A saída dessa falha está anexada como evidência
- [ ] O teste roda em Postgres real, nunca SQLite

> Um teste de corrida que nunca falhou pode estar medindo serialização acidental do ambiente.
> Provar que ele detecta a implementação ruim é metade do trabalho — e é a metade que costuma
> ser pulada.
```

### Item 31 · Árvore Merkle RFC 6962 `critico`

```markdown
## Contexto
Realiza R4. Cenários: `cenarios/R04-commitment.feature`
Regras: BR-085, BR-086
**Fonte externa dos vetores: RFC 6962.** Backend-only.

## Escopo
**Entra:** construção da árvore, prova de inclusão, verificação.
**NÃO entra:** carimbo (item 32), snapshot (item 30).

## Pronto quando
- [ ] A raiz bate com os **vetores publicados no RFC 6962** — os dois valores no comentário
- [ ] Folha usa `0x00` e nó interno `0x01`
- [ ] Nó ímpar é **promovido**, não duplicado
- [ ] Um script Python independente recomputa a raiz de 1000 folhas e chega ao mesmo valor
- [ ] 1M de folhas em < 2s (RNF-04)
- [ ] Cobertura do domínio: 100%

> Sem a separação de domínio, um nó interno pode ser apresentado como folha. Sem a promoção,
> duas listas diferentes podem produzir a mesma raiz. Ambos os erros passam nos testes ingênuos.
```

### Item 26 · Reconsulta ao PSP na confirmação `critico`

```markdown
## Contexto
Realiza R3 / ADR-022. Mitiga TH-030, a ameaça de maior exposição do projeto.
Cenários: `cenarios/R03-checkout-pix.feature`
Regras: BR-064, BR-065. Backend-only.

## Escopo
**Entra:** ao processar `PAID`, consultar a API do PSP e usar o valor de lá.
**NÃO entra:** recebimento do webhook (item 25).

## Pronto quando
- [ ] O cenário "O corpo do webhook não define o valor pago" passa com valor adulterado para R$ 0,01
- [ ] Nenhum caminho de código lê valor do corpo do webhook
- [ ] `security-auditor` confirma a mitigação de TH-030

> O webhook do PicPay é autenticado por token estático, não assinado: prova o chamador, não a
> integridade do corpo. Sem a reconsulta, um corpo forjado vira número entregue sem dinheiro.
```

---

## Regra de importação

Nenhuma issue entra em `lane:pronto-p-dev` sem passar pelo `po-reviewer`, que exige linha na
[TRACEABILITY_MATRIX](../requirements/TRACEABILITY_MATRIX.md). Issue sem requisito rastreável é
trabalho sem dono.
