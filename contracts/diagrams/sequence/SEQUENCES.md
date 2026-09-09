---
id: sequences
etapa: 7
data: 2026-09-08
status: done
---

# SEQUÊNCIAS — Dream RI

## 1. Compra: do checkout ao número atribuído

```mermaid
sequenceDiagram
    autonumber
    participant C as Comprador
    participant API
    participant DB as Postgres
    participant PSP as PicPay
    participant W as Worker

    C->>API: POST /api/pedidos (Idempotency-Key)
    API->>DB: BEGIN
    API->>DB: SELECT ... FOR UPDATE SKIP LOCKED
    DB-->>API: N números
    API->>DB: reserva + cria pedido + outbox
    API->>DB: COMMIT
    API->>PSP: cria cobrança (recebedor = operador)
    PSP-->>API: copia-e-cola + QR
    API-->>C: pedido + Pix

    C->>PSP: paga
    PSP--)API: webhook PAID (NÃO assinado)
    API->>DB: grava webhook_evento (provedor, evento_id)
    API-->>PSP: 200 (rápido)

    W->>PSP: GET status da cobrança
    Note over W,PSP: ADR-022 — o valor vem daqui,<br/>nunca do corpo do webhook
    PSP-->>W: status + valor REAL
    W->>DB: pedido PAGO + números atribuídos
    W--)C: números disponíveis
```

**O passo que carrega o risco:** o webhook chega não assinado. A reconsulta ao PSP é o que impede
que um corpo forjado vire número entregue sem dinheiro (TH-030).

---

## 2. Commitment: a ordem que não pode inverter

```mermaid
sequenceDiagram
    autonumber
    participant W as Worker
    participant DB as Postgres
    participant S as Object storage
    participant ACT
    participant P as Página pública

    Note over W: T-2h da extração
    W->>DB: campanha → CONGELADA
    W->>DB: SELECT números PAGOS ordenados
    DB-->>W: lista
    W->>W: deriva Argon2id(cpf, salt_campanha) em pool
    W->>W: monta NDJSON + leaf por linha
    W->>S: grava snapshot (object-lock)
    W->>W: árvore Merkle RFC 6962
    W->>ACT: carimba a raiz (RFC 3161)
    alt ACT responde
        ACT-->>W: token
        W->>DB: commitment
        W->>P: publica raiz + total + autoridade + horário
    else ACT indisponível
        W->>DB: CarimboFalhou
        Note over W: ALERTA CRÍTICO — bloqueia.<br/>Sem plano B (G-09)
    end
```

**Por que a ordem importa:** carimbar **antes** de a extração existir é o que dá valor probatório.
Inverter qualquer passo destrói a tese.

---

## 3. Apuração: a cascata e o bloqueio

```mermaid
sequenceDiagram
    autonumber
    participant W as Worker
    participant F1 as Fonte primária
    participant F2 as Fonte secundária
    participant DB
    participant O as Operador

    W->>F1: obtém extração
    alt primária responde
        F1-->>W: extração
    else primária falha
        W->>DB: extracao_tentativa (timeout)
        W->>F2: obtém extração
        alt secundária responde
            F2-->>W: extração
        else ambas falham
            W->>DB: extracao_tentativa (erro)
            W->>DB: apuração BLOQUEADA
            W--)O: notifica
            Note over W: NENHUM resultado sintético.<br/>Não existe caminho de código (TH-050)
            O->>DB: entrada manual (responsável 1)
            O->>DB: confirmação (responsável 2 — DISTINTO)
        end
    end
    W->>W: aplica RegraDeApuracao (puro)
    W->>DB: GanhadorApurado + publica
```

---

## 4. Verificação pelo auditor — sem tocar em nós

```mermaid
sequenceDiagram
    autonumber
    participant A as Auditor
    participant P as Página pública
    participant S as Storage
    participant CAIXA as Loteria Federal

    A->>P: abre a campanha
    P-->>A: raiz, total de folhas, autoridade, horário
    A->>S: baixa snapshot.ndjson
    S-->>A: NDJSON
    A->>A: recomputa a raiz Merkle localmente
    A->>A: compara com a raiz carimbada
    A->>A: valida o token RFC 3161
    A->>CAIXA: consulta a extração oficial
    CAIXA-->>A: resultado
    A->>A: aplica a regra publicada
    Note over A: chega ao mesmo ganhador<br/>sem nenhuma interação conosco
```

**Este é o diagrama que define o produto.** Nenhuma seta aponta para a nossa API. Se alguma
apontasse, a verificação dependeria da nossa colaboração — e deixaria de ser verificação.

---

## 5. Expiração: por que consultar antes

```mermaid
sequenceDiagram
    autonumber
    participant W as Worker
    participant DB
    participant PSP

    loop a cada 30s
        W->>DB: SELECT reservas vencidas LIMIT 5000 SKIP LOCKED
        DB-->>W: lote
        loop cada pedido
            W->>PSP: status da cobrança
            alt não pago
                W->>DB: EXPIRADO + libera números
            else pago (tardio)
                W->>DB: PAGO + atribui
                Note over W: sem esta consulta,<br/>o pagamento tardio seria perdido
            end
        end
    end
```
