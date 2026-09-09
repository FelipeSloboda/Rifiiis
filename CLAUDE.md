# CLAUDE.md — Dream RI (DRI)

Plano de projeto da plataforma de rifa verificável. **Fontes de verdade:**
[PRD](PRD-plataforma-rifa-mvp.md) v1.6 · [SPEC](SPEC-TECNICA-plataforma-rifa-mvp.md) v1.6 ·
[CONVENCOES-IDS.md](CONVENCOES-IDS.md).

## Regras deste plano

1. **PRD e SPEC vencem.** Todo artefato aqui é derivado. Contradição = defeito do derivado,
   salvo correção registrada no [DECISION_LOG](DECISION_LOG.md) (hoje: só a colisão do R10).
2. **IDs nascem em `CONVENCOES-IDS.md`**, nunca direto no artefato que os usa.
3. **`R10` é conta de recebimento** (P0). A notificação WhatsApp é `R11`. O PRD ainda não
   reflete isso — ver pendência 1 no [INDEX](INDEX.md).
4. **Artefato de execução é gabarito** até a execução acontecer. Não escrever release notes de
   release que não houve.
5. **Nada de material comercial no espelho público** (`FelipeSloboda/Rifiiis`): lá vão só PRD,
   SPEC e protótipo. Ver D4.

## Padrão de engenharia

Vale o global da máquina (`~/.claude/CLAUDE.md`) mais, deste projeto:

- **Domínio sem I/O.** Agregados, VOs e políticas são puros — é o que sustenta os 100% de
  cobertura exigidos. Adapter não entra no domínio.
- **Nada de `any`.** Zod em todo boundary (SPEC §9).
- **Erro é classe específica com `cause`.** Nunca `catch` genérico.
- **PII nunca em log.** O redator é no transporte, não no call site.
- **Vetor de teste de cripto vem de fora** (RFC 6962, RFC 3161). Nunca gerado na mesma sessão
  que escreveu a implementação.

## Onde as coisas estão

| Preciso de… | Vá para |
|---|---|
| o que o produto faz | [PRD](PRD-plataforma-rifa-mvp.md) · [product/VISION.md](product/VISION.md) |
| como é construído | [SPEC](SPEC-TECNICA-plataforma-rifa-mvp.md) · [models/c4/](models/c4/) |
| critério de aceite | [cenarios/](cenarios/) — a fonte, não o índice |
| o que entra primeiro | [backlog/ROADMAP.md](backlog/ROADMAP.md) · [backlog/waves/WAVES.md](backlog/waves/WAVES.md) |
| como um ticket anda | [AI_WORKFLOW.md](AI_WORKFLOW.md) |
| como escrever a issue | [PADRAO_ESCRITA_JIRA.md](PADRAO_ESCRITA_JIRA.md) |
