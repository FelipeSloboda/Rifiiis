# language: pt
@P0 @R9.4 @E08
Funcionalidade: Relatórios e exportação

  Cenário: Relatório de arrecadação por período
    Dado pedidos pagos em datas distintas
    Quando o operador gera o relatório de um período
    Então vê o total arrecadado no período

  Cenário: Exportação em planilha
    Quando o operador exporta em xlsx
    Então o arquivo contém os pedidos do período

  Cenário: Período sem dados mostra estado vazio
    Quando o período não tem pedidos
    Então a tela mostra estado vazio, não erro

  @BR-127
  Cenário: Exportação não vaza PII desnecessária
    Quando o relatório é gerado
    Então ele traz o mínimo de dado pessoal necessário à prestação de contas
