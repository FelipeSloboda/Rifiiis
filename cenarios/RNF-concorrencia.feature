# language: pt
@P0 @RNF-01 @RNF-02 @E10 @critico
Funcionalidade: Concorrência e carga

  Cenário: 500 requisições por segundo no checkout por 60 segundos
    Quando a carga de 500 req/s roda por 60s
    Então a taxa de erro fica abaixo de 0,5%
    E nenhum número é atribuído em duplicidade

  Cenário: Alocação não degrada com estoque quase esgotado
    Dado uma campanha com 1% do estoque disponível
    Quando 100 pedidos concorrentes são criados
    Então a latência mediana permanece dentro do budget

  Cenário: Expiração em massa concorrente com alocação
    Dado 50000 reservas vencendo
    E alocação concorrente ativa
    Então ambas progridem sem deadlock

  Cenário: Construção da árvore de 1M de folhas
    Dado um snapshot de 1000000 de folhas
    Quando a árvore é construída
    Então a fase 3 termina em menos de 2 segundos

  Cenário: Derivação Argon2id do snapshot usa paralelismo
    Dado 1000000 de folhas a derivar
    Quando a fase 2 roda
    Então a derivação é distribuída em pool de workers
