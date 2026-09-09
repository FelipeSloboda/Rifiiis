# language: pt
@P0 @R4 @E05 @critico
Funcionalidade: Congelamento e commitment criptográfico
  Como sistema
  Quero publicar um compromisso da lista antes de a extração existir
  Para que ninguém possa alterar a lista depois de conhecer o resultado

  # SPEC §11: vetores de Merkle vêm do RFC 6962, NUNCA gerados nesta sessão.
  # Implementação errada e teste errado concordam entre si; vetor publicado não.

  Contexto:
    Dado uma campanha com extração marcada para "2026-10-05T20:00:00Z"

  @BR-030 @BR-031
  Cenário: Congelamento em T-2h encerra a venda
    Quando o relógio chega a "2026-10-05T18:00:00Z"
    Então a campanha fica "CONGELADA"
    E criar pedido retorna "CAMPANHA_CONGELADA"

  @BR-032 @critico
  Cenário: Pagamento após o congelamento vai para estorno
    Dado um pedido pendente criado antes do congelamento
    Quando o pagamento é confirmado após o congelamento
    Então o pedido NÃO vira "PAGO"
    E um estorno é acionado
    E os números dele não entram no snapshot

  @BR-080 @BR-081
  Cenário: Snapshot contém só números pagos e nenhuma PII
    Dado 500 números pagos e 30 reservados não pagos
    Quando o snapshot é gerado
    Então ele tem exatamente 500 linhas
    E está ordenado crescente por número
    E nenhuma linha contém CPF, nome, telefone ou e-mail

  @BR-085 @BR-086 @critico
  Cenário: Árvore Merkle segue o RFC 6962
    Dado os vetores de teste publicados no RFC 6962
    Quando a árvore é construída
    Então a raiz calculada bate com o vetor de referência
    E folhas usam prefixo "0x00" e nós internos "0x01"
    E nó ímpar é promovido sem re-hash

  @BR-085 @critico
  Cenário: Raiz recomputada por implementação independente confere
    Dado um snapshot de 1000 folhas
    Quando a raiz é recomputada por um script Python independente
    Então as duas raízes são idênticas

  @BR-090 @critico
  Cenário: A ordem do protocolo é obrigatória
    Quando o commitment é produzido
    Então a sequência registrada é congelar, snapshot, raiz, carimbo, publicar
    E o carimbo tem horário anterior ao da extração oficial

  @BR-091
  Cenário: Falha ao carimbar bloqueia e alerta
    Dado que a ACT está indisponível
    Quando o carimbo é solicitado
    Então o commitment NÃO é publicado
    E um alerta de severidade crítica é emitido
    E o operador vê o estado bloqueado na tela de apurações

  @BR-033 @BR-034
  Cenário: Campanha sem vendas publica commitment da lista vazia
    Dado uma campanha sem nenhum pedido pago no congelamento
    Quando o congelamento ocorre
    Então a campanha vai para "CANCELADA_SEM_VENDAS"
    E o commitment da lista vazia é publicado assim mesmo
    E nenhuma apuração entre números não vendidos é possível
