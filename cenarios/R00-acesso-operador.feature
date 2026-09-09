# language: pt
@P0 @R0 @E01
Funcionalidade: Acesso do operador ao sistema
  Como operador
  Quero entrar com senha e segundo fator
  Para que uma senha vazada sozinha não dê acesso ao painel

  Contexto:
    Dado que existe um operador "ana@rifa.com" com TOTP ativado

  @BR-002 @critico
  Cenário: Login com senha correta não emite sessão utilizável
    Quando ela envia e-mail e senha corretos para "/api/auth/login"
    Então a resposta é um desafio de segundo fator
    E nenhuma sessão com "segundo_fator_em" preenchido é criada
    E a resposta não contém token de acesso utilizável em rota admin

  @BR-003 @critico
  Cenário: Rota admin recusa sessão sem segundo fator
    Dado que ela iniciou login mas não verificou o TOTP
    Quando ela chama "GET /api/admin/campanhas"
    Então a resposta é 401
    E o corpo não revela se a rota existe

  @BR-002
  Cenário: Segundo fator correto autoriza a sessão
    Dado que ela iniciou login
    Quando ela envia o código TOTP válido para "/api/auth/2fa/verificar"
    Então a sessão passa a ter "segundo_fator_em" preenchido
    E "GET /api/admin/campanhas" responde 200

  @BR-004 @critico
  Esquema do Cenário: Falha de login não distingue causa
    Quando ela envia "<email>" e "<senha>"
    Então a resposta é 401
    E a mensagem é exatamente "Credenciais inválidas"
    E o tempo de resposta não difere de forma observável entre os casos

    Exemplos:
      | email               | senha        |
      | ana@rifa.com        | errada       |
      | naoexiste@rifa.com  | qualquer     |

  @BR-005
  Cenário: Bloqueio temporário após tentativas falhas
    Quando ela erra a senha 5 vezes seguidas
    Então "bloqueado_ate" é preenchido
    E mesmo com a senha correta o login é recusado até o prazo passar

  @BR-009
  Cenário: Reuso de refresh token revoga a sessão
    Dado que ela tem uma sessão ativa e rotacionou o refresh token
    Quando o token antigo é apresentado novamente
    Então a sessão é revogada
    E um registro de auditoria de "reuso de refresh" é gravado

  @BR-006
  Cenário: Segredo TOTP nunca é legível no banco
    Quando o segredo TOTP é persistido
    Então a coluna "totp_secret_cifrado" não contém o segredo em claro
    E a chave de decifragem não está no banco

  @BR-014
  Cenário: Toda ação administrativa vai para auditoria
    Dado que ela tem sessão autorizada
    Quando ela publica uma campanha
    Então existe registro em "auditoria" com o "operador_id" dela
    E o registro entra na cadeia de hash sem quebrá-la
