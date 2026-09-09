# language: pt
@P0 @R9.2 @E08
Funcionalidade: Pedidos — busca, filtro e detalhe

  Cenário: Buscar pedido por CPF
    Dado um comprador com pedido pago
    Quando o operador busca pelo CPF dele
    Então o pedido aparece na lista

  @BR-124
  Cenário: Busca por CPF usa o índice cego
    Quando a busca por CPF é executada
    Então a consulta usa "cpf_indice", não o CPF em claro

  Cenário: Filtrar por status
    Quando o operador filtra por "AGUARDANDO_PAGAMENTO"
    Então só pedidos nesse estado aparecem

  Cenário: Detalhe mostra números e histórico
    Quando o operador abre um pedido
    Então vê os números atribuídos e as transições de estado

  @BR-127
  Cenário: Tela não expõe PII além do necessário
    Quando o operador lista pedidos
    Então o CPF aparece mascarado até ele abrir o detalhe
