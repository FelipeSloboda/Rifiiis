---
id: business-rules
etapa: 4
data: 2026-09-08
status: done
fonte: PRD §6 + SPEC §2-§9
---

# BUSINESS RULES — Dream RI

71 regras. Cada uma é **verificável** e tem cenário Gherkin correspondente em [cenarios/](../cenarios/).
Faixas em [CONVENCOES-IDS §5](../CONVENCOES-IDS.md).

Colunas: **ID · Regra · Onde vive (camada) · Requisito**

---

## BR-001..019 — Acesso, sessão e autorização

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-001 | Senha do operador é armazenada com Argon2id, nunca reversível | domínio | R0 |
| BR-002 | Login **não** emite sessão utilizável — devolve apenas desafio de 2º fator | aplicação | R0 |
| BR-003 | Nenhuma rota `/api/admin/*` responde sem `segundo_fator_em` preenchido | guard | R0 |
| BR-004 | Falha de login não distingue e-mail inexistente de senha errada | aplicação | R0 |
| BR-005 | Após N tentativas falhas, a conta é bloqueada temporariamente | domínio | R0 |
| BR-006 | Segredo TOTP é cifrado em coluna sob chave externa | infra | R0 |
| BR-007 | Código de recuperação é de uso único e armazenado como hash | domínio | R0.5 |
| BR-008 | Primeiro acesso obriga ativação de TOTP antes de qualquer ação | aplicação | R0.5 |
| BR-009 | Refresh token é rotativo; reuso de token antigo revoga a sessão | aplicação | R0 |
| BR-010 | Desativar operador revoga todas as sessões na mesma transação | domínio | R0.5 |
| BR-011 | Operador desativado não faz login, mas suas FKs permanecem íntegras | domínio | R0.5 |
| BR-012 | Anonimização de operador exige desativação prévia | banco (CHECK) | R0.5 |
| BR-013 | `ip` e `user_agent` de sessão são expurgados em D+90 | worker | RNF-10 |
| BR-014 | Toda ação administrativa é registrada em auditoria com o operador | domínio | R9 |
| BR-015 | Acesso do comprador é por código de uso único, sem senha | domínio | R7.5 |
| BR-016 | Código de acesso do comprador expira em 10 minutos | domínio | R7.5 |
| BR-017 | Código de acesso é armazenado como hash, nunca em claro | domínio | R7.5 |
| BR-018 | Sessão do comprador dura 30 dias | domínio | R7.5 |
| BR-019 | Toda escrita verifica `tenant_id` no repositório, não só no guard | repositório | RNF-11 |

## BR-020..039 — Campanha e publicação

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-020 | `total_numeros` entre 100 e 1.000.000 | banco (CHECK) | R1 |
| BR-021 | Preço do bilhete e números por bilhete são inteiros positivos | banco (CHECK) | R1 |
| BR-022 | `slug` é único por tenant | banco (UNIQUE) | R1 |
| BR-023 | Campanha nasce em `RASCUNHO` | domínio | R1 |
| BR-024 | Publicação exige conta de recebimento **verificada** | guarda | R10 |
| BR-025 | Publicação exige autorização com número, órgão e validade futura | guarda | R8 |
| BR-026 | Publicação exige regulamento versionado | guarda | R8 |
| BR-027 | Publicação dispara geração assíncrona do estoque | política | R2 |
| BR-028 | Campanha publicada não altera preço, total de números nem regra de apuração | domínio | R1 |
| BR-029 | Alerta quando a autorização vence em menos de 7 dias | observabilidade | R8 |
| BR-030 | Congelamento ocorre em T-2h da extração | política | R4 |
| BR-031 | Após congelar, criação de pedido retorna `CAMPANHA_CONGELADA` | aplicação | R4 |
| BR-032 | Após congelar, pedido pendente não pode virar `PAGO` — vai a estorno | domínio | R4 |
| BR-033 | Campanha sem vendas no congelamento vai para `CANCELADA_SEM_VENDAS` | domínio | R4 |
| BR-034 | Campanha cancelada sem vendas publica commitment da lista vazia | política | R4 |
| BR-035 | **Nunca** sortear entre números não vendidos | domínio | R6 |
| BR-036 | `regra_apuracao` é imutável após publicação | domínio | R6 |
| BR-037 | Limite por CPF, quando definido, é em centavos e verificado no pedido | domínio | R8 |
| BR-038 | Campanha exige aceite de 18+ do comprador | aplicação | R8 |
| BR-039 | Encerramento da campanha exige entrega registrada | domínio | R8.5 |

