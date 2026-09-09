# language: pt
@P0 @R1 @E02
Funcionalidade: Cadastro e publicação de campanha

  @BR-023
  Cenário: Campanha nasce em rascunho
    Quando o operador cria uma campanha
    Então ela fica "RASCUNHO" e não é visível publicamente

  @BR-020
  Esquema do Cenário: Total de números tem limites duros
    Quando o operador informa "<total>" números
    Então o resultado é "<resultado>"

    Exemplos:
      | total     | resultado |
      | 99        | recusado  |
      | 100       | aceito    |
      | 1000000   | aceito    |
      | 1000001   | recusado  |

  @BR-022
  Cenário: Slug é único por tenant
    Dado uma campanha com slug "rifa-do-carro"
    Quando outra campanha do mesmo tenant usa o mesmo slug
    Então a criação é recusada

  @BR-024 @BR-144 @critico
  Cenário: Publicação sem conta verificada é bloqueada
    Dado uma campanha completa e nenhuma conta de recebimento verificada
    Quando a publicação é tentada
    Então ela é bloqueada com o motivo explícito

  @BR-027
  Cenário: Publicar dispara geração de estoque
    Quando a campanha é publicada
    Então a geração do estoque é enfileirada
    E a tela mostra o estado "gerando"

  @BR-028 @critico
  Cenário: Campanha publicada não muda preço nem regra
    Dado uma campanha publicada
    Quando o operador tenta alterar preço, total ou regra de apuração
    Então a alteração é recusada

  Cenário: Página pública mostra preço sem exigir cadastro
    Quando um visitante abre a página da campanha
    Então vê prêmio, preço e números restantes sem se cadastrar
