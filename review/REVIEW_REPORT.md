---
id: review-report
etapa: 11
data: 2026-09-08
status: planned
---

# RELATÓRIO DE REVISÃO — Dream RI

> **Estado: gabarito.** Não há código para revisar. Este arquivo define o formato; será preenchido
> pelo `code-reviewer` (Etapa 10) e pelas revisões de invariante.

## Formato de entrada

```markdown
## <data> · <DRI-###> · <épico>

**Escopo:** arquivos/módulos revisados
**Revisor:** agente ou pessoa

### Achados
| # | Severidade | Arquivo:linha | Achado | Ação |

### Revisão de invariante (obrigatória em R2/R4/R6)
**Invariante:** o predicado que precisa valer sempre
**Como foi verificada:** não é leitura de diff — é raciocínio sobre o predicado
**Conclusão:** mantida / violada
```

## A revisão que não é de código

Em R2, R4 e R6, a revisão **não é do diff** — é da invariante (ADR-012). A IA acerta a sintaxe do
lock e erra qual predicado precisa ser atômico. Um diff correto linha a linha pode violar a
invariante.

Perguntas da revisão de invariante:

| Requisito | Pergunta |
|---|---|
| R2 | Qual predicado precisa ser atômico, e ele está inteiramente dentro da transação? |
| R4 | O carimbo é emitido depois da raiz e antes da extração, sem caminho que inverta? |
| R6 | Existe algum caminho — qualquer um — em que um resultado seja produzido sem extração oficial? |

Um "não" mal fundamentado em qualquer dessas reprova, mesmo com todos os testes verdes.
