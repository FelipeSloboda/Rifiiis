# DOCUMENTATION — por onde começar a ler

O [INDEX.md](INDEX.md) responde *o que falta*. Este responde *por onde eu começo*, conforme
quem você é.

---

## Sou novo no projeto — 20 minutos

1. [product/VISION.md](product/VISION.md) — o problema e a tese, em uma página.
2. [PRD §1–§4](PRD-plataforma-rifa-mvp.md) — problema, objetivos, não-objetivos, personas.
3. [SPEC §6](SPEC-TECNICA-plataforma-rifa-mvp.md) — o protocolo de apuração verificável. **É o
   produto.** Se você entender só uma coisa, entenda esta.
4. [prototipacao/hi-fi/index.html](prototipacao/hi-fi/index.html) — as 18 telas.

> Atalho honesto: a tese cabe numa frase — *o sorteio é verificável por um terceiro que não
> confia em ninguém*. Todo o resto é consequência disso.

---

## Vou implementar um ticket

1. [AI_WORKFLOW.md](AI_WORKFLOW.md) — a esteira de 20 etapas e os gates.
2. [cenarios/](cenarios/) — o `.feature` do requisito é o critério de aceite. **Não** o índice.
3. [SPEC §2–§5](SPEC-TECNICA-plataforma-rifa-mvp.md) — domínio, dados, alocação, máquina de estados.
4. [TASK_AUTHORING_RULES.md](TASK_AUTHORING_RULES.md) — os 3 blocos obrigatórios da task.

**Se o ticket toca R2, R4 ou R6**, leia antes a [SPEC §11 "Regra de verificação para código
assistido por IA"](SPEC-TECNICA-plataforma-rifa-mvp.md). São os três lugares onde o erro é
silencioso e destrói o produto.

---

## Vou revisar arquitetura

1. [models/c4/C1-CONTEXT.md](models/c4/C1-CONTEXT.md) → [C2](models/c4/C2-CONTAINERS.md) → [C3](models/c4/).
2. [adrs/](adrs/) — 26 decisões, cada uma com a alternativa recusada.
3. [security/THREAT_MODEL.md](security/THREAT_MODEL.md) — STRIDE por feature.
4. [models/state-machines/STATE-MACHINES.md](models/state-machines/STATE-MACHINES.md).

---

## Vou operar / vender

1. [go-to-market/ONE_PAGER.md](go-to-market/ONE_PAGER.md).
2. [client/ONBOARDING_CLIENTE.md](client/ONBOARDING_CLIENTE.md) — o que o operador precisa ter
   pronto **antes** da primeira campanha.
3. [ops/runbooks/](ops/runbooks/) — o que fazer quando a apuração trava, o webhook some ou o
   estorno falha.

---

## A ordem em que os documentos foram escritos

PRD → protótipo → SPEC → *plano full* (este conjunto). Isso importa: o plano é **derivado**, e
onde ele diverge do PRD/SPEC o defeito é dele — com a única exceção registrada em
[DECISION_LOG D1](DECISION_LOG.md).
