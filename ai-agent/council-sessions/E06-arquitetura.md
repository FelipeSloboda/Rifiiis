---
id: council-e06
etapa: 6
data: 2026-09-08
status: planned
---

# COUNCIL — Arquitetura (Etapa 6)

> **Estado: pauta, não ata.** A sessão **não rodou**. O perfil full exige 6 especialistas na
> etapa de arquitetura; este arquivo define a pauta e as perguntas que precisam de resposta.
> Preencher com as respostas reais quando a sessão acontecer.

## Composição prevista

| Especialista | Traz |
|---|---|
| `arquitetura-software` | Fronteiras de BC, portas e adapters |
| `seguranca-appsec` | STRIDE, cripto, OWASP |
| `juridico-contratos` | LGPD, base legal, retenção |
| `qa-testes` | Testabilidade, dados sintéticos |
| `dados-postgres` | Concorrência, índices, particionamento |
| `mobile-expo` | Superfície do app e política de lojas |

> Os slugs precisam ser confirmados via `rag_list_specialists` — o snapshot D0 não foi tirado
> (G-18).

## Pauta — as perguntas que precisam de resposta

### 1. A cascata de fontes tem um degrau indefinido
**G-15:** a fonte secundária da Federal não tem nome. Qual é? Ela publica no mesmo formato? Tem
disponibilidade melhor ou pior que a primária?
**Se a resposta for "não existe segunda fonte confiável"**, a cascata é de dois degraus e o
`FonteManualAssistida` vira muito mais provável do que o plano assume.

### 2. O pool de Argon2id na fase 2
**G-13:** 1M de folhas × 64 MiB. Quantos workers? Quanta RAM na máquina do congelamento? O
congelamento é T-2h — cabe na janela?

### 3. Uma única ACT é aceitável?
**G-09:** não há plano B para o carimbo. Contratar uma segunda ACT resolve, ou o custo não
justifica? Qual o SLA real da primeira?

### 4. `numero_sorte` sem particionamento
ADR-014 adia o particionamento com critério medido. O critério está certo? 1M linhas por campanha
com churn de reservas — `fillfactor` e autovacuum bastam?

### 5. Porta de entrada para o direito de exclusão
**G-06:** o mecanismo existe (crypto-shredding), o caminho para o titular *pedir* não. Tela,
e-mail, canal? Qual o prazo de atendimento?

### 6. O que acontece com backups anteriores ao shredding
**CH-07:** o teste roda em banco novo, nunca contra restore. Um PITR anterior ao shredding
ressuscita a PII. Como se resolve — retenção curta de backup, re-shredding pós-restore, ou aceite
documentado?

## Formato da ata

Cada pergunta fecha com: decisão, alternativa recusada, quem discordou e por quê. Discordância
não registrada é decisão que será re-litigada em três semanas.
