# language: pt
@P0 @R10 @E02
Funcionalidade: Conta de recebimento do operador

  @BR-145 @critico
  Cenário: A plataforma nunca custodia o dinheiro
    Quando uma cobrança é emitida
    Então o recebedor é a conta do operador
    E nenhuma conta da bit4devs participa do fluxo

  @BR-141 @BR-142 @critico
  Cenário: Conta de terceiro é recusada
    Dado uma conta cujo titular difere do CNPJ do organizador
    Quando a verificação de titularidade roda
    Então a conta é recusada

  @BR-141
  Cenário: Conta com titularidade conferida é aceita
    Dado uma conta cujo titular bate com o CNPJ
    Quando a verificação roda
    Então a conta fica verificada e apta a publicar

  @BR-140
  Cenário: Só uma conta ativa por operador
    Dado uma conta ativa
    Quando outra conta é ativada
    Então a anterior deixa de ser a ativa

  @BR-143
  Cenário: Trocar conta exige segundo fator
    Quando o operador tenta trocar a conta sem 2FA recente
    Então a operação é recusada

  @BR-071
  Cenário: Fila de estornos pendentes mostra o total devido
    Dado 3 estornos pendentes
    Quando o operador abre a tela
    Então vê os 3 com motivo e o total devido

  @BR-070
  Cenário: Retry do estorno após regularizar saldo
    Dado um estorno pendente por saldo insuficiente
    Quando o operador regulariza e aciona o retry
    Então o estorno é reprocessado
