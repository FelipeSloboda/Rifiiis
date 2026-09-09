---
id: threat-model
etapa: 6
data: 2026-09-08
status: done
metodo: STRIDE por feature
---

# THREAT MODEL — Dream RI

STRIDE por feature. **S**poofing · **T**ampering · **R**epudiation · **I**nformation disclosure ·
**D**enial of service · **E**levation of privilege.

Severidade: 🔴 crítica · 🟠 alta · 🟡 média · ⚪ baixa

---

## Fronteiras de confiança

| # | Fronteira | Confiança |
|---|---|---|
| TB-1 | Comprador → API pública | Nenhuma |
| TB-2 | **Webhook do PSP → API** | **Nenhuma — não assinado** |
| TB-3 | Operador → API admin | Autenticado, **mas é a parte auditada** |
| TB-4 | API → PSP / Federal / ACT | Terceiro, sem SLA |
| TB-5 | Auditor → artefato público | Anônimo por design |
| TB-6 | Worker → banco | Interna |

---

## F01 · Acesso do operador

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-001 | S | Credencial vazada dá acesso ao painel | 🔴 | TOTP obrigatório; login não emite sessão utilizável (ADR-15) | `R00` |
| TH-002 | S | Enumeração de e-mail cadastrado | 🟡 | Resposta idêntica para inexistente e senha errada (BR-004) | `R00` |
| TH-003 | S | Força bruta de senha | 🟠 | Bloqueio temporário por tentativas | `R00` |
| TH-004 | E | Bug de middleware libera admin com só a senha | 🔴 | Estado explícito na tabela, não só no middleware (ADR-15) | `R00` |
| TH-005 | T | Roubo de refresh token | 🟠 | Rotação; reuso revoga a sessão | `R00` |
| TH-006 | I | Segredo TOTP legível em dump | 🟠 | Coluna cifrada sob chave externa | `R00` |
| TH-007 | R | Operador nega ter autorizado apuração manual | 🔴 | Auditoria append-only + FK preservada (ADR-026) | `R00.5` |

## F02 · Campanha e conta de recebimento

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-010 | T | Publicar campanha sem autorização | 🔴 | Guarda na publicação (BR-025) | `R08` |
| TH-011 | T | Alterar preço/regra após publicar | 🔴 | Imutabilidade pós-publicação (BR-028) | `R01` |
| TH-012 | S | Cadastrar conta de recebimento de terceiro | 🟠 | Titularidade conferida contra CNPJ (BR-141) | `R10` |
| TH-013 | E | Trocar conta sem 2º fator | 🟠 | 2FA exigido na troca (BR-143) | `R10` |
| TH-014 | I | Vazar dados bancários do operador | 🟡 | Campos sensíveis cifrados | — |

## F03 · Alocação

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-020 | T | Dois compradores com o mesmo número | 🔴 | `SKIP LOCKED` + teste contra ingênua (ADR-003, ADR-012) | `R02` |
| TH-021 | D | Exaurir estoque com pedidos nunca pagos | 🟠 | TTL de reserva + rate limit | `R02` |
| TH-022 | D | Pico de expiração trava a alocação | 🟠 | Lotes de 5.000 com `SKIP LOCKED` | `R02` |
| TH-023 | T | Prever qual número virá | 🟡 | Pré-embaralhamento não publicado | — |

## F04 · Compra e pagamento

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-030 | S | **Webhook forjado confirma pagamento** | 🔴 | Reconsulta ao PSP (ADR-022) | `R03` |
| TH-031 | T | Webhook com valor adulterado | 🔴 | Valor vem da API, não do corpo | `R03` |
| TH-032 | T | Replay de webhook duplica números | 🟠 | Idempotência `(provedor, evento_id)` | `R03` |
| TH-033 | T | Replay de criação de pedido | 🟠 | `Idempotency-Key` com TTL 24h | `R03` |
| TH-034 | I | Payload do webhook com PII em claro | 🟠 | Cifrado na gravação | `R03` |
| TH-035 | D | Flood no checkout | 🟠 | Rate limit 10/min por IP | `RNF-seguranca` |
| TH-036 | R | Comprador nega ter aceitado o regulamento | 🟡 | Versão, timestamp e IP gravados | `R07` |

