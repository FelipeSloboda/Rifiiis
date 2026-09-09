---
id: exploratory-charters
etapa: 12
data: 2026-09-08
status: done
---

# CHARTERS DE TESTE EXPLORATÓRIO — Dream RI

Sessões time-boxed de 60–90 min. O automatizado cobre o que sabemos perguntar; o exploratório
existe para o que não sabemos.

---

## CH-01 · Explorar o checkout sob rede instável

**Missão:** descobrir o que acontece quando o comprador perde conexão entre reservar e pagar.
**Áreas:** `02-checkout-pix`, worker de expiração, reconsulta ao PSP.
**Perguntas:** o Pix continua válido? A reserva expira com o pagamento em trânsito? A tela mente
sobre o estado?
**Por que importa:** o público compra em rede móvel instável — este é o caminho normal, não o triste.

---

## CH-02 · Tentar comprar depois do congelamento

**Missão:** achar qualquer caminho que permita entrar na lista após T-2h.
**Áreas:** congelamento, pedido pendente, webhook tardio, retry.
**Ataque:** criar pedido antes, pagar depois; reenviar webhook antigo; manipular timestamps.
**Por que importa:** se algum caminho passar, o commitment vira ficção.

---

## CH-03 · Verificar como um auditor hostil

**Missão:** tentar verificar sem nenhuma cooperação nossa — e falhar de propósito.
**Áreas:** snapshot público, raiz, carimbo, verificador.
**Perguntas:** os dados públicos bastam? A documentação explica como recomputar? Um comprovante
adulterado é rejeitado?
**Por que importa:** é a persona P3 executada como adversário, que é como ela vai aparecer.

---

## CH-04 · Estressar a apuração degradada

**Missão:** derrubar as duas fontes e ver se algum caminho produz resultado.
**Áreas:** cascata, bloqueio, entrada manual.
**Ataque:** mesma pessoa nas duas confirmações; extração com formato inesperado; reprocessar em loop.
**Por que importa:** é onde o produto pode inventar em vez de bloquear.

---

## CH-05 · Explorar os limites da LGPD

**Missão:** encontrar PII sobrevivendo ao shredding.
**Áreas:** todas as tabelas, logs, métricas, exportações, comprovantes, backups.
**Perguntas:** o relatório exportado vaza? A métrica segmenta por titular? O backup antigo tem a
DEK que foi apagada?
**Por que importa:** o inventário da SPEC §9 é bom — mas um campo esquecido anula a garantia inteira.

---

## CH-06 · Usar o painel como operador apressado

**Missão:** operar no celular, na rua, com uma mão.
**Áreas:** todo o admin.
**Perguntas:** dá para publicar campanha sem entender o que se está aceitando? A tela de apuração
bloqueada diz o que fazer? O estado vazio orienta ou só informa?
**Por que importa:** a persona P1 opera assim, não sentada no desktop.

---

## CH-07 · Backup antigo e a DEK apagada

**Missão:** verificar se restaurar um backup anterior ao shredding ressuscita a PII.
**Áreas:** PITR, retenção de backup, ciclo de vida das chaves.
**Por que importa:** o crypto-shredding pressupõe que a chave sumiu **de todo lugar**. Um backup
com a DEK antiga desfaz o direito exercido — e ninguém testa isso.

> CH-07 é o charter que mais provavelmente encontra algo. Foi escrito por último, ao perceber
> que o teste de shredding no CI roda em banco novo, e nunca contra um restore.
