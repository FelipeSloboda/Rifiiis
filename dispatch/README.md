# DISPATCH

Briefs, revisões e conclusões por ticket:

| Arquivo | Quando |
|---|---|
| `<DRI-###>.brief.md` | Antes de começar — contexto para quem vai executar |
| `<DRI-###>.review.md` | Após a revisão |
| `<DRI-###>.done.md` | Ao fechar — evidências e o que mudou |

> **Estado: vazio.** Nenhum ticket despachado; o board `DRI` não existe.

## Brief mínimo

```markdown
# DRI-### · <título>

**Requisito:** R## · **Cenário:** cenarios/R##-*.feature
**Épico:** E0N · **Depende de:** DRI-###

## Contexto que não está no ticket
## Armadilhas conhecidas
## Como validar
```

## Quando o brief importa mais

Tickets com label `critico` (R2, R4, R6). Neles o brief precisa nomear a **fonte externa dos
vetores** e a **invariante** que a revisão vai checar — sem isso o executor descobre tarde demais
que o teste que escreveu não vale.
