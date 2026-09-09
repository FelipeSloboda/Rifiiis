---
id: personas
etapa: 2
data: 2026-09-08
status: done
fonte: PRD §4
---

# PERSONAS — Dream RI

---

## P1 — Operador

**Quem é.** Organiza rifas com autorização do órgão competente. Pode ser pessoa jurídica pequena
ou associação. Vende principalmente por WhatsApp e Instagram.

**Contexto de uso.** Celular, na rua, entre outras tarefas. Usa o painel algumas vezes ao dia
durante a campanha e intensamente no dia da apuração.

**O que ele quer.** Vender e não ser acusado de fraude.

**A dor real.** Ele já perdeu venda porque alguém comentou "isso é golpe" num post. Não teve
como responder — o print que ele postou não prova nada, e ele sabe.

**O que o faz confiar.** Ver o carimbo do tempo emitido antes da extração e poder mandar o link
do verificador para o cliente que reclamou.

**O que o faz desistir.** Publicar campanha exigir 12 campos que ele não entende. Ou a apuração
travar sem dizer o que fazer.

**Frase que resume.** *"Eu preciso provar que sou honesto, não só ser."*

**Requisitos que existem por causa dele.** R0, R0.5, R1, R9.1–R9.6, R10.

---

## P2 — Comprador

**Quem é.** Compra 1 a 5 bilhetes por impulso, via link do WhatsApp. Faixa ampla; muitos com
pouca familiaridade digital.

**Contexto de uso.** Celular, conexão instável, quer terminar em menos de um minuto.

**O que ele quer.** O prêmio. Verificabilidade é bônus — **até** ele desconfiar.

**A dor real.** Pagou e não recebeu número. Ou recebeu e no dia do sorteio não achou o nome dele
em lugar nenhum.

**O que o faz confiar.** Receber o número na hora e um comprovante que ele consegue conferir sem
depender do operador.

**O que o faz desistir.** Cadastro longo antes de ver o preço. Pix que demora a confirmar sem
dizer nada.

**Frase que resume.** *"Como eu sei que meu número tava lá?"*

**Requisitos por causa dele.** R3, R5, R7, R7.5, R9.6.

> **Hipótese frágil, e assumida:** o comprador pode não se importar com a prova. Por isso o
> desenho não o obriga a entender nada — o comprovante verificável chega pronto, e verificar é
> opcional. Ver [RSK-01](../RISKS.md).

---

## P3 — Auditor / órgão autorizador

**Quem é.** Fiscal do órgão, jornalista, ou comprador desconfiado com conhecimento técnico.

**Contexto de uso.** Desktop, sem acesso ao sistema, possivelmente adversarial.

**O que ele quer.** Recomputar o resultado sozinho e chegar ao mesmo ganhador.

**A dor real.** Prestação de contas que chega como PDF sem como conferir.

**O que o faz confiar.** Dados públicos suficientes para recomputar: snapshot, raiz, carimbo,
regra e extração oficial.

**O que o faz rejeitar.** Precisar pedir qualquer coisa a nós. Se a verificação depende da nossa
colaboração, ela não é verificação.

**Frase que resume.** *"Me dá os dados que eu confiro por mim mesmo."*

**Requisitos por causa dele.** R4, R5, R6, R8.5.

---

## Não-personas

| Quem | Por que fora |
|---|---|
| Afiliado / revendedor | Split é P2 (R18) |
| Operador sem autorização | R8 bloqueia por construção |
| Menor de 18 | Bloqueado por compliance (R8) |
| Comprador internacional | Pix e CPF são pressupostos do MVP |

## O conflito que o design precisa segurar

P1 paga; P2 e P3 são protegidos **do** P1. Toda vez que um pedido do operador enfraquecer a
prova, o produto tem que dizer não — e a recusa precisa estar no código (guarda), não na
diplomacia do vendedor. Ver [STAKEHOLDER_MATRIX](../discovery/STAKEHOLDER_MATRIX.md).
