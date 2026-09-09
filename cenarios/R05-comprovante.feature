# language: pt
@P0 @R5 @E05
Funcionalidade: Comprovante verificável do comprador
  Como comprador
  Quero conferir que meu número está na lista
  Sem depender da palavra do operador

  @BR-092
  Cenário: Comprovante traz leaf e prova de inclusão
    Dado um pedido pago numa campanha com commitment publicado
    Quando o comprador abre o comprovante
    Então ele vê o leaf hash e a prova de inclusão
    E vê a raiz carimbada e a autoridade do carimbo

  @BR-093 @critico
  Cenário: Verificador funciona sem autenticação
    Quando um terceiro abre o verificador público com o leaf
    Então a verificação confirma a inclusão
    E nenhum login foi exigido

  @BR-093 @critico
  Cenário: Verificação independe de contato conosco
    Dado o snapshot público, a raiz e o carimbo baixados
    Quando o terceiro recomputa a raiz localmente
    Então ela bate com a raiz carimbada

  Cenário: Prova inválida é rejeitada
    Quando um leaf que não está na árvore é verificado
    Então o verificador informa que não consta
    E não revela nenhum dado de outro comprador

  Cenário: Prova de 1 milhão de folhas cabe no comprovante
    Dado uma campanha de 1000000 de números
    Quando a prova de inclusão é gerada
    Então ela tem cerca de 20 hashes

  Cenário: Comprovante não expõe PII de terceiro
    Quando o comprovante é renderizado
    Então nenhum dado pessoal de outro comprador aparece
