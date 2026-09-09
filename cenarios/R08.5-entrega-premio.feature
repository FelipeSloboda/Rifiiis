# language: pt
@P0 @R8.5 @E06
Funcionalidade: Entrega do prêmio e encerramento

  @BR-112
  Cenário: Operador registra a entrega com comprovante
    Dado uma apuração publicada
    Quando o operador registra a entrega com foto do comprovante
    Então a entrega fica pendente de confirmação do ganhador
    E o comprovante é armazenado cifrado

  @BR-113
  Cenário: Ganhador confirma o recebimento
    Quando o ganhador confirma
    Então a entrega fica confirmada
    E o IP do aceite é gravado cifrado

  @BR-039
  Cenário: Campanha só encerra com entrega registrada
    Dado uma apuração publicada sem entrega
    Quando o encerramento é tentado
    Então ele é recusado

  @BR-114
  Cenário: Prazo de entrega é monitorado
    Dado uma entrega com prazo vencido
    Quando o monitor roda
    Então ela aparece na lista de pendências do operador

  @BR-115 @critico
  Cenário: A prova pública da entrega sobrevive ao esquecimento
    Dado uma entrega confirmada
    Quando o ganhador exerce o direito ao esquecimento
    Então o número apurado, a data e o status continuam públicos
    E a identificação dele fica ilegível

  Cenário: Entrega aparece na página pública
    Quando a entrega é confirmada
    Então a página pública mostra número, data e status, sem identificar a pessoa
