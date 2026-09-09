---
id: risks
etapa: 3
data: 2026-09-08
status: done
fonte: PRD §8 + análise do plano
---

# RISKS — Dream RI

Escala: **P** probabilidade (1–5) · **I** impacto (1–5) · **E** exposição = P×I.
Risco com E ≥ 12 exige mitigação **antes** do épico que o carrega.

---

## Riscos de produto

### RSK-01 — O comprador não se importa com verificabilidade · P3 I5 **E15**

A tese inteira assume que a prova tem valor percebido. Se o comprador só quer o prêmio, o
diferencial vira custo de engenharia sem retorno comercial.

**Sinal antecipado:** verificações < 5% dos compradores em D+7.
**Mitigação:** não tentar educá-lo — fazer o **operador** ser o vendedor da prova. O link do
verificador é material de marketing dele, não feature nossa.
**Plano B:** se o sinal vier, o produto continua vendável como "rifa que não dá problema com o
órgão" (R8, R9.4) — valor para P1 mesmo sem P2 perceber.

### RSK-02 — Loja rejeita app de sorteio · P3 I4 **E12**

Apple e Google restringem apps de sorteio; costumam exigir comprovação de conformidade legal.

**Mitigação já no plano:** web mobile-first paritária (RNF-16) é caminho de compra que **não**
depende de aprovação. O PRD §10 diz explicitamente que a publicação da campanha real não espera
a loja.
**Custo se ocorrer:** um ciclo de resposta na semana 6 — a folga nomeada tem esse dono provável.

---

## Riscos técnicos

### RSK-03 — Alocação concorrente entrega número duplicado · P2 I5 **E10**

Dois compradores recebendo o mesmo número destrói a credibilidade de forma irrecuperável.

**Mitigação:** `SKIP LOCKED` sobre tabela pré-embaralhada (SPEC §4) + teste de concorrência
escrito **antes** do alocador e rodado contra implementação ingênua para provar que falha.
**Vigiar:** teste de corrida que nunca falhou pode estar testando serialização acidental.

### RSK-04 — Fonte da Loteria Federal indisponível no dia · P4 I4 **E16** ⚠️

A fonte é externa e não temos SLA sobre ela.

**Mitigação:** cascata primária → secundária → `FonteManualAssistida` com dois responsáveis e
registro em `extracao_tentativa`. **Resultado sintético é proibido por construção.**
**Aceite residual:** a apuração pode atrasar. Atrasar é aceitável; inventar não é.

### RSK-05 — Carimbo do tempo falha no momento do commitment · P2 I5 **E10**

Sem carimbo não há prova de anterioridade — a tese cai naquela campanha.

**Mitigação:** alerta crítico (SPEC §10); congelamento não avança sem carimbo confirmado.
**Pendência:** contratar a ACT é marco duro D+7, **sem plano B**.

### RSK-06 — Webhook do PicPay não é assinado · P5 I4 **E20** ⚠️⚠️

Qualquer um que descubra a URL pode forjar confirmação de pagamento.

**Mitigação (SPEC §7):** o corpo do webhook nunca é fonte de verdade para valor — ao receber
`PAID`, o worker **consulta a API** do PSP. A idempotência usa `(provedor, evento_id)`.
**Este é o risco de maior exposição do projeto** e a mitigação é arquitetural, não configurável.

### RSK-07 — Migration crítica não aplicada em produção · P3 I4 **E12**

Padrão já observado em outro projeto da casa: erro 500 com três causas empilhadas, uma delas
migration ausente.

**Mitigação:** CI aplica `migrate deploy` antes do smoke; `release/SMOKE_TESTS.md` verifica
schema esperado.

---

## Riscos de dados e compliance

### RSK-08 — Vazamento do banco expõe CPFs · P2 I5 **E10**

**Mitigação:** PII cifrada sob DEK por titular; `cpf_indice` em Argon2id com salt por tenant
(ADR-22). Enumeração em massa inviável mesmo com dump + salt.
**Residual assumido:** confirmação pontual de um CPF já conhecido continua possível.

### RSK-09 — Shredding quebra a cadeia de auditoria · P2 I5 **E10**

**Mitigação:** o hash encadeia o registro **cifrado**; teste `crypto-shredding` no CI valida a
cadeia antes e depois de apagar a chave.

### RSK-10 — Campanha publicada sem autorização válida · P2 I5 **E10**

Expõe operador e plataforma a sanção do órgão.

**Mitigação:** guarda na publicação (R8); autorização com validade e alerta em < 7 dias.

---

## Riscos de cronograma

### RSK-11 — Marcos duros D+7 não cumpridos · P3 I5 **E15** ⚠️

PicPay, ACT e contas de loja. **Nenhum é acelerável por IA** — são espera por terceiro.

**Mitigação:** o PRD já os declara como marcos que **param** o cronograma. A ação é iniciá-los
em D0, não em D+5.
**Estado hoje:** todos os três **em aberto** (pendências 3–5 do [INDEX](INDEX.md)).

### RSK-12 — Gerador e verificador compartilham o ponto cego · P4 I4 **E16** ⚠️

Todo o código é assistido por IA. Quando a mesma sessão escreve implementação e teste, o teste
passa porque testa o que o autor pensou.

**Mitigação (SPEC §11):** em R2, R4 e R6 — vetores externos (RFC 6962, RFC 3161), teste de
concorrência antes da implementação, revisão humana da **invariante**, e comparação com
implementação de referência independente.

---

## Mapa de calor

| E | Riscos |
|---|---|
| **20** | RSK-06 |
| **16** | RSK-04, RSK-12 |
| **15** | RSK-01, RSK-11 |
| **12** | RSK-02, RSK-07 |
| **10** | RSK-03, RSK-05, RSK-08, RSK-09, RSK-10 |

**Os cinco de maior exposição têm algo em comum:** quatro deles (06, 04, 11, 12) dependem de algo
fora do nosso controle — provedor, fonte oficial, terceiro, ou o próprio limite da assistência de
IA. Só RSK-01 é hipótese de produto. Isso diz onde a atenção de gestão deve estar: **não** na
engenharia, que está desenhada, mas nas dependências externas.
