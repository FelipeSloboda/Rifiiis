---
id: task-authoring-rules
etapa: 10
data: 2026-09-08
status: done
---

# REGRAS DE AUTORIA DE TASK — Dream RI

Toda issue tem **três blocos obrigatórios**. Falta de qualquer um reprova no `po-reviewer`.

## Bloco 1 — Contexto (por que existe)

- Requisito (`R##`) e story (`US-NNN`) que a task realiza
- Link para o `.feature` correspondente
- Regras de negócio (`BR-NNN`) que ela precisa respeitar
- Tela do protótipo, ou marcação explícita de backend-only

## Bloco 2 — Escopo (o que fazer)

- Lista do que entra
- **Lista do que NÃO entra** — mais importante que a primeira
- Arquivos/módulos prováveis
- Dependência de outras tasks

## Bloco 3 — Pronto quando (como saber que acabou)

- Cenários do `.feature` que devem passar, nomeados
- Gates aplicáveis da [DoD](requirements/DOR_DOD.md)
- Evidência esperada (saída de teste, screenshot, payload)

---

## Regras específicas deste projeto

### Se toca R2, R4 ou R6

O bloco 3 **precisa nomear a fonte externa dos vetores** (RFC 6962, RFC 3161, RFC 9106). Task
desses requisitos sem fonte externa nomeada é reprovada — ADR-012.

### Se toca alocação

O bloco 3 precisa incluir: *"o teste de concorrência falha contra a implementação ingênua"*. Não
basta passar contra a implementação boa.

### Se toca PII

O bloco 1 precisa apontar o campo no inventário da SPEC §9, e o bloco 3 precisa incluir o teste
`crypto-shredding` continuando verde.

### Se toca contrato de API

O bloco 2 precisa dizer se a mudança é **aditiva**. Se não for, exige ADR — o app na loja pode
estar em versão antiga por dias.

### Se toca schema

O bloco 3 precisa incluir: *"migration aplicada em banco limpo, do zero"*.

---

## O antipadrão que esta página existe para evitar

> **"Implementar a alocação de números."**

Sem cenário nomeado, sem o que não entra, sem como saber que acabou. Uma task assim termina
quando o autor cansa, não quando o requisito é atendido — e a diferença só aparece em produção.

## Modelo mínimo

```markdown
## Contexto
Realiza R2 / US-024. Cenários: `cenarios/R02-alocacao-atomica.feature`.
Regras: BR-042, BR-043, BR-048. Backend-only.

## Escopo
Entra: alocador com SKIP LOCKED sobre índice parcial; liberação em falha.
NÃO entra: geração do estoque (task 17), expiração (task 19).
Depende de: task 16 (teste de concorrência) e 17 (geração).

## Pronto quando
- [ ] Cenários "Cem pedidos concorrentes não colidem" e "Linha travada não bloqueia o lote" passam
- [ ] O cenário "A implementação ingênua falha o mesmo teste" **falha** contra a versão ingênua
- [ ] Cobertura do domínio tocado: 100%
- [ ] `perf-auditor` dentro do budget de latência
```
