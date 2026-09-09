---
id: smoke-tests
etapa: 13
data: 2026-09-08
status: done
---

# SMOKE TESTS — Dream RI

Executados após cada deploy, antes de liberar tráfego. Falha em qualquer um = rollback.

## Infra

| # | Verificação | Esperado |
|:-:|---|---|
| 1 | `GET /health/live` | 200 |
| 2 | `GET /health/ready` | 200, com Postgres, Redis e PSP ok |
| 3 | Migrations aplicadas | Versão esperada |
| 4 | Cabeçalhos de segurança | HSTS, CSP, X-Frame-Options, X-Content-Type-Options |
| 5 | TLS | 1.3 |
| 6 | Object-lock no storage | Ativo |

## Fluxo crítico

| # | Verificação | Esperado |
|:-:|---|---|
| 7 | Página pública da campanha | Renderiza sem login |
| 8 | Criar pedido | Números reservados + Pix emitido |
| 9 | Idempotência | Mesma chave devolve o mesmo pedido |
| 10 | Webhook de teste | Aceito e idempotente |
| 11 | **Reconsulta ao PSP** | Valor vem da API, não do corpo |
| 12 | Verificador público | Responde sem autenticação |

## Segurança

| # | Verificação | Esperado |
|:-:|---|---|
| 13 | Rota admin sem 2º fator | 401 |
| 14 | Campanha de outro tenant | **404**, não 403 |
| 15 | Rate limit no checkout | 429 acima de 10/min |
| 16 | Log de um pedido | **Sem CPF, telefone ou e-mail** |

## Dados

| # | Verificação | Esperado |
|:-:|---|---|
| 17 | Worker de retenção | Agendado e ativo |
| 18 | `sessoes_pendentes_expurgo_gauge` | Exposta |
| 19 | Alertas críticos | Configurados com destinatário real |

## Pré-campanha (adicional, antes de publicar campanha real)

| # | Verificação | Esperado |
|:-:|---|---|
| 20 | Conta de recebimento | Verificada, titularidade conferida |
| 21 | Autorização do órgão | Válida por > 30 dias |
| 22 | **ACT respondendo** | Carimbo de teste emitido e validado |
| 23 | Fonte da Federal | Extração da última data lida corretamente |
| 24 | Estoque gerado | Total confere; `ordem` é permutação |

---

## O smoke que ninguém lembra de fazer

**#22 — carimbar de teste antes da campanha.** A ACT pode estar com cota esgotada, credencial
vencida ou fora do ar, e isso só aparece no congelamento — quando já é tarde, porque a janela de
anterioridade ao sorteio é fixa.

Emitir um carimbo descartável antes de publicar a campanha custa centavos e evita o incidente
mais caro possível.
