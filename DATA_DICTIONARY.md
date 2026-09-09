---
id: data-dictionary
etapa: 8
data: 2026-09-08
status: done
fonte: SPEC §3
---

# DICIONÁRIO DE DADOS — Dream RI

Complementa o DDL da [SPEC §3](SPEC-TECNICA-plataforma-rifa-mvp.md), que é a fonte. Aqui está o
**significado** e a classificação de sensibilidade de cada campo que não é óbvio.

Sensibilidade: 🔴 PII cifrada · 🟠 pseudônimo · 🟡 dado operacional sensível · ⚪ público

---

## `operador`

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `email` | CITEXT | 🔴 | Único **entre não anonimizados** (índice parcial) |
| `senha_hash` | TEXT | 🟡 | Argon2id. Zerado na anonimização |
| `totp_secret_cifrado` | BYTEA | 🟡 | Cifrado sob chave externa; `NULL` até o 1º acesso |
| `bloqueado_ate` | TIMESTAMPTZ | ⚪ | Bloqueio temporário por tentativas |
| `desativado_em` | TIMESTAMPTZ | ⚪ | Desligamento. Revoga acesso, **não** apaga (ADR-026) |
| `anonimizado_em` | TIMESTAMPTZ | ⚪ | Eliminação por prazo. Exige `desativado_em` (CHECK) |

## `sessao`

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `segundo_fator_em` | TIMESTAMPTZ | ⚪ | **`NULL` = não autoriza rota admin.** O campo que ADR-015 tornou explícito |
| `ip` / `user_agent` | INET / TEXT | 🔴 | Expurgados em D+90 |
| `purgar_em` | TIMESTAMPTZ | ⚪ | Vencimento da retenção (default now + 90d) |
| `refresh_hash` | TEXT | 🟡 | Hash do refresh; reuso revoga a sessão |

## `comprador` — onde vive toda a PII do produto

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `nome_cifrado`, `cpf_cifrado`, `nascimento_cifrado`, `telefone_cifrado`, `email_cifrado` | BYTEA | 🔴 | AES-256-GCM sob a DEK do titular, nonce por campo |
| `chave_dek_cifrada` | BYTEA | 🔴 | **A chave do titular, embrulhada pela KEK externa. Apagar isto É o shredding** |
| `chave_apagada_em` | TIMESTAMPTZ | ⚪ | Carimbo do exercício do art. 18 |
| `cpf_indice` | BYTEA | 🟠 | `Argon2id(CPF, salt do tenant)`. **Sobrevive ao shredding** — sustenta limite e consulta |

> `CHECK ((chave_apagada_em IS NULL) = (chave_dek_cifrada IS NOT NULL))`: DEK apagada com PII
> presente é o estado esperado pós-shredding; o inverso é bug, e o banco recusa.

## `campanha`

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `total_numeros` | INTEGER | ⚪ | **100..1.000.000** — o `CHECK` é fonte única (ADR-011) |
| `limite_cents_por_cpf` | INTEGER | ⚪ | `NULL` = sem limite. Em centavos |
| `regra_apuracao` | JSONB | ⚪ | `{fonte, premios, digitos}`. **Imutável após publicar** |
| `autorizacao_numero/orgao/validade` | TEXT/DATE | 🟡 | Guarda de publicação; alerta a 7 dias do vencimento |
| `regulamento_versao` | INTEGER | ⚪ | Gravado no pedido — o comprador aceitou *aquela* versão |
| `congelada_em` | TIMESTAMPTZ | ⚪ | Marca T-2h; depois dela nada vira `PAGO` |

## `numero_sorte`

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `numero` | INTEGER | ⚪ | **Valor visível ao comprador** |
| `ordem` | INTEGER | 🟡 | **Posição pré-embaralhada de alocação.** Não publicar: revelaria a sequência futura |
| `reservado_ate` | TIMESTAMPTZ | ⚪ | TTL da reserva |

> A distinção `numero` × `ordem` é o coração do ADR-002: a aleatoriedade é resolvida **uma vez**,
> na geração, e a alocação vira leitura sequencial de índice.

## `pedido`

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `regulamento_versao` | INTEGER | ⚪ | Versão aceita **no momento da compra** |
| `psp_cobranca_id` | TEXT | 🟡 | Único quando não nulo; liga ao PSP |
| `pix_copia_cola` | TEXT | 🟡 | Payload EMV da cobrança |
| `valor_cents` | INTEGER | ⚪ | **Centavos.** Confirmado por reconsulta, não pelo webhook |

## `webhook_evento`

| Campo | Tipo | Sens. | Significado |
|---|---|:-:|---|
| `evento_id` | TEXT | ⚪ | Id do lado do PSP. `UNIQUE(provedor, evento_id)` **é** a idempotência |
| `payload` | JSONB | 🔴 | Bruto do PSP; **cifrado** — pode conter nome e CPF |

## `commitment`

| Campo | Sens. | Significado |
|---|:-:|---|
| `raiz` | ⚪ | Raiz Merkle em hex. **Pública** |
| `token_carimbo` | ⚪ | Token RFC 3161. Público e verificável por terceiro |
| `snapshot_sha256` | ⚪ | Integridade do arquivo no storage |
| `salt_campanha` | 🔴 | **Nunca publicado.** Sem ele o leaf seria força-brutável |

## `apuracao` / `extracao_tentativa`

| Campo | Sens. | Significado |
|---|:-:|---|
| `numero_apurado` | ⚪ | Público. **Sobrevive ao shredding** |
| `fonte` | ⚪ | `primaria` \| `secundaria` \| `manual` |
| `resultado` | ⚪ | `sucesso` \| `timeout` \| `erro` \| `divergente` |
| `operador_id` | 🟡 | **Só na entrada manual.** É a FK que impede apagar o operador |

## `entrega_premio`

| Campo | Sens. | Significado |
|---|:-:|---|
| `ganhador_cifrado` | 🔴 | Ilegível após shredding |
| `confirmado_ip_cifrado` | 🔴 | IP do aceite |
| `comprovante_uri` | 🟡 | Objeto cifrado; a URI vira referência morta após o shredding |
| `numero_apurado`, `prazo_limite`, status | ⚪ | **Preservados** — a prova de entrega sobrevive (BR-115) |

## `auditoria`

| Campo | Sens. | Significado |
|---|:-:|---|
| `dados` | 🔴 | Campos PII cifrados |
| `hash_anterior` / `hash` | ⚪ | **A cadeia encadeia o hash do registro cifrado.** Se fosse do texto claro, o shredding a quebraria |

---

## Convenções

| Convenção | Regra |
|---|---|
| Dinheiro | Inteiro em centavos, sufixo `_cents`. Nunca float |
| Tempo | `TIMESTAMPTZ` sempre; datas civis (extração) como `DATE` |
| Cifrado | Sufixo `_cifrado`, tipo `BYTEA` |
| Multi-tenant | `tenant_id` em toda tabela de negócio, desde o dia 1 (ADR-008) |
| Auditoria | Append-only. Nenhum `UPDATE`, nenhum `DELETE` |
