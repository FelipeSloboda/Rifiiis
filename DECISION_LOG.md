# DECISION LOG — Dream RI (DRI)

Decisões de **planejamento**. Decisões de **arquitetura** vivem em [adrs/](adrs/) e na
[SPEC §12](SPEC-TECNICA-plataforma-rifa-mvp.md). Uma decisão entra aqui quando muda o que
o plano promete, quem decide, ou o que é cortável.

---

## D0 — 2026-09-08 · Perfil full, a partir de PRD e SPEC já maduros

**Contexto.** Diferente de um bootstrap normal, este plano nasce *depois* do PRD (v1.6), da SPEC
(v1.6) e de 18 telas hi-fi. O trabalho não é descobrir o produto — é dar ao que já foi decidido
a estrutura operável pela esteira.

**Decisão.** Perfil **full**, com uma inversão de fluxo: em vez de gerar PRD/SPEC a partir de
templates, os artefatos do plano são **derivados** dos documentos existentes, que permanecem
como fonte. `PRD-plataforma-rifa-mvp.md` e `SPEC-TECNICA-plataforma-rifa-mvp.md` mantêm os nomes
originais em vez de virarem `PRD.md`/`SPEC.md` — renomear quebraria os links do espelho público
no `FelipeSloboda/Rifiiis`.

**Consequência.** Nenhum artefato derivado pode contradizer PRD ou SPEC. Onde contradiz, é
defeito do derivado — exceto onde este log registra correção explícita (ver D1).

---

## D1 — 2026-09-08 · Colisão de `R10` resolvida a favor do P0

**Contexto.** O PRD v1.6 §6 usa `R10` duas vezes: P0 "Conta de recebimento do operador" e P1
"Notificação WhatsApp". Rastreabilidade com chave duplicada produz matriz que mente.

**Decisão.** `R10` = conta de recebimento (P0). P1 renumerado para `R11..R14`, P2 para `R15..R20`.
De-para vinculante em [CONVENCOES-IDS §0](CONVENCOES-IDS.md).

**Por quê o P0 fica com o número.** Três amarras existentes contra zero: a lista "nunca cortar"
do PRD §10 cita `R10`; a SPEC referencia `R10` em §3, §7 e ADR-17; e a tela chama-se
`10-conta-recebimento`. Renumerar o P0 exigiria tocar em três documentos e um nome de arquivo.

**Consequência.** O PRD está **desatualizado** em relação ao plano até aplicar o de-para —
registrado como pendência 1 no [INDEX.md](INDEX.md). Enquanto isso, `CONVENCOES-IDS.md` vence.

---

## D2 — 2026-09-08 · Vocabulário `R##` preservado; `RF-NNN` recusado

**Contexto.** O molde `_template/` e os planos irmãos (`piscina-ia`, `d7`) usam `RF-NNN`.

**Decisão.** Manter `R##`. O molde é convenção da casa, não regra de arquitetura, e aqui ela
custaria mais do que entrega: PRD, SPEC, protótipo e a matriz §6.1 já compartilham `R##`. Uma
tradução `R3 → RF-012` criaria uma camada de indireção que ninguém usa para conversar.

**Consequência.** `CONVENCOES-IDS.md` documenta o desvio. Os `RNF-NN` são numeração **nova** —
não existiam no PRD, então nasceram já no padrão.

---

## D3 — 2026-09-08 · Artefatos de execução nascem como gabarito, não como ficção

**Contexto.** O perfil full pede `RELEASE_NOTES.md`, `run-logs/`, `dispatch/` e evidências de QA.
Nada disso aconteceu: não há repositório de código, board Jira nem uma linha escrita.

**Decisão.** Esses artefatos nascem com `status: planned` e descrevem **o que será registrado** —
estrutura, campos, critérios de preenchimento. Nenhum afirma execução.

**Por quê.** Um `RELEASE_NOTES.md` descrevendo uma release que não houve não é adiantamento de
trabalho, é dívida: quem lê acredita, e a correção custa mais que a omissão. A SPEC §11 já
combate a mesma classe de defeito ("a IA escreve; a aceitação vem de fonte que a IA não produziu").

---

## D5 — 2026-09-08 · D4 revogada: o plano full inteiro vai ao espelho público

**Contexto.** O D4 (abaixo) reteve `go-to-market/`, `MARKET.md` e `infra/COST_MODEL.md` do
espelho público por carregarem modelo de receita, estrutura de custo e posicionamento da bit4devs.

**Decisão do operador (2026-09-08):** publicar o plano **inteiro**, 98 arquivos, no
`FelipeSloboda/Rifiiis`.

**O que isso significa, dito claramente.** O repositório é público e o dono é outra pessoa. Ficam
visíveis a qualquer um, de forma permanente e indexável:

- o modelo de receita (licença/mensalidade) e a recusa consciente do percentual — Q5, ADR-017;
- a estrutura de custo, incluindo o carimbo por campanha como piso de precificação;
- o posicionamento contra os concorrentes nomeados em `MARKET.md`;
- o deck executivo com as perguntas difíceis e as respostas honestas.

Nada disso é segredo técnico nem credencial. É estratégia comercial — e a exposição é
consequência aceita, não descuido.

**Efeito no D4.** Revogado. Fica registrado abaixo com o raciocínio original, porque a decisão de
publicar só faz sentido para quem lê contra o que ela substituiu.

---

## D4 — 2026-09-08 · ~~O espelho público é do PRD/SPEC, não do plano~~ (revogada pelo D5)

**Contexto.** PRD, SPEC e protótipo estão em `FelipeSloboda/Rifiiis` (público). O plano full
inclui material comercial (`go-to-market/`, `MARKET.md`, `infra/COST_MODEL.md`).

**Decisão.** O espelho continua recebendo **apenas** PRD, SPEC e protótipo. O plano full fica no
`Wandersonla/squad`.

**Por quê.** `go-to-market/` e `COST_MODEL.md` carregam margem, custo e posicionamento da
bit4devs. Publicá-los num repositório cujo dono é outra pessoa entrega estratégia comercial sem
necessidade. A separação é deliberada e deve ser mantida em qualquer sincronização futura.
