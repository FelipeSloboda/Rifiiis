# language: pt
@P0 @R9.1 @E08
Funcionalidade: Visão geral da campanha

  Cenário: Painel mostra arrecadação e estoque
    Dado uma campanha com 400 números pagos de 1000
    Quando o operador abre o painel
    Então vê o total arrecadado, números vendidos e restantes

  Cenário: Estado da campanha é explícito
    Quando a campanha está congelada
    Então o painel mostra "CONGELADA" e o que isso implica

  Cenário: Campanha sem vendas não quebra a tela
    Dado uma campanha sem nenhum pedido
    Quando o operador abre o painel
    Então vê o estado vazio com orientação, sem erro

  @RNF-09
  Cenário: Painel passa na verificação de acessibilidade
    Quando a tela é auditada com axe-core nos dois temas
    Então não há violações critical nem serious