## F05 · Commitment e verificação

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-040 | T | **Editar a lista após conhecer o resultado** | 🔴 | Carimbo anterior à extração + object-lock | `R04` |
| TH-041 | T | Recarimbar com lista diferente | 🔴 | Um commitment por campanha (cardinalidade) | `R04` |
| TH-042 | T | Árvore ambígua por duplicação de nó | 🔴 | RFC 6962: promoção, não duplicação (ADR-004) | `R04` |
| TH-043 | T | Nó interno apresentado como folha | 🔴 | Separação de domínio `0x00`/`0x01` | `R04` |
| TH-044 | I | **Reidentificar comprador pelo snapshot público** | 🟠 | Argon2id com salt por campanha, nunca publicado (ADR-025) | `RNF-lgpd` |
| TH-045 | I | Cruzar snapshot público com a base | 🟠 | Salts distintos entre índice e leaf | `RNF-lgpd` |
| TH-046 | D | ACT indisponível impede o commitment | 🔴 | Alerta crítico; bloqueia. **Sem plano B** (G-09) | `R04` |

## F06 · Apuração e entrega

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-050 | T | **Resultado sintético quando as fontes caem** | 🔴 | Impossível por construção (SPEC §7) | `R06` |
| TH-051 | T | Entrada manual unilateral | 🔴 | Dois responsáveis distintos (ADR-016) | `R06` |
| TH-052 | T | Editar apuração publicada | 🔴 | Não existe rota nem caminho | `R06` |
| TH-053 | T | Retificação usada para trocar o ganhador | 🔴 | Causa fechada + dupla autorização + original preservada (ADR-013) | `R06` |
| TH-054 | R | Operador nega entrega não realizada | 🟠 | Confirmação do ganhador + comprovante | `R08.5` |
| TH-055 | T | Sortear entre números não vendidos | 🔴 | Proibido no domínio (BR-035) | `R06` |

## F07 · LGPD e compliance

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-060 | I | **Dump do banco expõe CPFs em massa** | 🔴 | Argon2id + salt por tenant (ADR-025) | `RNF-lgpd` |
| TH-061 | I | PII em log | 🟠 | Redator no transporte (BR-127) | `R08` |
| TH-062 | I | Sessão vira histórico de localização do operador | 🟡 | Expurgo de IP em D+90 (BR-013) | `RNF-lgpd` |
| TH-063 | T | Shredding quebra a cadeia de auditoria | 🔴 | Hash sobre registro cifrado; teste no CI | `RNF-lgpd` |
| TH-064 | T | **Fraudador apaga o próprio rastro** | 🔴 | Operador se anonimiza, não se apaga (ADR-026) | `R00.5` |
| TH-065 | I | Vazamento entre tenants | 🟠 | `tenant_id` no repositório, não só no guard (BR-019) | `RNF-seguranca` |

## F08 · Painel

| ID | STRIDE | Ameaça | Sev | Mitigação | Cenário |
|---|:-:|---|:-:|---|---|
| TH-070 | E | Operador A acessa campanha do tenant B | 🔴 | 404 sem revelar existência | `RNF-seguranca` |
| TH-071 | I | Exportação leva PII além do necessário | 🟡 | Mínimo necessário à prestação de contas | `R09.4` |
| TH-072 | I | CPF exposto na listagem | 🟡 | Mascarado por padrão; revelar é ação explícita | `R09.2` |

---

## Total: 45 ameaças

| Severidade | Qtd |
|---|---:|
| 🔴 Crítica | 22 |
| 🟠 Alta | 16 |
| 🟡 Média | 7 |

## As três que definem o produto

1. **TH-030 (webhook forjado)** — maior exposição do projeto. Mitigada por reconsulta ao PSP.
2. **TH-040 (editar a lista após o resultado)** — se essa passar, o produto não existe.
3. **TH-064 (fraudador apaga o rastro)** — a ameaça que transformou "direito ao esquecimento do
   operador" em anonimização com FK preservada.

## Ameaça aceita sem mitigação completa

**Confirmação pontual de CPF conhecido** (variação de TH-060): quem já sabe o CPF pode verificar
se ele está na base, ao custo de 50ms por tentativa. Nenhuma derivação protege contra isso. Risco
aceito e declarado em [ADR-025](../adrs/ADR-025-argon2id-cpf.md).
