# ADR-010 — A campanha encerra na entrega, não na apuração

**Status:** aceita · **Contexto:** PRD R8.5

## Decisão

A campanha só chega a `ENCERRADA` depois que a entrega do prêmio é **registrada pelo operador**
e **confirmada pelo ganhador**. Apurar não encerra.

## Alternativa recusada

**Encerrar em `APURADA`** — o sorteio aconteceu, o ganhador é público, fim.

## Por quê

O vetor de fraude que motivou este produto não está no sorteio: está na **atribuição e na
entrega**. Casos públicos de rifa fraudada raramente envolvem manipular o número sorteado —
envolvem o prêmio que nunca sai, ou o "ganhador" que é conhecido do organizador.

Provar metade do percurso e chamar de prova é pior que não provar: **torna o selo falso**. Se o
sistema declara "sorteio verificado" e o prêmio não é entregue, o selo passa a atestar exatamente
o que o comprador não precisava.

## Consequências

- `EntregaPremio` é agregado de primeira classe, com comprovante cifrado e confirmação do ganhador.
- A prova de entrega **sobrevive ao crypto-shredding**: `numero_apurado`, datas e status
  continuam públicos; a identificação do ganhador fica ilegível (BR-115).
- Há prazo limite monitorado — entrega atrasada aparece nas pendências do operador.
- A métrica "campanhas com entrega registrada" tem alvo de 100% em D+30.

## A tensão com a LGPD, e como se resolve

O ganhador tem direito ao esquecimento; a campanha tem obrigação de provar a entrega. A solução
não é escolher um lado: o que era **público** (número, data, status) continua público; o que era
**pessoal** (quem) fica ilegível. O passo 7 do teste `crypto-shredding` no CI existe para provar
isso a cada build.
