# RUNBOOK — Falha ao carimbar o commitment

**Sintoma:** alerta crítico `CarimboFalhou`; campanha congelada sem commitment publicado.
**Severidade:** **crítica.** Sem carimbo, a campanha perde a prova de anterioridade.

## Por que isto é o pior incidente do produto

O carimbo precisa ser emitido **antes** da extração. Essa janela é fixa e não se recupera: se ela
passar, nenhum backup, retry ou correção devolve a anterioridade.

A apuração **não roda** sem commitment — e está certo que não rode.

## Diagnóstico imediato

1. A ACT está no ar? (status do fornecedor)
2. A credencial está válida?
3. A cota de carimbos está esgotada?
4. Há erro de rede/TLS no log do worker?

## Ação por causa

| Causa | Ação | Prazo |
|---|---|---|
| Indisponibilidade momentânea | Retry manual | Imediato |
| Credencial vencida | Renovar e retentar | Horas |
| Cota esgotada | Contratar cota adicional | Horas |
| ACT fora do ar prolongado | **Escalar** — decisão de negócio | — |

## Se o carimbo não sair antes da extração

Não há solução técnica. As opções são de negócio, e todas ruins:

| Opção | Consequência |
|---|---|
| Adiar a apuração para a próxima extração | A campanha atrasa, mas **a prova se mantém** |
| Apurar sem commitment | ❌ **Não fazer.** Destrói a tese e engana o comprador |
| Cancelar e devolver | Último recurso; aciona estornos em massa |

**A primeira é quase sempre a certa.** A Federal tem extrações periódicas; adiar preserva a única
coisa que o produto vende.

## Prevenção

O smoke #22 (`release/SMOKE_TESTS.md`) manda emitir um carimbo de teste **antes** de publicar
qualquer campanha real. Custa centavos e é a única defesa real contra este incidente.

## Pós-incidente

Registre postmortem. Se a causa foi do fornecedor, avalie contratar uma segunda ACT — hoje o
projeto tem **uma só, sem plano B** (G-09), e este runbook existe por causa disso.
