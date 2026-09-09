# language: pt
@P0 @R0.5 @E01
Funcionalidade: Provisionamento da conta do operador

  @BR-008
  Cenário: Primeiro acesso obriga ativar TOTP
    Dado um operador provisionado sem TOTP ativado
    Quando ele entra pela primeira vez
    Então é obrigado a ativar o segundo fator antes de qualquer ação

  @BR-007
  Cenário: Ativação emite códigos de recuperação de uso único
    Quando o TOTP é ativado
    Então códigos de recuperação são emitidos uma única vez
    E o banco guarda apenas os hashes

  @BR-007
  Cenário: Código de recuperação não se reutiliza
    Dado um código já usado
    Quando ele é apresentado de novo
    Então o acesso é recusado

  @BR-010 @critico
  Cenário: Desativar operador revoga sessões na mesma transação
    Dado um operador com 3 sessões ativas
    Quando ele é desativado
    Então "desativado_em" é preenchido
    E as 3 sessões ficam revogadas
    E ele não consegue mais fazer login

  @BR-011 @BR-126 @critico
  Cenário: Não existe rota que apague operador
    Quando as rotas administrativas são inspecionadas
    Então nenhuma delas remove o registro do operador
    E a atribuição de apurações manuais anteriores continua íntegra

  @BR-012
  Cenário: Anonimizar exige desativação prévia
    Dado um operador ativo
    Quando a anonimização é tentada
    Então o banco recusa pela restrição de coerência
