# language: pt
@P0 @R3 @E04
Funcionalidade: Checkout Pix com reserva temporária
  Como comprador
  Quero pagar por Pix e receber meus números na hora
  Para ter certeza de que a compra valeu

  Contexto:
    Dado uma campanha publicada com números disponíveis
    E um comprador cadastrado

  @BR-060 @BR-061
  Cenário: Pedido criado reserva números e emite cobrança
    Quando o comprador cria um pedido de 5 números com "Idempotency-Key: abc"
    Então o pedido fica "AGUARDANDO_PAGAMENTO"
    E 5 números ficam "RESERVADO"
    E uma cobrança Pix é emitida com copia-e-cola

  @BR-061 @critico
  Cenário: Retry com a mesma chave não reserva de novo
    Dado um pedido criado com "Idempotency-Key: abc"
    Quando a mesma requisição é reenviada com "Idempotency-Key: abc"
    Então a resposta é o mesmo pedido
    E nenhum número adicional é reservado

  @BR-063 @critico
  Cenário: A cobrança tem o operador como recebedor
    Quando a cobrança é emitida
    Então o recebedor é a conta de recebimento do operador
    E nenhuma conta da plataforma aparece na cobrança

  @BR-064 @BR-065 @critico
  Cenário: O corpo do webhook não define o valor pago
    Dado um webhook "PAID" com valor adulterado para R$ 0,01
    Quando o worker processa o evento
    Então ele consulta a API do PSP para obter o valor real
    E o pedido só é confirmado se o valor real bater com o esperado

  @BR-066 @critico
  Cenário: Webhook duplicado é idempotente
    Dado um webhook com "evento_id" já processado
    Quando ele chega novamente
    Então nada muda no pedido
    E não há segunda atribuição de números

  @BR-067
  Cenário: Webhook responde rápido
    Quando um webhook é recebido
    Então a resposta HTTP sai sem esperar o processamento
    E o processamento ocorre de forma assíncrona

  @BR-068
  Cenário: Payload do webhook é cifrado na gravação
    Quando o payload é persistido
    Então o conteúdo não é legível em claro no banco

  @BR-049 @BR-069
  Cenário: Falta de estoque após pagamento aciona estorno
    Dado que o estoque acabou entre a reserva e a confirmação
    Quando o pagamento é confirmado
    Então o pedido vai para "ESTORNO_PENDENTE"
    E o comprador é informado de que a devolução está em andamento

  @BR-070 @BR-071
  Cenário: Estorno que falha por saldo entra na fila
    Dado que o PSP recusa o estorno por saldo insuficiente
    Quando o estorno é tentado
    Então ele fica em "ESTORNO_PENDENTE" com o motivo
    E o operador vê a fila com o total devido
    E um retry com backoff é agendado
