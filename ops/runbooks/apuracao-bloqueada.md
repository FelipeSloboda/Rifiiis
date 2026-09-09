# RUNBOOK — Apuração bloqueada

**Sintoma:** a tela de apurações mostra `BLOQUEADA`; nenhum resultado publicado.
**Severidade:** crítica se no dia da extração.

## O que aconteceu

As duas fontes da extração falharam. O sistema **bloqueou de propósito** — não existe caminho de
código que produza resultado sintético.

## Diagnóstico

1. Abra `07-apuracoes-admin` → histórico de tentativas.
2. Leia `fonte` e `resultado` de cada uma:

| Resultado | Significado |
|---|---|
| `timeout` | Fonte não respondeu a tempo |
| `erro` | Respondeu com erro ou formato inesperado |
| `divergente` | As duas fontes discordaram — **não faça entrada manual sem investigar** |

## Ação

### Caso A — timeout/erro nas duas
1. Verifique se a extração **realmente saiu** no site da CAIXA.
2. Se saiu: **Reprocessar**. Costuma resolver (indisponibilidade temporária).
3. Se não saiu: aguarde. O sistema tenta de novo.

### Caso B — reprocesso falhou e a extração existe
Entrada manual assistida:
1. Responsável 1 informa os números da extração oficial.
2. **Responsável 2, pessoa diferente**, confere na fonte oficial e confirma.
3. A apuração roda.

> A mesma pessoa nas duas etapas é recusada pelo sistema. O controle existe contra erro de
> digitação **e** contra ação unilateral — duas confirmações do mesmo humano não protegem de
> nenhum dos dois.

### Caso C — `divergente`
**Não faça entrada manual.** Duas fontes discordando significa que uma está errada. Confira na
CAIXA qual corresponde à data da campanha antes de qualquer ação.

## O que NÃO fazer

- ❌ Inventar ou "estimar" a extração
- ❌ Usar extração de outra data
- ❌ Fazer as duas confirmações com a mesma pessoa em contas diferentes
- ❌ Prometer resultado a comprador antes de apurar

## Comunicação

A página pública já mostra que a apuração aguarda o resultado oficial (R9.6). Não é preciso
anunciar nada — mas se perguntarem, a resposta é: *o sistema não publica resultado sem a extração
oficial.*
