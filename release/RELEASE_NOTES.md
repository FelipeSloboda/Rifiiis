---
id: release-notes
etapa: 13
data: 2026-09-08
status: planned
---

# CHANGELOG — Dream RI

Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento semântico.

> **Estado: gabarito.** Não há release. O produto não tem código ainda. Este arquivo define o
> formato e as regras; a primeira entrada real será escrita pelo `release-notes` (Etapa 17) a
> partir dos commits e do PR.
>
> Um changelog descrevendo uma release que não houve não é adiantamento de trabalho — é dívida.
> Ver [DECISION_LOG D3](../DECISION_LOG.md).

---

## [Não lançado]

Nada lançado. O plano de execução está em [EXECUTION_PLAN.md](../EXECUTION_PLAN.md).

---

## Formato de cada entrada

```markdown
## [1.0.0] — AAAA-MM-DD

### Added
- Descrição do que o usuário passa a poder fazer (DRI-###)

### Changed
- Mudança de comportamento existente (DRI-###)

### Fixed
- Defeito corrigido, com o sintoma que o usuário via (DRI-###)

### Removed
- O que saiu

### ⚠ BREAKING
- Mudança incompatível, com o caminho de migração
```

## Regras deste projeto

| Regra | Motivo |
|---|---|
| Toda entrada cita a issue `DRI-###` | Rastreabilidade até o requisito |
| Descrever o **efeito para o usuário**, não a implementação | "Corrige NPE no service" não diz nada a quem lê |
| **⚠ BREAKING para qualquer mudança de contrato não-aditiva** | O app na loja pode estar em versão antiga por dias |
| Mudança em R2, R4 ou R6 é destacada | São os três onde o erro é silencioso |
| Retificação de apuração **nunca** entra só aqui | Ela é pública na própria campanha |