## BR-040..059 — Estoque, reserva e alocação

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-040 | Números são gerados `[0..N-1]` e embaralhados (Fisher-Yates) na publicação | domínio | R2 |
| BR-041 | `ordem` define a sequência de alocação; `numero` é o valor visível | domínio | R2 |
| BR-042 | Alocação usa `SKIP LOCKED` — linha travada vai para a próxima rodada | repositório | R2 |
| BR-043 | Dois pedidos concorrentes **nunca** recebem o mesmo número | invariante | R2 |
| BR-044 | Número tem exatamente um dos estados: `DISPONIVEL`, `RESERVADO`, `PAGO` | domínio | R2 |
| BR-045 | Reserva tem TTL; expirada volta a `DISPONIVEL` | worker | R3 |
| BR-046 | Worker de expiração consulta o PSP **antes** de expirar | worker | R3 |
| BR-047 | Expiração roda em lotes de 5.000 para não travar a alocação | worker | RNF-01 |
| BR-048 | Pedido sem estoque suficiente falha inteiro — nunca parcial | domínio | R2 |
| BR-049 | Falha por falta de estoque após pagamento aciona estorno | política | R3 |
| BR-050 | Índice de alocação é parcial: só `DISPONIVEL` entra | banco | RNF-01 |

## BR-060..079 — Pedido, pagamento e estorno

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-060 | Pedido nasce em `AGUARDANDO_PAGAMENTO` | domínio | R3 |
| BR-061 | `POST /api/pedidos` exige `Idempotency-Key`; retry devolve o mesmo pedido | aplicação | R3 |
| BR-062 | Chave de idempotência vive 24h em Redis | infra | R3 |
| BR-063 | Cobrança é emitida **sempre** com o operador como recebedor | domínio | R10 |
| BR-064 | O corpo do webhook **não** é fonte de verdade para valor pago | aplicação | R3 |
| BR-065 | Ao receber `PAID`, o worker consulta a API do PSP para confirmar | aplicação | R3 |
| BR-066 | Idempotência do webhook é `(provedor, evento_id)` | banco (UNIQUE) | RNF-08 |
| BR-067 | Webhook responde rápido; processamento é assíncrono | aplicação | R3 |
| BR-068 | Payload de webhook é cifrado na gravação (pode conter PII) | infra | RNF-06 |
| BR-069 | Transição `PAGO → ESTORNADO` passa por `ESTORNO_PENDENTE` | domínio | R3 |
| BR-070 | Estorno que falha por saldo entra em fila com retry e backoff | política | R10 |
| BR-071 | Estorno pendente é visível ao operador com o total devido | read model | R10 |
| BR-072 | Pagamento após o congelamento vai direto para estorno | domínio | R4 |
| BR-073 | Eventos de domínio são publicados via outbox transacional | infra | RNF-13 |

## BR-080..099 — Commitment e verificação

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-080 | Snapshot contém apenas números com pedido `PAGO`, ordenado crescente | domínio | R4 |
| BR-081 | Snapshot **não** contém CPF nem qualquer PII | domínio | RNF-06 |
| BR-082 | Leaf = `SHA256(0x00 ‖ numero_be32 ‖ Argon2id(cpf, salt_campanha) ‖ pedido_id ‖ pago_em)` | domínio | R5 |
| BR-083 | `salt_campanha` é gerado por campanha e **nunca** publicado | infra | R5 |
| BR-084 | `salt_campanha` ≠ `salt_cpf_tenant` — salts nunca são reusados | infra | ADR-22 |
| BR-085 | Árvore Merkle segue RFC 6962: folha `0x00`, interno `0x01` | domínio | R4 |
| BR-086 | Nó ímpar é promovido sem re-hash, nunca duplicado | domínio | R4 |
| BR-087 | Snapshot é gravado em storage com object-lock | infra | R4 |
| BR-088 | Raiz Merkle é carimbada por ACT credenciada (RFC 3161) | integração | R4 |
| BR-089 | Commitment é publicado com raiz, total de folhas, autoridade e horário | read model | R4 |
| BR-090 | Ordem obrigatória: congelar → snapshot → raiz → carimbo → publicar | política | R4 |
| BR-091 | Falha ao carimbar é alerta **crítico** e bloqueia o avanço | observabilidade | R4 |
| BR-092 | Comprovante do comprador traz o leaf e a prova de inclusão | read model | R5 |
| BR-093 | Verificador público funciona sem autenticação e sem contato conosco | aplicação | R5 |

