# language: pt
@P0 @R9.3 @E08
Funcionalidade: Apurações — estado, tentativas e reprocesso

  @BR-104
  Cenário: Histórico de tentativas é visível
    Dado uma apuração com 2 tentativas falhas
    Quando o operador abre a tela
    Então vê fonte, resultado e motivo de cada tentativa

  Cenário: Apuração bloqueada é evidente
    Dado uma apuração bloqueada
    Quando o operador abre a tela
    Então vê o estado bloqueado e a ação disponível

  Cenário: Reprocessar tenta a fonte oficial de novo
    Quando o operador aciona reprocessar
    Então uma nova tentativa é registrada

  @BR-102
  Cenário: Entrada manual pede o segundo responsável
    Quando o operador submete entrada manual
    Então a tela informa que falta a confirmação de outro responsável

  Cenário: Estado de todas as campanhas numa lista
    Quando o operador abre apurações
    Então vê o estado da apuração de cada campanha

  @RNF-09
  Cenário: Tela de apurações é acessível
    Quando auditada com axe-core
    Então não há violações critical nem serious
