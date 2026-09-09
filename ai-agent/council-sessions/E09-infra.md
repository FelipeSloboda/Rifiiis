---
id: council-e09
etapa: 9
data: 2026-09-08
status: planned
---

# COUNCIL — Infra (Etapa 9)

> **Estado: pauta.** Sessão não realizada.

## Composição prevista

`infra-devops` · `dados-postgres` · `seguranca-appsec` · `observabilidade`

## Pauta

### 1. Onde hospedar
VPS com Caddy é a proposta da SPEC §1. Serviços gerenciados de Postgres e Redis, ou tudo no mesmo
host? O critério é custo × risco de operação por uma equipe pequena.

### 2. Object-lock — qual provedor
Requisito não-negociável para o snapshot. Quais opções S3-compatíveis atendem, e a que custo?

### 3. RPO/RTO realistas
O plano declara RPO < 5 min e RTO < 1h. Isso é atingível com o orçamento? Se não, ajustar a
declaração — número de recuperação que não se cumpre é pior que número honesto.

### 4. Retenção de backup vs. crypto-shredding
Ver CH-07 e a pergunta 6 do council de arquitetura. Backup longo conflita com o direito de
exclusão. Qual a janela?

### 5. Onde vive a KEK
Gerenciador externo — qual? O requisito é que ela **nunca** esteja no mesmo lugar do dump.

### 6. Custo do carimbo
⚠️ Não cotado. É a variável que define o piso de preço do produto.
