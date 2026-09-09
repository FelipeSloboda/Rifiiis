---
id: event-storming
etapa: 2
data: 2026-09-08
status: done
fonte: SPEC §2 (eventos de domínio), §5 (máquina de estados)
---

# EVENT STORMING — Dream RI

Legenda: 🟧 evento de domínio · 🟦 comando · 🟨 agregado · 🟩 política/reação · 🟪 read model ·
🟥 hotspot (decisão ou risco)

---

## Fluxo 1 — Provisionamento e acesso (R0, R0.5)

```
🟦 ProvisionarOperador → 🟨 Operador → 🟧 OperadorProvisionado
🟦 AtivarSegundoFator  → 🟨 Operador → 🟧 SegundoFatorAtivado → 🟩 emite códigos de recuperação
🟦 Autenticar          → 🟨 Sessao   → 🟧 LoginIniciado (sem autorização ainda)
🟦 VerificarSegundoFator → 🟨 Sessao → 🟧 SessaoAutorizada
🟦 DesativarOperador   → 🟨 Operador → 🟧 OperadorDesativado → 🟩 revoga todas as sessões
```

🟥 **Hotspot:** `LoginIniciado` **não** é sessão utilizável. A separação entre iniciar e autorizar
é o que impede que senha vazada dê acesso admin. Modelada como dois eventos, não um.

---

## Fluxo 2 — Campanha e conta de recebimento (R1, R10, R8)

```
🟦 CadastrarContaRecebimento → 🟨 ContaRecebimento → 🟧 ContaCadastrada
🟩 verifica titularidade contra CNPJ → 🟧 ContaVerificada | 🟧 ContaRecusada
🟦 CriarCampanha    → 🟨 Campanha → 🟧 CampanhaCriada (RASCUNHO)
🟦 PublicarCampanha → 🟨 Campanha → 🟩 GUARDA: conta verificada? autorização válida? regulamento?
                                  → 🟧 CampanhaPublicada
                                  → 🟩 gera estoque de N números (assíncrono)
                                  → 🟧 EstoqueGerado
```

🟥 **Hotspot:** publicar é o **único** ponto em que compliance (R8) e conta (R10) são checados.
Depois disso a campanha é vendável. Guarda fraca aqui = campanha ilegal no ar.

---

## Fluxo 3 — Compra (R3, R7, R7.5, R2)

```
🟦 CadastrarComprador → 🟨 Comprador → 🟧 CompradorCadastrado
🟦 CriarPedido → 🟩 GUARDA: campanha publicada? limite por CPF? maioridade?
              → 🟨 Pedido → 🟧 PedidoCriado (AGUARDANDO_PAGAMENTO)
              → 🟩 aloca N números (SKIP LOCKED) → 🟧 NumerosReservados
              → 🟩 cria cobrança no PSP → 🟧 CobrancaEmitida
🟧 (webhook) PagamentoConfirmado → 🟩 confirma valor na API, não no corpo
                                → 🟨 Pedido → 🟧 PedidoPago → 🟧 NumerosAtribuidos
🟩 worker de expiração → 🟩 consulta PSP antes → 🟧 PedidoExpirado → 🟧 NumerosLiberados
```

🟥 **Hotspot 1:** o corpo do webhook **não** é fonte de verdade para valor (SPEC §7). Confiar
nele é aceitar que quem forjar o POST define quanto foi pago — e o webhook do PicPay não é assinado.

🟥 **Hotspot 2:** expirar sem consultar o PSP perde pagamento tardio. O worker consulta antes.

---

## Fluxo 4 — Commitment (R4, R5)

```
🟦 CongelarCampanha (T-2h) → 🟨 Campanha → 🟧 CampanhaCongelada
                          → 🟩 pagamento tardio agora vai para estorno
🟩 monta snapshot NDJSON dos números PAGOS → 🟧 SnapshotGerado
🟩 constrói árvore Merkle (RFC 6962)        → 🟧 RaizCalculada
🟦 CarimbarCommitment → ACT externa         → 🟧 CommitmentCarimbado
                                            → 🟧 CommitmentPublicado
```

🟥 **Hotspot:** a ordem é irreversível e **auditável**: congelar → snapshot → raiz → carimbo.
Carimbar antes de a extração existir é o que dá valor probatório. Inverter a ordem destrói a tese.

🟥 **Caso degenerado:** snapshot vazio (zero vendas) → `CANCELADA_SEM_VENDAS`, commitment da lista
vazia publicado assim mesmo. **Nunca** sortear entre não-vendidos.

---

## Fluxo 5 — Apuração e entrega (R6, R8.5, R9.3)

```
🟩 (dia da extração) obtém extração → fonte primária
   ↳ falha → fonte secundária
   ↳ falha → 🟧 ApuracaoBloqueada → 🟩 exige entrada manual com 2 responsáveis
🟦 Apurar → 🟨 Apuracao → 🟧 ExtracaoObtida → 🟧 GanhadorApurado → 🟧 ResultadoPublicado
🟦 RegistrarEntrega → 🟨 EntregaPremio → 🟧 EntregaRegistrada
🟦 ConfirmarRecebimento (ganhador) → 🟧 EntregaConfirmada → 🟧 CampanhaEncerrada
🟦 RetificarApuracao → 🟩 GUARDA: causa fechada + dupla autorização
                    → 🟧 ApuracaoRetificada (original preservada)
```

🟥 **Hotspot:** resultado sintético é **proibido por construção** — não existe caminho de código
que produza uma extração inventada. Bloquear e esperar humano é a única saída degradada.

---

## Read models (🟪)

| Read model | Alimenta | Requisito |
|---|---|---|
| `CampanhaPublica` | página pública, contador | R1, R12 |
| `MeusNumeros` | painel do comprador | R7.5 |
| `ComprovanteComProva` | comprovante + prova Merkle | R5 |
| `PainelOperador` | visão geral, pedidos, apurações | R9.1–R9.3 |
| `RelatorioArrecadacao` | exportação | R9.4 |
| `VerificadorPublico` | verificação por terceiro | R5 |

---

## Hotspots consolidados → onde viraram decisão

| # | Hotspot | Resolvido em |
|---|---|---|
| 1 | Login ≠ sessão autorizada | SPEC §8, RNF-11 |
| 2 | Webhook não assinado, valor não confiável | SPEC §7, ADR-19 |
| 3 | Expirar sem consultar PSP | SPEC §4, worker |
| 4 | Ordem do commitment | SPEC §6, ADR-04 |
| 5 | Snapshot vazio | SPEC §6, caso degenerado |
| 6 | Resultado sintético proibido | SPEC §7, ADR-16 |
| 7 | Retificação sem virar edição | ADR-13 |
| 8 | Shredding vs. cadeia de auditoria | SPEC §9, ADR-22 |
