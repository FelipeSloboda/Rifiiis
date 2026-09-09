# language: pt
@P0 @RNF-05 @RNF-06 @RNF-11 @RNF-12 @E07
Funcionalidade: Segurança de transporte, autorização e limite de taxa

  @RNF-05
  Cenário: TLS e cabeçalhos de segurança
    Quando qualquer resposta é inspecionada
    Então há HSTS, CSP, X-Frame-Options e X-Content-Type-Options

  @RNF-11 @critico
  Cenário: Autorização verifica tenant no repositório
    Dado dois tenants com campanhas
    Quando o operador do tenant A pede uma campanha do tenant B
    Então a resposta é 404, sem revelar existência

  @RNF-12
  Cenário: Rate limit no checkout
    Quando mais de 10 requisições por minuto partem do mesmo IP
    Então as excedentes são recusadas

  @BR-019 @critico
  Cenário: Guard sozinho não basta
    Quando uma consulta é feita sem filtro de tenant no repositório
    Então o teste falha
    # A verificação é dupla por construção: guard e repositório.

  @RNF-06 @critico
  Cenário: Redator de PII atua no transporte
    Quando um log com CPF é emitido pelo call site
    Então a saída final não contém o CPF

  Cenário: Segredos não estão no código
    Quando o repositório é varrido
    Então nenhum segredo literal é encontrado
