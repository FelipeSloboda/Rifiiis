---
id: dor-dod
etapa: 4
data: 2026-09-08
status: done
---

# DoR / DoD — Dream RI

## Definition of Ready — o ticket pode entrar em `em-dev`?

Verificado pelo `po-reviewer` (Etapa 1 da esteira). Qualquer ❌ devolve para refinamento.

- [ ] Tem linha na [TRACEABILITY_MATRIX](TRACEABILITY_MATRIX.md) (requisito ↔ story ↔ cenário)
- [ ] Os cenários Gherkin existem em [cenarios/](../cenarios/) e cobrem o caminho triste
- [ ] Classificação MoSCoW definida
- [ ] Regras de negócio (`BR-NNN`) aplicáveis estão listadas no corpo
- [ ] Tela do protótipo identificada (ou marcado explicitamente como backend-only)
- [ ] Dependências de outros épicos declaradas
- [ ] Se toca R2, R4 ou R6: **fonte externa dos vetores de teste nomeada**
- [ ] Se toca PII: campo mapeado no inventário da SPEC §9
- [ ] Estimativa em pontos
- [ ] DoD colada no corpo da issue

## Definition of Done — o ticket pode ir para `pronto-p-deploy`?

Verificado pelo `acceptance-validator` (Etapa 16) e pelo `release-manager` (Etapa 20).

### Código
- [ ] Todos os cenários do `.feature` passam
- [ ] Cobertura: > 90% global, **100% no domínio tocado**
- [ ] Sem `any`; erros são classes específicas com `cause`
- [ ] Zod em todo boundary novo
- [ ] `graphify update .` rodado se houve mudança estrutural

### Gates bloqueantes
- [ ] `code-reviewer` sem thread aberta
- [ ] `security-auditor` sem crítico nem alto
- [ ] `integration-tester` verde
- [ ] `perf-auditor` dentro do budget
- [ ] `a11y-auditor` sem violação critical/serious (ou `n/a` justificado)
- [ ] `e2e-web` / `e2e-mobile` verde (ou `n/a` justificado)

### Específicos deste produto
- [ ] Se toca alocação: teste de concorrência roda **e falha** contra implementação ingênua
- [ ] Se toca cripto: vetor externo (RFC 6962/3161/9106) usado, não gerado na sessão
- [ ] Se toca PII: teste `crypto-shredding` continua verde
- [ ] Se toca log: `telemetry-checker` confirma ausência de PII
- [ ] Se toca schema: migration aplicada em ambiente limpo, do zero

### Registro
- [ ] Evidências no Jira (`task-reporter`)
- [ ] CHANGELOG atualizado
- [ ] Docs impactadas atualizadas (`docs-updater`)

## O item que costuma ser pulado

**"Migration aplicada em ambiente limpo, do zero."** O padrão de falha já observado nesta casa:
migration que roda no banco de desenvolvimento (que tem estado acumulado) e falha em produção.
Aplicar do zero é o único teste que vale.
