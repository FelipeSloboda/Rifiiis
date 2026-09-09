# RUNBOOK — Estorno pendente

**Sintoma:** fila de estornos pendentes com valor devido; comprador vendo "devolução em andamento".
**Severidade:** alta — é dinheiro de terceiro retido.

## O que aconteceu

Um pagamento precisou ser devolvido (sem estoque, ou campanha já congelada) e o estorno falhou no
PSP — quase sempre **saldo insuficiente na conta do operador**.

Como o Pix cai direto na sua conta (sem custódia), o sistema não tem como devolver sozinho.

## Por que existe o estado "pendente"

Ir direto de `PAGO` para `ESTORNADO` declararia devolvido um dinheiro que continua com você. O
estado existe **para o sistema não mentir** ao comprador.

## Ação

1. Abra `10-conta-recebimento` → estornos pendentes.
2. Veja o **total devido**.
3. Garanta saldo na conta.
4. Acione **Retry** em cada estorno, ou aguarde o retry automático com backoff.
5. Confirme que a fila zerou.

## Se o retry falhar de novo

| Motivo | Ação |
|---|---|
| Saldo ainda insuficiente | Aporte e repita |
| Conta bloqueada no PSP | Resolva com o PSP — nenhum retry passa antes |
| Dados do recebedor inválidos | Abra chamado; pode exigir devolução manual |

## Prazo

Alerta dispara com **24h** de fila aberta. Dinheiro de terceiro retido é risco jurídico e
reputacional — trate como incidente, não como pendência administrativa.

## Comunicação

O comprador já vê "devolução em processamento" no pedido. Se ele procurar você, seja direto sobre
o prazo. **Não** prometa data que dependa de saldo que você ainda não tem.
