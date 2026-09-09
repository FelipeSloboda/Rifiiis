# language: pt
@P0 @RNF-07 @RNF-10 @E07 @critico
Funcionalidade: LGPD — shredding, retenção e integridade da auditoria
  Como titular de dados
  Quero exercer meus direitos
  Sem que isso destrua a prova pública do sorteio

  # Este é o teste "crypto-shredding" citado na SPEC §9. Roda no CI.

  Contexto:
    Dado uma campanha completa com comprador, pedido pago, apuração e entrega confirmada
    E cerca de 50 registros de auditoria

  @BR-122 @critico
  Cenário: A cadeia de auditoria valida antes do shredding
    Quando a cadeia é verificada de ponta a ponta
    Então ela é válida

  @BR-121 @BR-122 @critico
  Cenário: A cadeia continua válida depois do shredding
    Quando a chave do titular é apagada
    E a cadeia é verificada de novo
    Então ela é válida de forma idêntica
    E a raiz Merkle do snapshot recomputada bate com a raiz carimbada

  @BR-120
  Cenário: Nenhum campo do titular é legível após o shredding
    Quando a chave do titular é apagada
    Então nome, CPF, nascimento, telefone e e-mail estão ilegíveis
    E o "id" e as chaves estrangeiras permanecem íntegros

  @BR-115 @critico
  Cenário: A prova de entrega sobrevive à exclusão do dado pessoal
    Quando a chave do titular é apagada
    Então "numero_apurado", datas e status da entrega continuam legíveis
    E a identificação do ganhador fica ilegível

  @BR-124 @critico
  Cenário: O limite por CPF continua valendo após o shredding
    Dado um titular que atingiu o limite da campanha
    Quando a chave dele é apagada
    E ele tenta comprar de novo com o mesmo CPF
    Então o pedido é recusado com "LIMITE_CPF_EXCEDIDO"

  @BR-084 @critico
  Cenário: Os salts do índice e do leaf nunca coincidem
    Dado o mesmo CPF
    Quando o índice e o leaf são derivados
    Então os dois valores são diferentes
    # Se alguém unificar os salts numa refatoração, este cenário falha.

  @BR-013 @BR-125
  Cenário: Expurgo de sessão e anonimização do operador por prazo
    Quando o relógio avança 91 dias
    E o worker de retenção roda
    Então "ip" e "user_agent" das sessões estão nulos
    E "segundo_fator_em" e "revogada_em" permanecem
    E um operador desligado há mais do que o prazo legal está anonimizado
    E as chaves estrangeiras dele em auditoria continuam resolvendo
