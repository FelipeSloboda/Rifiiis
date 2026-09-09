# language: pt
@P0 @R7 @E04
Funcionalidade: Cadastro do comprador

  @BR-120
  Cenário: PII é cifrada sob a chave do titular
    Quando o comprador se cadastra com nome, CPF, nascimento e contato
    Então os campos são persistidos cifrados
    E a chave do titular é armazenada embrulhada pela KEK externa

  @BR-123 @BR-124
  Cenário: CPF gera índice cego derivado
    Quando o cadastro é gravado
    Então "cpf_indice" é derivado com Argon2id e salt do tenant
    E o CPF em claro não aparece em nenhuma coluna

  Cenário: Mesmo CPF no mesmo tenant reaproveita o comprador
    Dado um comprador já cadastrado
    Quando outro pedido é feito com o mesmo CPF
    Então nenhum comprador duplicado é criado

  @BR-038
  Cenário: Cadastro exige aceite de maioridade
    Quando o comprador não aceita a declaração de 18+
    Então o cadastro é recusado

  @BR-128
  Cenário: Consentimento registra versão, timestamp e IP
    Quando o comprador aceita o regulamento
    Então a versão do termo, o horário e o IP são gravados
