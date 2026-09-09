# language: pt
@P0 @R8 @E07
Funcionalidade: Guarda-corpos de compliance

  @BR-025 @critico
  Cenário: Publicação exige autorização válida
    Dado uma campanha sem número de autorização
    Quando a publicação é tentada
    Então ela é bloqueada

  @BR-025
  Cenário: Autorização vencida bloqueia a publicação
    Dado uma autorização com validade no passado
    Quando a publicação é tentada
    Então ela é bloqueada

  @BR-029
  Cenário: Alerta de autorização perto de vencer
    Dado uma autorização que vence em 5 dias
    Quando o monitor roda
    Então um alerta de severidade média é emitido

  @BR-026
  Cenário: Publicação exige regulamento versionado
    Dado uma campanha sem regulamento
    Quando a publicação é tentada
    Então ela é bloqueada

  @BR-037 @critico
  Cenário: Limite por CPF é respeitado
    Dado uma campanha com limite de R$ 100,00 por CPF
    E um comprador que já gastou R$ 90,00
    Quando ele tenta comprar R$ 20,00
    Então o pedido é recusado com "LIMITE_CPF_EXCEDIDO"

  @BR-038
  Cenário: Menor de idade é bloqueado
    Quando o comprador declara ter menos de 18 anos
    Então a compra é recusada

  @BR-127 @critico
  Cenário: Log não contém PII
    Quando um pedido é criado e registrado em log
    Então nenhum CPF, telefone ou e-mail aparece na saída
