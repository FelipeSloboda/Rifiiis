# CENÁRIOS — fonte de verdade dos critérios de aceite

Um arquivo por requisito. **Estes arquivos vencem** sobre qualquer prosa de critério de aceite
em PRD, issue ou task: o `acceptance-validator` (Etapa 16 da esteira) cruza a saída real contra
os cenários daqui.

## Convenção

- Nome: `R<NN>-<slug>.feature` — o número casa com [CONVENCOES-IDS](../CONVENCOES-IDS.md).
- Tag `@P0`/`@P1` = prioridade · `@BR-NNN` = regra coberta · `@critico` = erro silencioso e caro.
- Cenário com `@critico` **não** pode ter vetor de teste gerado na mesma sessão que escreveu a
  implementação (SPEC §11).

## Índice

| Arquivo | Requisito | Cenários |
|---|---|---:|
| `R00-acesso-operador.feature` | R0 | 8 |
| `R00.5-provisionamento.feature` | R0.5 | 6 |
| `R01-campanha.feature` | R1 | 7 |
| `R02-alocacao-atomica.feature` | R2 | 8 |
| `R03-checkout-pix.feature` | R3 | 9 |
| `R04-commitment.feature` | R4 | 8 |
| `R05-comprovante.feature` | R5 | 6 |
| `R06-apuracao.feature` | R6 | 10 |
| `R07-cadastro-comprador.feature` | R7 | 5 |
| `R07.5-painel-comprador.feature` | R7.5 | 6 |
| `R08-compliance.feature` | R8 | 7 |
| `R08.5-entrega-premio.feature` | R8.5 | 6 |
| `R09.1-visao-geral.feature` | R9.1 | 4 |
| `R09.2-pedidos-admin.feature` | R9.2 | 5 |
| `R09.3-apuracoes-admin.feature` | R9.3 | 6 |
| `R09.4-relatorios.feature` | R9.4 | 4 |
| `R09.6-estados-excecao.feature` | R9.6 | 6 |
| `R10-conta-recebimento.feature` | R10 | 7 |
| `RNF-concorrencia.feature` | RNF-01, 02 | 5 |
| `RNF-lgpd.feature` | RNF-07, 10 | 7 |
| `RNF-seguranca.feature` | RNF-05, 06, 11, 12 | 6 |

**Total: 136 cenários em 21 arquivos.**
