# language: pt
@P0 @R9.6 @E10
Funcionalidade: Estados de exceção visíveis ao público
  # O comprador precisa entender o que houve para não achar que foi roubado.

  Cenário: Fonte da extração indisponível
    Dado que a apuração está bloqueada por falha das fontes
    Quando um comprador abre a página da campanha
    Então vê que a apuração está aguardando a extração oficial
    E vê que nenhum resultado foi produzido

  Cenário: Campanha cancelada sem vendas
    Dado uma campanha cancelada sem vendas
    Quando alguém abre a página
    Então vê o motivo e o commitment da lista vazia

  Cenário: Pagamento após o congelamento
    Dado um pagamento tardio estornado
    Quando o comprador abre o pedido
    Então vê que a campanha já havia fechado e que a devolução está em curso

  Cenário: Estorno em andamento
    Dado um estorno pendente
    Quando o comprador consulta
    Então vê que a devolução está em processamento

  Cenário: Apuração retificada
    Dado uma apuração retificada
    Quando alguém abre a página
    Então vê o resultado vigente e o original, com a causa

  Cenário: Commitment não carimbado
    Dado que o carimbo falhou
    Quando alguém abre a página
    Então vê que a campanha está aguardando o carimbo
    E que a apuração não roda antes disso
