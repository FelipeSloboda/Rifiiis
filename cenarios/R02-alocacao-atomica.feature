# language: pt
@P0 @R2 @E03 @critico
Funcionalidade: Estoque e alocação atômica de números
  Como sistema
  Quero alocar números sob concorrência sem colisão
  Para que dois compradores nunca recebam o mesmo número

  # Este arquivo cobre a invariante mais cara do produto.
  # SPEC §11: o teste de concorrência é escrito ANTES do alocador e rodado contra
  # uma implementação ingênua para provar que ele falha. Teste de corrida que nunca
  # falhou pode estar medindo serialização acidental.

  Contexto:
    Dado uma campanha publicada com 1000000 de números

  @BR-040
  Cenário: Estoque nasce embaralhado
    Quando o estoque é gerado
    Então existem exatamente 1000000 números
    E os valores visíveis cobrem "[0..999999]" sem repetição
    E a coluna "ordem" é uma permutação distinta da ordem natural de "numero"

  @BR-043 @critico
  Cenário: Cem pedidos concorrentes não colidem
    Quando 100 pedidos de 10 números são criados simultaneamente
    Então 1000 números distintos são reservados
    E nenhum número aparece em dois pedidos
    E o total de números "DISPONIVEL" caiu exatamente 1000

  @BR-043 @critico
  Cenário: A implementação ingênua falha o mesmo teste
    Dado um alocador sem "SKIP LOCKED" nem lock de linha
    Quando 100 pedidos concorrentes de 10 números são criados
    Então ocorre colisão ou deadlock
    # Este cenário existe para provar que o teste tem poder de detecção.

  @BR-042
  Cenário: Linha travada não bloqueia o lote
    Dado que uma transação longa segura a linha de "ordem" 5
    Quando outro pedido aloca 3 números
    Então ele recebe as ordens 6, 7 e 8
    E não espera pela transação longa

  @BR-048
  Cenário: Pedido sem estoque suficiente falha inteiro
    Dado que restam 3 números disponíveis
    Quando um pedido de 10 números é criado
    Então o pedido é recusado com "ESTOQUE_INSUFICIENTE"
    E nenhum dos 3 números fica reservado

  @BR-045 @BR-046
  Cenário: Reserva expirada volta ao estoque após consulta ao PSP
    Dado um pedido com reserva vencida
    E que o PSP responde que a cobrança não foi paga
    Quando o worker de expiração roda
    Então os números voltam a "DISPONIVEL"
    E o pedido fica "EXPIRADO"

  @BR-046 @critico
  Cenário: Pagamento tardio não perde a reserva
    Dado um pedido com reserva vencida
    E que o PSP responde que a cobrança FOI paga
    Quando o worker de expiração roda
    Então os números NÃO voltam ao estoque
    E o pedido é confirmado como "PAGO"

  @BR-047
  Cenário: Expiração em massa não trava a alocação
    Dado 50000 reservas vencendo no mesmo minuto
    Quando o worker de expiração roda
    Então ele processa em lotes de no máximo 5000
    E a alocação concorrente continua respondendo
