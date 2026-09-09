---
id: environments
etapa: 9
data: 2026-09-08
status: done
---

# AMBIENTES — Dream RI

| Ambiente | Propósito | Dados | PSP | ACT | Federal |
|---|---|---|---|---|---|
| **Local** | Desenvolvimento | Sintéticos | Sandbox | Mock | Fixture gravada |
| **Preview** | Por PR | Sintéticos | Sandbox | Mock | Fixture |
| **Homologação** | Ensaio de apuração (marco D+21) | Sintéticos | Sandbox | **Real** | Real |
| **Produção** | Campanha real | Reais | Real | Real | Real |

## Por que homologação usa ACT e Federal reais

O marco D+21 é *apuração ensaiada com dados sintéticos e verificada por terceiro*. Um ensaio com
carimbo simulado não ensaia nada — o que precisa ser testado é justamente a integração com a
autoridade e a leitura da extração oficial. Os **dados** são sintéticos; as **provas** são reais.

## Infraestrutura

| Componente | Local | Produção |
|---|---|---|
| API + workers | Docker Compose | VPS com Caddy |
| Postgres | Container | Gerenciado, com PITR |
| Redis | Container | Gerenciado |
| Object storage | MinIO | S3-compatível **com object-lock** |

**Object-lock não é opcional em produção.** Sem ele o snapshot publicado poderia ser reescrito, e
a raiz carimbada apontaria para conteúdo mutável.

## Backup e recuperação

| Item | Estratégia | RPO | RTO |
|---|---|---|---|
| Postgres | PITR contínuo | < 5 min | < 1h |
| Snapshots | Object-lock + versionamento | 0 (imutável) | imediato |
| Tokens de carimbo | No banco + storage | < 5 min | < 1h |

> **O que não se recupera:** um carimbo não emitido. Se a ACT falhou e a extração já saiu, não
> há backup que resolva — a janela de anterioridade passou. Por isso o alerta é crítico e bloqueia.

## Isolamento

Nenhum ambiente não-produtivo acessa a KEK de produção. O teste de crypto-shredding usa chave de
teste — e é assim que ele consegue apagar chaves livremente no CI.
