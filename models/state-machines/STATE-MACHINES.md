---
id: state-machines
etapa: 6
data: 2026-09-08
status: done
fonte: SPEC §5
---

# MÁQUINAS DE ESTADO — Dream RI

## 1. Pedido

```mermaid
stateDiagram-v2
    [*] --> AGUARDANDO_PAGAMENTO: criar pedido (números reservados)
    AGUARDANDO_PAGAMENTO --> PAGO: pagamento confirmado na API do PSP
    AGUARDANDO_PAGAMENTO --> EXPIRADO: TTL vencido E PSP confirma não pago
    PAGO --> ESTORNO_PENDENTE: sem estoque / campanha congelada
    ESTORNO_PENDENTE --> ESTORNADO: estorno confirmado pelo PSP
    ESTORNO_PENDENTE --> ESTORNO_PENDENTE: retry após falha de saldo
    EXPIRADO --> [*]
    ESTORNADO --> [*]
    PAGO --> [*]: campanha encerrada
```

### A transição que não existe, e por quê

**`PAGO → ESTORNADO` direto não existe.** O estorno é uma operação no PSP que **pode falhar por
saldo** — a conta é do operador, e ela pode estar vazia. Ir direto de `PAGO` para `ESTORNADO`
declararia devolvido um dinheiro que continua com o operador.

`ESTORNO_PENDENTE` existe para que o sistema **não minta**. O comprador vê "devolução em
andamento", o operador vê a fila com o total devido, e o retry acontece quando o saldo permitir.

### Invariantes

| Invariante | Onde é garantida |
|---|---|
| Números só ficam definitivos em `PAGO` | Agregado `Pedido` |
| `EXPIRADO` exige consulta ao PSP antes | Worker de expiração (BR-046) |
| Pagamento após congelamento nunca chega a `PAGO` | Guarda no agregado (BR-032) |
| Toda transição vai para auditoria | Evento de domínio via outbox |

---

## 2. Campanha

```mermaid
stateDiagram-v2
    [*] --> RASCUNHO: criar
    RASCUNHO --> PUBLICADA: publicar (conta verificada + autorização + regulamento)
    PUBLICADA --> CONGELADA: T-2h da extração
    CONGELADA --> APURADA: extração obtida + regra aplicada
    CONGELADA --> CANCELADA_SEM_VENDAS: nenhum pedido pago
    APURADA --> ENCERRADA: entrega registrada e confirmada
    APURADA --> APURADA: retificação (causa fechada + dupla autorização)
    CANCELADA_SEM_VENDAS --> [*]
    ENCERRADA --> [*]
```

### Por que `APURADA → APURADA`

A retificação **não cria um estado novo**. A apuração original é preservada e continua pública;
a retificada passa a ser a vigente. Modelar a retificação como estado separado sugeriria que o
resultado anterior deixou de existir — e o ponto de ADR-13 é exatamente que ele não deixa.

### Guardas de publicação (o portão)

Publicar é o único ponto onde compliance é verificado. Depois disso a campanha é vendável.

| Guarda | Regra |
|---|---|
| Conta de recebimento verificada | BR-024, BR-144 |
| Autorização com validade futura | BR-025 |
| Regulamento versionado | BR-026 |
| Total de números entre 100 e 1M | BR-020 |

---

## 3. Apuração

```mermaid
stateDiagram-v2
    [*] --> AGUARDANDO: campanha congelada, commitment carimbado
    AGUARDANDO --> OBTENDO: dia da extração
    OBTENDO --> CONCLUIDA: fonte primária ou secundária responde
    OBTENDO --> BLOQUEADA: ambas as fontes falham
    BLOQUEADA --> AGUARDANDO_2O_RESPONSAVEL: entrada manual submetida
    AGUARDANDO_2O_RESPONSAVEL --> CONCLUIDA: segundo operador distinto confirma
    AGUARDANDO_2O_RESPONSAVEL --> BLOQUEADA: confirmação recusada
    BLOQUEADA --> OBTENDO: reprocessar
    CONCLUIDA --> RETIFICADA: causa fechada + dupla autorização
```

**O estado que salva o produto:** `BLOQUEADA`. Sem ele, a única alternativa a "fonte caiu" seria
inventar um resultado. Bloquear é feio, visível e correto — e é por isso que R9.6 dá a ele uma
tela pública.

---

## 4. Número da sorte

```mermaid
stateDiagram-v2
    [*] --> DISPONIVEL: estoque gerado (pré-embaralhado)
    DISPONIVEL --> RESERVADO: alocação com SKIP LOCKED
    RESERVADO --> PAGO: pedido confirmado
    RESERVADO --> DISPONIVEL: reserva expirada (após consultar PSP)
    PAGO --> [*]
```

**Invariante crítica (BR-043):** dois pedidos concorrentes nunca recebem o mesmo número. A
garantia é `SKIP LOCKED` sobre índice parcial de `DISPONIVEL`, não lock otimista nem retry.

---

## 5. Entrega do prêmio

```mermaid
stateDiagram-v2
    [*] --> PENDENTE: apuração concluída
    PENDENTE --> REGISTRADA: operador registra com comprovante
    REGISTRADA --> CONFIRMADA: ganhador confirma recebimento
    PENDENTE --> ATRASADA: prazo limite vencido
    ATRASADA --> REGISTRADA: operador registra
```

O estado `CONFIRMADA` sobrevive ao crypto-shredding: `numero_apurado`, datas e status continuam
públicos; a identificação do ganhador fica ilegível (BR-115). É o que concilia LGPD com R8.5.
