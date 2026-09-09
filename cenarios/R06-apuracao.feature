# language: pt
@P0 @R6 @E06 @critico
Funcionalidade: Apuração automática
  Como sistema
  Quero derivar o ganhador da extração oficial pela regra publicada
  Para que o resultado seja recomputável por qualquer terceiro

  Contexto:
    Dado uma campanha congelada com commitment carimbado
    E a regra de apuração publicada "{fonte: federal, premios: [1,2], digitos: 3}"

  @BR-100
  Cenário: Fonte primária responde e a apuração roda
    Quando a extração é obtida da fonte primária
    Então o ganhador é derivado pela regra
    E o resultado é publicado com a extração de origem
    E a tentativa fica registrada com resultado "sucesso"

  @BR-100 @BR-104
  Cenário: Primária falha e a secundária assume
    Dado que a fonte primária responde timeout
    Quando a apuração roda
    Então a fonte secundária é consultada
    E existem duas tentativas registradas, uma "timeout" e uma "sucesso"

  @BR-101 @BR-105 @critico
  Cenário: Ambas as fontes falham e a apuração bloqueia
    Dado que primária e secundária falham
    Quando a apuração roda
    Então a apuração fica "BLOQUEADA"
    E nenhum resultado é publicado
    E NENHUMA extração sintética é gerada
    E o operador é notificado

  @BR-102 @critico
  Cenário: Entrada manual exige dois responsáveis distintos
    Dado uma apuração bloqueada
    Quando o operador "ana" informa a extração manualmente
    Então a apuração aguarda segunda confirmação
    E só é aceita após confirmação do operador "bruno"

  @BR-103 @critico
  Cenário: Dupla confirmação do mesmo humano é recusada
    Dado que "ana" informou a extração manualmente
    Quando "ana" tenta confirmar a própria entrada
    Então a confirmação é recusada
    E a apuração continua aguardando

  @BR-106
  Cenário: Terceiro recomputa o ganhador com dados públicos
    Dado o snapshot público, a raiz, o carimbo e a extração oficial
    Quando um terceiro aplica a regra publicada
    Então ele chega ao mesmo número apurado
    E não precisou de nenhum acesso ao sistema

  @BR-107
  Esquema do Cenário: Casos degenerados da regra de aproximação
    Dado a extração "<extracao>" e o estoque "<estoque>"
    Quando a regra de aproximação é aplicada
    Então o número apurado é "<resultado>"

    Exemplos:
      | extracao | estoque      | resultado          |
      | 000      | 0..999       | 0                  |
      | 999      | 0..999       | 999                |
      | 500      | vendidos ímpares | o mais próximo por regra determinística |

  @BR-108 @critico
  Cenário: Apuração publicada não se edita
    Dado um resultado publicado
    Quando alguém tenta alterar o número apurado
    Então não existe rota nem caminho de código que o permita

  @BR-109 @BR-110 @BR-111
  Cenário: Retificação corrige sem apagar a original
    Dado um resultado publicado sobre extração de data errada
    Quando a retificação é solicitada com causa "insumo_incorreto"
    E dois operadores distintos autorizam
    Então a apuração retificada é publicada
    E a apuração original continua visível publicamente
    E a cadeia de auditoria registra as duas

  @BR-035 @critico
  Cenário: Nunca sortear entre não vendidos
    Dado uma campanha com 1000 números e apenas 10 vendidos
    Quando a apuração roda
    Então o ganhador sai dos 10 vendidos pela regra publicada
    E nenhum número não vendido é considerado ganhador