## BR-100..119 — Apuração, retificação e entrega

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-100 | Extração vem da fonte primária; falhando, da secundária | integração | R6 |
| BR-101 | Falhando ambas, a apuração **bloqueia** e exige entrada manual | política | R6 |
| BR-102 | Entrada manual exige **dois responsáveis distintos** | guarda | R6 |
| BR-103 | Duas confirmações do mesmo humano são recusadas | guarda | R6 |
| BR-104 | Toda tentativa de obtenção é registrada em `extracao_tentativa` | domínio | R9.3 |
| BR-105 | **Não existe caminho de código que produza extração sintética** | arquitetura | R6 |
| BR-106 | Ganhador sai da regra publicada aplicada à extração oficial | domínio | R6 |
| BR-107 | Regra de aproximação tem casos degenerados definidos e testados | domínio | R6 |
| BR-108 | Apuração é irreversível; correção só por retificação | domínio | R6 |
| BR-109 | Retificação exige causa de lista fechada | guarda | R6 |
| BR-110 | Retificação exige dupla autorização | guarda | R6 |
| BR-111 | Retificação preserva a apuração original, publicamente | domínio | R6 |
| BR-112 | Entrega registra comprovante (documento/foto) cifrado | domínio | R8.5 |
| BR-113 | Ganhador confirma recebimento; IP do aceite é cifrado | domínio | R8.5 |
| BR-114 | Entrega tem prazo limite monitorado | read model | R8.5 |
| BR-115 | Após shredding, `numero_apurado`, datas e status da entrega permanecem legíveis | domínio | RNF-07 |

## BR-120..139 — Compliance e LGPD

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-120 | PII do comprador é cifrada sob DEK do próprio titular | infra | RNF-07 |
| BR-121 | Apagar a DEK torna a PII ilegível sem remover bytes | infra | RNF-07 |
| BR-122 | A cadeia de auditoria encadeia o hash do registro **cifrado** | domínio | RNF-07 |
| BR-123 | `cpf_indice` usa Argon2id com salt por tenant | infra | ADR-22 |
| BR-124 | `cpf_indice` sobrevive ao shredding — sustenta limite e consulta | domínio | R8 |
| BR-125 | Operador é anonimizado por prazo (art. 16), nunca apagado | worker | ADR-23 |
| BR-126 | Não existe rota de API que exclua operador | arquitetura | ADR-23 |
| BR-127 | Log nunca contém CPF, telefone ou e-mail — redator no transporte | infra | RNF-06 |
| BR-128 | Consentimento grava versão do termo, timestamp e IP | domínio | R8 |
| BR-129 | Métricas não segmentam por titular identificado | observabilidade | RNF-06 |

## BR-140..159 — Conta de recebimento

| ID | Regra | Camada | Req |
|---|---|---|---|
| BR-140 | Uma conta ativa por operador | banco (índice parcial) | R10 |
| BR-141 | Titularidade é conferida contra o CNPJ do organizador | integração | R10 |
| BR-142 | Conta de terceiro é **recusada** | guarda | R10 |
| BR-143 | Troca de conta exige segundo fator | guarda | R10 |
| BR-144 | Publicação é bloqueada sem conta verificada | guarda | R10 |
| BR-145 | A plataforma **nunca** custodia dinheiro de terceiro | arquitetura | ADR-17 |
