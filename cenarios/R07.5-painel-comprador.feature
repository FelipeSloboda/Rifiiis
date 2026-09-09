# language: pt
@P0 @R7.5 @E04
Funcionalidade: Acesso e painel do comprador

  @BR-015 @BR-016
  Cenário: Acesso por código de uso único
    Quando o comprador pede acesso informando o CPF
    Então um código é enviado ao canal cadastrado
    E o código expira em 10 minutos

  @BR-017
  Cenário: Código é armazenado como hash
    Quando o código é gerado
    Então o banco guarda apenas o hash

  Cenário: Código usado não funciona de novo
    Dado um código já utilizado
    Quando ele é reapresentado
    Então o acesso é recusado

  @BR-018
  Cenário: Sessão do comprador dura 30 dias
    Quando o comprador entra com código válido
    Então a sessão expira em 30 dias

  Cenário: Painel lista números por campanha
    Dado um comprador com pedidos em duas campanhas
    Quando ele abre "meus números"
    Então vê os números agrupados por campanha e o status de cada pedido

  @RNF-12
  Cenário: Consulta por CPF tem rate limit
    Quando mais de 5 consultas por minuto partem do mesmo IP
    Então as excedentes são recusadas
