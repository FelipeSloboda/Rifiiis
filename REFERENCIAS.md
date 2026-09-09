---
id: referencias
etapa: 3
data: 2026-09-08
status: done
---

# REFERÊNCIAS — Dream RI

Fontes normativas e técnicas. **Regra:** vetor de teste de cripto vem daqui, nunca de sessão de IA
(SPEC §11).

---

## Normas técnicas — vinculantes

| Ref | O que define | Onde o plano usa | Vetores de teste |
|---|---|---|---|
| **RFC 6962** | Certificate Transparency: árvore Merkle com separação de domínio (`0x00` folha, `0x01` interno) | SPEC §6 fase 3 | ✅ vetores publicados — usar |
| **RFC 3161** | Time-Stamp Protocol | SPEC §6 fase 4 | ✅ tokens de exemplo |
| **RFC 9106** | Argon2 — parâmetros recomendados | ADR-22, `cpf_indice`, leaf | ✅ vetores no apêndice |
| **RFC 6238** | TOTP | R0, segundo fator | ✅ vetores no apêndice |
| **RFC 7519** | JWT | Sessão do operador | — |

> A separação de domínio do RFC 6962 não é detalhe: sem o prefixo, um nó interno pode ser
> apresentado como folha (segunda pré-imagem). E nós ímpares são **promovidos**, não duplicados —
> duplicar abre ambiguidade de árvore.

---

## Legislação e regulação

| Ref | O que define | Onde incide |
|---|---|---|
| **Lei 13.709/2018 (LGPD)** | art. 7º V (execução de contrato), art. 12 §2º (pseudonimizado é PII), art. 16 (eliminação), art. 18 (direitos do titular) | SPEC §9, regime do operador e do comprador |
| **MP 2.200-2/2001** | ICP-Brasil; validade probatória de assinatura/carimbo | SPEC §6 — por que ACT credenciada e não blockchain |
| **Lei 5.768/1971 + Decreto 70.951/1972** | Distribuição gratuita de prêmios / autorização | R8, campo `autorizacao_*` |
| **Código Civil art. 206** | Prescrição de pretensão civil | Prazo de anonimização do operador (5 anos) |
| **Lei 8.078/1990 (CDC)** | Relação de consumo | Regulamento, direito de informação |

> **Não** é aconselhamento jurídico. O enquadramento da modalidade (rifa, sorteio filantrópico,
> promoção comercial) é do operador e do órgão — o sistema **exige** a autorização, não a julga.

---

## Padrões de mercado

| Ref | Uso |
|---|---|
| **OWASP Top 10 (2025)** | `security/THREAT_MODEL.md`, checklist por feature |
| **OWASP ASVS** | Nível 2 como alvo para o admin |
| **Keep a Changelog** | `release/RELEASE_NOTES.md` |
| **Conventional Commits** | Padrão de commit |
| **WCAG 2.2 AA** | RNF-09, `prototipacao/UX_REVIEW.md` |
| **C4 Model** | `models/c4/` |

---

## Documentação de fornecedor

| Fornecedor | O que consultar | Estado |
|---|---|---|
| **PicPay** | API de cobrança Pix, webhook, consulta de status | ⚠️ webhook **não assinado** — ver RSK-06 |
| **Loteria Federal / CAIXA** | Formato do resultado; fonte primária e secundária | Sem SLA — ver RSK-04 |
| **ACT (ICP-Brasil)** | Protocolo RFC 3161, cota de carimbos | ⚠️ não contratada |
| **Expo / EAS** | Build e submissão | Contas não abertas |
| **Apple / Google** | Política de apps de sorteio | ⚠️ ler **antes** de E09 |

---

## Documentos internos

| Doc | Papel |
|---|---|
| [PRD v1.6](PRD-plataforma-rifa-mvp.md) | Fonte de produto |
| [SPEC v1.6](SPEC-TECNICA-plataforma-rifa-mvp.md) | Fonte técnica |
| [prototipacao/DESIGN.md](prototipacao/DESIGN.md) | Tokens e padrões visuais |
| `plan-project/PADRAO_ESCRITA_JIRA.md` | Padrão de issue do workspace |
