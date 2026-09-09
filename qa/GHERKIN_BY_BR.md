---
id: gherkin-by-br
etapa: 12
data: 2026-09-08
status: done
---

# COBERTURA DE REGRAS POR CENÁRIO — Dream RI

Cruzamento inverso: cada `BR-NNN` e onde ela é verificada. Regra sem cenário é regra que ninguém
vai defender quando alguém a violar num refactor.

## Cobertas

| Faixa | Regras | Cenário principal | Cobertura |
|---|---|---|:-:|
| BR-001..019 Acesso | 19 | `R00`, `R00.5`, `R07.5` | ✅ |
| BR-020..039 Campanha | 20 | `R01`, `R04`, `R08` | ✅ |
| BR-040..050 Estoque | 11 | `R02` | ✅ |
| BR-060..073 Pedido | 14 | `R03` | ✅ |
| BR-080..093 Commitment | 14 | `R04`, `R05` | ✅ |
| BR-100..115 Apuração | 16 | `R06`, `R08.5` | ✅ |
| BR-120..129 LGPD | 10 | `RNF-lgpd`, `R08` | ✅ |
| BR-140..145 Conta | 6 | `R10` | ✅ |

## Regras sem cenário dedicado, e por quê

| Regra | Situação |
|---|---|
| BR-014 (auditoria de toda ação admin) | Verificada em `R00` e transversalmente; um cenário por ação seria ruído |
| BR-019 (tenant no repositório) | Em `RNF-seguranca`; é propriedade estrutural, testada por amostragem |
| BR-073 (outbox transacional) | Verificada por teste de integração, não por Gherkin — não há comportamento observável pelo usuário |
| BR-129 (métrica sem titular) | Verificada pelo `telemetry-checker`, não por cenário |

## As regras que mais precisam de defesa automatizada

Não são as mais complexas — são as que **um refactor bem-intencionado quebraria sem perceber**:

| Regra | O refactor perigoso |
|---|---|
| BR-084 (salts nunca iguais) | "Vamos unificar essa constante duplicada" |
| BR-046 (consultar PSP antes de expirar) | "Essa consulta está lenta, vamos remover" |
| BR-064 (webhook não é fonte de verdade) | "Já temos o valor no payload, por que consultar?" |
| BR-086 (promover nó ímpar, não duplicar) | "Duplicar é mais simples de entender" |
| BR-122 (hash sobre registro cifrado) | "Hash do texto claro é mais fácil de debugar" |

Cada uma dessas tem cenário `@critico` justamente porque a versão errada **parece mais razoável**
para quem não conhece o motivo.
