# Spec Técnica — Plataforma de Rifa com Apuração Verificável

**Codinome:** Rifiiis
**Versão:** 1.6
**Companion de:** `PRD-plataforma-rifa-mvp.md`
**Status:** Draft para revisão de arquitetura

### O que mudou na v1.6 (2026-09-08)

Quatro decisões do operador, e as consequências que elas arrastaram:

| Mudança | Onde | Consequência não óbvia |
|---|---|---|
| Node 22 → **Node 24 LTS**, TS 5.6 → **5.9** | §1, ADR-23 | 22 saiu de Active LTS. **TS 7 foi recusado deliberadamente** — é `latest`, mas o NestJS e o Metro ainda não seguiram |
| **Mobile-first com Expo/RN** | §1, §13, ADR-20 | **+1 semana (5 → 6)** e dependência da fila de revisão das lojas. O app deixa de ser caminho único de compra para não travar o go-live |
| **PicPay como PSP** (era Asaas/Celcoin) | §7, ADR-21 | O webhook **não é assinado** — autenticação por token estático obrigou a reconsulta do §7 (ADR-22) |
| **Sem ORM** (Prisma) | §1, ADR-24 | A `latest` do Prisma hoje é RC, e o núcleo do sistema é SQL de qualquer forma |

**A leitura que importa:** o modelo de domínio (§2–§6) **não mudou uma linha**. Trocar de PSP e de
superfície de apresentação custou dois adapters e um app — não uma reescrita. É o retorno concreto das
portas que a v1.0 pagou para ter.

---

## 1. Visão de arquitetura

Monolito modular em TypeScript, Clean Architecture com ports & adapters. Monolito é decisão deliberada: 6 semanas, 1 dev, 1 cliente. Distribuir aqui é custo puro. O corte por módulo de domínio preserva a extração futura sem reescrita.

```
┌──────────────────────────────────────────────────────┐
│  Presentation                                        │
│  app (Expo/RN) │ storefront (Next.js) │ admin │ REST │
│      ↑ superfície primária        ↑ SEO/link público │
├──────────────────────────────────────────────────────┤
│  Application                                         │
│  use cases · commands · queries · DTOs               │
├──────────────────────────────────────────────────────┤
│  Domain                          ← sem dependência   │
│  agregados · VOs · eventos · políticas · portas      │
├──────────────────────────────────────────────────────┤
│  Infrastructure                                      │
│  Postgres · Redis · PSP · Federal · TSA · e-mail     │
└──────────────────────────────────────────────────────┘
```

Dependências apontam sempre para dentro. O domínio não importa nada de `infrastructure` — verificado por regra de ESLint (`import/no-restricted-paths`), não por disciplina.

### Stack

| Camada | Escolha | Justificativa |
|---|---|---|
| Runtime | **Node 24 LTS** + **TypeScript 5.9 strict** | Node 24 é o Active LTS (mantido até abr/2028); 22 entrou em Maintenance. TS 5.9 e não 7.x: ver nota abaixo |
| Framework HTTP | **NestJS 11** | DI nativo casa com ports/adapters; módulos por feature |
| Banco | **PostgreSQL 17** | Transações, `SKIP LOCKED`, `COPY`, append-only. 17 melhora vacuum e I/O de `COPY` — ambos no caminho crítico da geração de 1M números |
| Cache/locks | Redis 7 | Idempotência, rate limit, fila leve |
| Fila | **BullMQ 5** | Já sobre Redis; evita mais um componente |
| **App (primário)** | **Expo SDK 54 (React Native 0.81) + expo-router** | **Mobile-first: é a superfície principal do produto.** Build/OTA por EAS, sem cadeia nativa local |
| Front web | **Next.js 15 (App Router)** | Continua existindo, com escopo reduzido: página pública da campanha (SEO/link compartilhável) + admin do operador |
| Estado/dados | TanStack Query 5 + Zod 4 | Cache e revalidação no app; Zod valida a fronteira de confiança nas duas pontas |
| Testes | Vitest + Supertest + Testcontainers | Integração contra Postgres real |
| Testes de app | **Maestro** | E2E em emulador Android/iOS, sem depender de Detox+cadeia nativa |
| Contrato | OpenAPI 3.1 gerado dos decorators | Fonte única — o app consome cliente gerado, não tipos escritos à mão |
| Infra | Docker Compose → VPS com Caddy | Mesmo padrão já usado em `*.tst.bit4devs.com.br` |
| CI | GitHub Actions | lint → test → build → migrate → deploy; job separado de `eas build` |

**Por que TypeScript 5.9 e não 7.x.** O TS 7 (compilador reescrito em Go) já é `latest` no npm, mas o
custo aqui não é o compilador — é o ecossistema: NestJS depende de decorators + `emitDecoratorMetadata`
para a DI, e a stack de build do React Native/Metro ainda se estabiliza em cima do compilador antigo.
Numa janela de 6 semanas com 1 dev, adotar o compilador novo transfere risco de terceiro para o caminho
crítico sem ganho de produto. **Gatilho de revisão:** quando NestJS declarar suporte a TS 7 em release
estável, a migração vira ADR própria — não decisão silenciosa.

**Por que Expo SDK 54 e não 57.** O SDK 57 é o estável mais recente, e é a escolha certa se o projeto
começar depois que as libs nativas de terceiro alcançarem. O que trava a decisão é o SDK do PSP e as
libs de câmera/deep link: em SDK recém-lançado, `expo prebuild` costuma quebrar em dependência nativa
que ainda não publicou build para a versão. **Regra:** fixar o SDK na versão em que todas as
dependências nativas do projeto já publicaram suporte, verificada no dia do kickoff — não na mais nova
por princípio. Se a verificação passar em 57, sobe para 57 e esta linha é atualizada.

**Por que Prisma não entrou.** A `latest` do npm hoje é uma release candidate (8.0-rc). Além disso, o
núcleo de valor deste sistema — `FOR UPDATE SKIP LOCKED`, `COPY` de 1M linhas, hash chain append-only —
é escrito em SQL direto de qualquer forma. ORM aqui seria uma camada a manter sem cobrir o caminho
crítico. Repositórios usam SQL parametrizado com driver `postgres`; migrations versionadas em `.sql`.

### Estrutura de pastas — por domínio, não por tipo

```
apps/
├── api/src/             # NestJS — o monolito modular abaixo
│   ├── campanha/
│   │   ├── domain/          # Campanha, Premio, Autorizacao, portas
│   │   ├── application/     # PublicarCampanha, CongelarCampanha
│   │   ├── infrastructure/  # CampanhaRepositoryPg
│   │   └── presentation/    # CampanhaController
│   ├── estoque/             # NumeroDaSorte, AlocadorDeNumeros
│   ├── pedido/              # Pedido, Reserva, máquina de estados
│   ├── pagamento/           # porta PSP + adapter PicPay
│   ├── apuracao/            # Commitment, MerkleTree, RegraDeAproximacao
│   ├── comprador/           # Comprador, consentimento LGPD
│   ├── auditoria/           # ledger append-only com hash chain
│   └── shared/              # kernel: Result, DomainEvent, Money, CPF
├── app/                 # Expo/RN — superfície primária (comprador)
│   └── src/app/             # expo-router: campanha, checkout, pix, meus-numeros
└── web/                 # Next.js — página pública da campanha + admin do operador
packages/
├── contrato/            # cliente TS gerado do OpenAPI — consumido por app e web
└── ui/                  # tokens de design compartilhados
```

**O domínio não sabe que existe app.** Toda a §2 em diante permanece idêntica com a mudança de
superfície: mobile-first muda a camada de apresentação e o plano de entrega, não o modelo de domínio.
É exatamente o que a Clean Architecture deveria comprar — e o teste dessa promessa é este: nenhuma
regra de negócio precisou mudar de lugar nesta revisão.

Cada módulo expõe um `index.ts` como barrel. Módulos comunicam por eventos de domínio ou por casos de uso da camada de aplicação — nunca por acesso direto a repositório de outro módulo.

---

## 2. Modelo de domínio

### Agregados

**`Campanha`** (raiz)
Invariantes:
- Preço e total de números são imutáveis após `PUBLICADA`
- Só publica com `Autorizacao` vigente
- Transição para `CONGELADA` é irreversível
- `dataExtracao` deve ser futura na publicação

Estados: `RASCUNHO → PUBLICADA → CONGELADA → APURADA → AGUARDANDO_ENTREGA → ENCERRADA`
(+ `SUSPENSA` a partir de `PUBLICADA`; + `CANCELADA_SEM_VENDAS` a partir de `CONGELADA` com snapshot vazio)

A campanha **não encerra na apuração** — encerra na entrega comprovada (R8.5). Parar em `APURADA` deixaria o produto provando metade do percurso.

**`Pedido`** (raiz)
Invariantes:
- Todo pedido tem exatamente uma `Reserva` enquanto `AGUARDANDO_PAGAMENTO`
- Valor total = quantidade de bilhetes × preço unitário, calculado no domínio, nunca vindo do cliente
- Não pode ser criado em campanha fora de `PUBLICADA`
- Não pode exceder o limite por CPF da campanha

Estados: `AGUARDANDO_PAGAMENTO → PAGO | EXPIRADO | CANCELADO`, e `PAGO → ESTORNO_PENDENTE → ESTORNADO`

`ESTORNO_PENDENTE` existe por causa do modelo sem custódia (R10): a plataforma solicita o
estorno na conta do operador, e essa operação **pode falhar por saldo**. Ir direto de `PAGO`
para `ESTORNADO` declararia devolvido um dinheiro que continua com o operador.

**`NumeroDaSorte`** (entidade dentro do agregado `EstoqueDaCampanha`)
Invariante central: um número está em exatamente um de três estados — `DISPONIVEL`, `RESERVADO` (com dono e prazo), `VENDIDO` (com pedido pago). Nunca em dois.

**`Apuracao`** (raiz)
Invariantes:
- Só existe para campanha `CONGELADA`
- Exige `Commitment` carimbado anterior à extração
- Cada passo da regra de aproximação é registrado imutavelmente

**`Comprador`** (raiz) — CPF como identidade natural, consentimento versionado.

### Value Objects

`CPF` (com validação de DV), `Dinheiro` (centavos em inteiro, nunca float), `FaixaDeNumeros`, `RaizMerkle`, `ProvaDeInclusao`, `ExtracaoFederal`, `NumeroDaAutorizacao`.

### Eventos de domínio

`CampanhaPublicada`, `CampanhaCongelada`, `PedidoCriado`, `PagamentoConfirmado`, `NumerosAtribuidos`, `ReservaExpirada`, `CommitmentGerado`, `ApuracaoConcluida`.

Publicados via outbox transacional (tabela `evento_outbox` escrita na mesma transação do agregado, drenada por worker). Sem isso, "pagamento confirmado mas números não atribuídos" vira incidente de produção.

---

## 3. Modelo de dados

```sql
-- ── Operador (R0) ───────────────────────────────────────
-- Sem esta tabela, tenant_id (ADR-08) não tem dono modelado.
CREATE TABLE operador (
  id                UUID PRIMARY KEY,
  tenant_id         UUID NOT NULL,
  email             CITEXT NOT NULL,        -- unicidade no índice parcial abaixo
  senha_hash        TEXT NOT NULL,          -- Argon2id
  nome              TEXT NOT NULL,
  totp_secret_cifrado BYTEA,                -- NULL até o primeiro acesso ativar
  totp_ativado_em   TIMESTAMPTZ,
  bloqueado_ate     TIMESTAMPTZ,            -- bloqueio temporário por tentativas
  tentativas_falhas SMALLINT NOT NULL DEFAULT 0,
  criado_em         TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Desligamento: revoga acesso sem apagar a linha. As FKs de auditoria e de
  -- extracao_tentativa apontam para cá; DELETE destruiria a atribuição de quem
  -- autorizou a apuração manual, que é o controle do ADR-16.
  desativado_em     TIMESTAMPTZ,
  -- Anonimização (art. 16): executada no fim do prazo legal, não no desligamento.
  -- Zera e-mail/nome/segredos preservando id, tenant_id e as FKs.
  anonimizado_em    TIMESTAMPTZ,
  CONSTRAINT anonimizado_exige_desativado
    CHECK (anonimizado_em IS NULL OR desativado_em IS NOT NULL)
);

-- e-mail único apenas entre operadores vivos: liberar o endereço após a
-- anonimização permite recontratar a mesma pessoa sem colidir com a linha morta.
CREATE UNIQUE INDEX idx_operador_email_ativo
  ON operador (email) WHERE anonimizado_em IS NULL;

-- códigos de recuperação: hash, uso único
CREATE TABLE operador_codigo_recuperacao (
  id            UUID PRIMARY KEY,
  operador_id   UUID NOT NULL REFERENCES operador(id),
  codigo_hash   TEXT NOT NULL,
  usado_em      TIMESTAMPTZ
);

CREATE TABLE sessao (
  id            UUID PRIMARY KEY,
  operador_id   UUID NOT NULL REFERENCES operador(id),
  refresh_hash  TEXT NOT NULL,
  ip            INET,
  user_agent    TEXT,
  segundo_fator_em TIMESTAMPTZ,   -- NULL = login iniciado, 2FA ainda não verificado
  expira_em     TIMESTAMPTZ NOT NULL,
  revogada_em   TIMESTAMPTZ,
  criada_em     TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Prazo de expurgo do par (ip, user_agent). Fixo em 90 dias: cobre a janela de
  -- investigação de acesso indevido sem virar histórico de localização do operador.
  purgar_em     TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '90 days',
  purgada_em    TIMESTAMPTZ
);

-- sessão sem segundo_fator_em NÃO autoriza nenhuma rota /api/admin/*
CREATE INDEX idx_sessao_ativa ON sessao (operador_id)
  WHERE revogada_em IS NULL;

-- fila do worker de expurgo: só o que ainda tem PII e já venceu
CREATE INDEX idx_sessao_a_purgar ON sessao (purgar_em)
  WHERE purgada_em IS NULL;

-- ── Comprador ───────────────────────────────────────────
-- Concentra TODA a PII do produto. É a tabela que o crypto-shredding protege:
-- cada titular tem sua própria chave (`chave_dek_cifrada`), e apagá-la torna
-- os campos ilegíveis sem remover um único byte — o que preserva o hash chain
-- da auditoria (§9).
CREATE TABLE comprador (
  id                UUID PRIMARY KEY,
  tenant_id         UUID NOT NULL,

  -- PII cifrada sob a DEK do próprio titular (AES-256-GCM, nonce por campo)
  nome_cifrado      BYTEA NOT NULL,
  cpf_cifrado       BYTEA NOT NULL,
  nascimento_cifrado BYTEA NOT NULL,
  telefone_cifrado  BYTEA NOT NULL,
  email_cifrado     BYTEA,

  -- Chave de dados do titular, embrulhada pela KEK externa (envelope encryption).
  -- Apagar esta coluna É o shredding. A KEK nunca toca o banco.
  chave_dek_cifrada BYTEA,
  chave_apagada_em  TIMESTAMPTZ,      -- carimbo do exercício do art. 18

  -- Índice cego do CPF: permite achar o titular e aplicar o limite por campanha
  -- sem manter o CPF legível. Ver §9 para por que é Argon2id e não HMAC.
  cpf_indice        BYTEA NOT NULL,

  criado_em         TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- DEK apagada e PII presente é o estado esperado após o shredding;
  -- o inverso (carimbo sem apagar a chave) é bug e o banco recusa.
  CONSTRAINT shredding_coerente
    CHECK ((chave_apagada_em IS NULL) = (chave_dek_cifrada IS NOT NULL))
);

-- Um comprador por CPF por tenant: é o que sustenta o limite do art. da campanha
-- e a consulta "meus números". Sobrevive ao shredding — cpf_indice não é cifrado.
CREATE UNIQUE INDEX idx_comprador_cpf ON comprador (tenant_id, cpf_indice);

-- ── Acesso do comprador por código (R7.5) ───────────────
-- Sem senha: o código de uso único prova posse do canal.
CREATE TABLE comprador_codigo_acesso (
  id            UUID PRIMARY KEY,
  comprador_id  UUID NOT NULL REFERENCES comprador(id),
  codigo_hash   TEXT NOT NULL,          -- nunca o código em claro
  canal         TEXT NOT NULL,          -- 'whatsapp' | 'email'
  tentativas    SMALLINT NOT NULL DEFAULT 0,
  usado_em      TIMESTAMPTZ,
  expira_em     TIMESTAMPTZ NOT NULL,   -- 10 min
  ip_solicitante INET,
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_codigo_vigente
  ON comprador_codigo_acesso (comprador_id, expira_em DESC)
  WHERE usado_em IS NULL;

CREATE TABLE comprador_sessao (
  id            UUID PRIMARY KEY,
  comprador_id  UUID NOT NULL REFERENCES comprador(id),
  token_hash    TEXT NOT NULL,
  ip            INET,
  user_agent    TEXT,
  expira_em     TIMESTAMPTZ NOT NULL,   -- 30 dias
  revogada_em   TIMESTAMPTZ,
  criada_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Conta de recebimento do operador (R10) ──────────────
-- Modelo SEM custódia: o Pix cai direto aqui, nunca em conta da plataforma.
CREATE TABLE conta_recebimento (
  id                UUID PRIMARY KEY,
  operador_id       UUID NOT NULL REFERENCES operador(id),
  tenant_id         UUID NOT NULL,
  provedor          TEXT NOT NULL,          -- 'asaas' | 'celcoin'
  conta_externa_id  TEXT NOT NULL,          -- id da conta no PSP
  chave_pix_mascara TEXT NOT NULL,          -- só para exibir; a chave vive no PSP
  cnpj_titular      TEXT NOT NULL,
  verificada_em     TIMESTAMPTZ,            -- NULL = não publica campanha
  ativa             BOOLEAN NOT NULL DEFAULT true,
  criada_em         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- uma conta ativa por operador
CREATE UNIQUE INDEX idx_conta_ativa
  ON conta_recebimento (operador_id) WHERE ativa;

-- ── Estornos pendentes (R10) ────────────────────────────
CREATE TABLE estorno_pendente (
  id            UUID PRIMARY KEY,
  pedido_id     UUID NOT NULL UNIQUE REFERENCES pedido(id),
  valor_cents   INTEGER NOT NULL,
  motivo_falha  TEXT NOT NULL,          -- SALDO_INSUFICIENTE, CONTA_BLOQUEADA, ...
  tentativas    SMALLINT NOT NULL DEFAULT 1,
  ultima_tentativa_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolvido_em  TIMESTAMPTZ,
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_estorno_aberto
  ON estorno_pendente (criado_em) WHERE resolvido_em IS NULL;

-- ── Tentativas de obtenção da extração (R9.3) ───────────
CREATE TABLE extracao_tentativa (
  id            BIGSERIAL PRIMARY KEY,
  campanha_id   UUID NOT NULL REFERENCES campanha(id),
  fonte         TEXT NOT NULL,          -- 'primaria' | 'secundaria' | 'manual'
  resultado     TEXT NOT NULL,          -- 'sucesso' | 'timeout' | 'erro' | 'divergente'
  detalhe       TEXT,                   -- motivo legível na tela do operador
  payload       JSONB,
  operador_id   UUID REFERENCES operador(id),   -- preenchido só na entrada manual
  ocorrida_em   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tentativa_campanha
  ON extracao_tentativa (campanha_id, ocorrida_em DESC);

-- ── Campanha ────────────────────────────────────────────
CREATE TABLE campanha (
  id                UUID PRIMARY KEY,
  tenant_id         UUID NOT NULL,
  slug              TEXT NOT NULL,
  titulo            TEXT NOT NULL,
  descricao         TEXT,
  status            campanha_status NOT NULL DEFAULT 'RASCUNHO',
  preco_bilhete_cents  INTEGER NOT NULL CHECK (preco_bilhete_cents > 0),
  numeros_por_bilhete  INTEGER NOT NULL CHECK (numeros_por_bilhete > 0),
  total_numeros     INTEGER NOT NULL CHECK (total_numeros BETWEEN 100 AND 1000000),
  limite_cents_por_cpf INTEGER,
  data_extracao     DATE NOT NULL,
  regra_apuracao    JSONB NOT NULL,   -- {fonte, premios:[1,2], digitos:3}
  autorizacao_numero  TEXT NOT NULL,
  autorizacao_orgao   TEXT NOT NULL,
  autorizacao_validade DATE NOT NULL,
  regulamento_versao  INTEGER NOT NULL DEFAULT 1,
  congelada_em      TIMESTAMPTZ,
  criada_em         TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, slug)
);

-- LIMITE DE total_numeros — fonte única da verdade
--   v1 (alocador TabelaPreSorteada):  100 .. 1.000.000
--   O CHECK acima é a autoridade. R1 do PRD e o teste de carga derivam DESTE valor.
--   Elevar o teto para 10.000.000 exige trocar o alocador (ver §4, escape hatch Feistel)
--   E revisar o particionamento de numero_sorte. Não basta alterar o CHECK.

-- ── Estoque ─────────────────────────────────────────────
CREATE TABLE numero_sorte (
  id            BIGSERIAL PRIMARY KEY,
  campanha_id   UUID NOT NULL REFERENCES campanha(id),
  numero        INTEGER NOT NULL,      -- valor visível ao comprador
  ordem         INTEGER NOT NULL,      -- posição pré-embaralhada de alocação
  status        numero_status NOT NULL DEFAULT 'DISPONIVEL',
  pedido_id     UUID,
  reservado_ate TIMESTAMPTZ,
  UNIQUE (campanha_id, numero)
);

-- índice parcial: só o que está disponível entra no índice de alocação
CREATE INDEX idx_numero_alocacao
  ON numero_sorte (campanha_id, ordem)
  WHERE status = 'DISPONIVEL';

CREATE INDEX idx_numero_expiracao
  ON numero_sorte (reservado_ate)
  WHERE status = 'RESERVADO';

CREATE INDEX idx_numero_pedido ON numero_sorte (pedido_id);

-- ── Pedido ──────────────────────────────────────────────
CREATE TABLE pedido (
  id                UUID PRIMARY KEY,
  tenant_id         UUID NOT NULL,
  campanha_id       UUID NOT NULL REFERENCES campanha(id),
  comprador_id      UUID NOT NULL REFERENCES comprador(id),
  status            pedido_status NOT NULL DEFAULT 'AGUARDANDO_PAGAMENTO',
  qtd_bilhetes      INTEGER NOT NULL CHECK (qtd_bilhetes > 0),
  qtd_numeros       INTEGER NOT NULL,
  valor_cents       INTEGER NOT NULL,
  regulamento_versao INTEGER NOT NULL,
  psp_cobranca_id   TEXT,
  pix_copia_cola    TEXT,
  expira_em         TIMESTAMPTZ NOT NULL,
  pago_em           TIMESTAMPTZ,
  criado_em         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_pedido_psp ON pedido (psp_cobranca_id)
  WHERE psp_cobranca_id IS NOT NULL;

-- ── Idempotência de webhook ─────────────────────────────
CREATE TABLE webhook_evento (
  id            UUID PRIMARY KEY,
  provedor      TEXT NOT NULL,
  evento_id     TEXT NOT NULL,       -- id do lado do PSP
  payload       JSONB NOT NULL,
  processado_em TIMESTAMPTZ,
  recebido_em   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (provedor, evento_id)       -- a garantia de idempotência
);

-- ── Commitment ──────────────────────────────────────────
CREATE TABLE commitment (
  id                UUID PRIMARY KEY,
  campanha_id       UUID NOT NULL UNIQUE REFERENCES campanha(id),
  raiz_merkle       BYTEA NOT NULL,
  total_folhas      INTEGER NOT NULL,
  algoritmo         TEXT NOT NULL DEFAULT 'RFC6962-SHA256',
  tsa_token         BYTEA,           -- token RFC 3161
  tsa_autoridade    TEXT,
  carimbado_em      TIMESTAMPTZ,
  snapshot_uri      TEXT NOT NULL,   -- objeto imutável com a lista canônica
  snapshot_sha256   BYTEA NOT NULL,
  criado_em         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Entrega do prêmio (R8.5) ────────────────────────────
CREATE TABLE entrega_premio (
  id                UUID PRIMARY KEY,
  campanha_id       UUID NOT NULL UNIQUE REFERENCES campanha(id),
  numero_apurado    INTEGER NOT NULL,
  pedido_id         UUID REFERENCES pedido(id),   -- NULL se número não vendido
  -- PII do ganhador: cifrada, sujeita a crypto-shredding como o resto
  ganhador_cifrado  BYTEA,           -- sob a chave do titular (crypto-shredding)
  comprovante_uri   TEXT,            -- aponta p/ objeto cifrado
  forma_entrega     TEXT,
  prazo_limite      DATE NOT NULL,
  entregue_em       TIMESTAMPTZ,
  confirmado_em     TIMESTAMPTZ,     -- aceite do ganhador
  confirmado_ip_cifrado BYTEA,       -- IP é PII: cifrado sob a mesma chave
  criada_em         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- só o status é público; nome/CPF/contato do ganhador nunca saem daqui
CREATE INDEX idx_entrega_pendente
  ON entrega_premio (prazo_limite)
  WHERE entregue_em IS NULL;

-- ── Auditoria append-only com hash chain ────────────────
CREATE TABLE auditoria (
  seq           BIGSERIAL PRIMARY KEY,
  tenant_id     UUID NOT NULL,
  entidade      TEXT NOT NULL,
  entidade_id   UUID NOT NULL,
  acao          TEXT NOT NULL,
  ator          TEXT NOT NULL,
  dados         JSONB NOT NULL,
  hash_anterior BYTEA NOT NULL,
  hash_atual    BYTEA NOT NULL,
  ocorrido_em   TIMESTAMPTZ NOT NULL DEFAULT now()
);

REVOKE UPDATE, DELETE ON auditoria FROM app_user;
```

`REVOKE` no nível do banco, não no ORM. Regra de aplicação se contorna; permissão de banco, não.

---

## 4. Alocação de números — o problema técnico central

É aqui que a maioria das implementações quebra. Três armadilhas:

1. `ORDER BY random()` em 1M linhas: sequential scan, segundos por request.
2. `SELECT ... WHERE disponivel LIMIT n` sem lock: dois requests pegam os mesmos números.
3. `SELECT FOR UPDATE` sem `SKIP LOCKED`: serializa tudo e a fila engasga no pico.

### Solução: pré-embaralhamento na geração + `SKIP LOCKED` na alocação

**Na publicação** (job assíncrono): gera `[0..N-1]`, aplica Fisher-Yates sobre `Int32Array` (~50ms para 1M), grava via `COPY` binário atribuindo `ordem = posição embaralhada`. 1M de linhas em ~6s.

A aleatoriedade é resolvida **uma vez, na geração**. A alocação vira sequencial e barata.

**Na reserva:**

```sql
WITH escolhidos AS (
  SELECT id
  FROM numero_sorte
  WHERE campanha_id = $1 AND status = 'DISPONIVEL'
  ORDER BY ordem
  LIMIT $2
  FOR UPDATE SKIP LOCKED
)
UPDATE numero_sorte n
   SET status = 'RESERVADO',
       pedido_id = $3,
       reservado_ate = now() + ($4 || ' minutes')::interval
  FROM escolhidos e
 WHERE n.id = e.id
RETURNING n.numero;
```

Se `RETURNING` devolver menos linhas que `$2`, a transação faz rollback e o caso de uso retorna `ESTOQUE_INSUFICIENTE`. Isso resolve a user story 16 sem lógica adicional.

Índice parcial mantém a árvore B-tree pequena: números vendidos saem do índice, então o custo de alocação **cai** conforme a campanha esgota.

**Expiração** — worker a cada 30s:

```sql
-- em lotes: sem LIMIT, um pico de reservas expirando junto vira lock burst
WITH expirados AS (
  SELECT id
  FROM numero_sorte
  WHERE status = 'RESERVADO' AND reservado_ate < now()
  ORDER BY reservado_ate
  LIMIT 5000
  FOR UPDATE SKIP LOCKED
)
UPDATE numero_sorte n
   SET status='DISPONIVEL', pedido_id=NULL, reservado_ate=NULL
  FROM expirados e
 WHERE n.id = e.id
RETURNING n.id;
```

O worker repete o lote enquanto `RETURNING` devolver 5.000 linhas, e para quando devolver menos. Sem o `LIMIT`, o `UPDATE` de um pico de expiração simultânea (fim de campanha popular, milhares de reservas vencendo no mesmo minuto) toma lock em faixa grande da tabela e compete com a alocação — exatamente no pior momento. `SKIP LOCKED` também aqui: linha travada por outra transação fica para a próxima rodada, não bloqueia o lote.

### Dimensionamento de `numero_sorte` sob churn

O `COPY` de 1M em ~6s é o caso fácil: escrita única, tabela limpa. O caso que morde é o **churn de reserva/expiração ao longo da campanha** — todo `UPDATE` no Postgres cria uma tupla nova e marca a antiga como morta.

**Conta do pior caso realista** (1M números, conversão Pix de 55%, TTL de 15 min):

| Grandeza | Valor |
|---|---|
| Tupla de `numero_sorte` | ~70 bytes + overhead ≈ 100 bytes |
| Tabela inicial (1M) | ~100 MB + índices |
| `UPDATE`s por número vendido | 1 (reserva) + 1 (venda) = 2 |
| `UPDATE`s por número que expira e volta | 2 por ciclo, e um número pode ciclar várias vezes |
| Estimativa com 45% de Pix não pago | ~2,5M `UPDATE`s numa campanha que esgota |
| **Tuplas mortas geradas** | **~2,5M ≈ 250 MB de bloat** se o autovacuum não acompanhar |

O autovacuum default (`autovacuum_vacuum_scale_factor = 0.2`) só dispara com 20% da tabela morta — 200 mil tuplas. Numa campanha em pico isso acumula rápido, e o índice parcial `idx_numero_alocacao` degrada junto: a alocação fica lendo páginas cheias de tupla morta.

**Configuração por tabela** (não global — só esta tabela tem esse perfil):

```sql
ALTER TABLE numero_sorte SET (
  autovacuum_vacuum_scale_factor = 0.02,   -- 2% em vez de 20%
  autovacuum_vacuum_cost_delay   = 2,      -- mais agressivo
  autovacuum_analyze_scale_factor = 0.05,
  fillfactor = 85                          -- espaço para HOT update na mesma página
);
```

`fillfactor = 85` é o ajuste mais relevante: reserva 15% de cada página para que o `UPDATE` de status caiba **na mesma página** (HOT update), o que evita atualizar o índice e reduz drasticamente o bloat de índice. Funciona aqui porque os campos atualizados (`status`, `pedido_id`, `reservado_ate`) **não** fazem parte de `UNIQUE (campanha_id, numero)`.

**Verificação obrigatória** (entra no teste de carga da semana 6):

```sql
SELECT relname, n_live_tup, n_dead_tup,
       round(100.0 * n_dead_tup / NULLIF(n_live_tup,0), 1) AS pct_morto,
       last_autovacuum
  FROM pg_stat_user_tables WHERE relname = 'numero_sorte';
```

Critério de aceite: após simular uma campanha completa com 45% de expiração, `pct_morto < 10%` e o p95 da alocação continua < 300ms. Se não passar, o próximo passo é particionar por `campanha_id` — campanha encerrada vira partição estática, sem churn.

**Por que não particionar já:** com teto de 1M por campanha (ADR-11) e 1 cliente, particionar agora é complexidade sem retorno mensurado. A decisão fica registrada com o gatilho explícito acima, em vez de virar surpresa.

**Escape hatch (P2/R19):** acima de ~5M números, trocar a tabela pré-embaralhada por permutação via cifra Feistel de 3 rodadas sobre o domínio `[0..N-1]`. Vira O(1) sem tabela. Por isso `AlocadorDeNumeros` é porta, não implementação concreta.

---

## 5. Máquina de estados do pedido

```
                    ┌─────────────────────┐
       criar ──────▶│ AGUARDANDO_PAGAMENTO│
                    └──────────┬──────────┘
              webhook.pago     │     timeout / cancelamento
                    ┌──────────┴──────────┐
                    ▼                     ▼
              ┌──────────┐          ┌──────────┐
              │   PAGO   │          │ EXPIRADO │
              └────┬─────┘          └──────────┘
                   │ estorno
                   ▼
             ┌───────────┐
             │ ESTORNADO │
             └───────────┘
```

Implementada como enum fechado + tabela de transições permitidas no domínio. Qualquer transição fora da tabela lança `TransicaoInvalidaError`. Isso é aplicação direta do princípio de deixar o modelo propor e o determinístico dispor — o webhook do PSP propõe, a máquina de estados dispõe.

**Caso crítico: Pix pago após a expiração.** O PSP entrega `pago` para um pedido já `EXPIRADO`. Fluxo:

1. Tenta realocar a mesma quantidade de números.
2. Sucesso → pedido vai para `PAGO` com números novos, comprador é notificado da troca.
3. Falha (sem estoque ou campanha congelada) → aciona estorno via PSP **na conta do operador**:
   - Estorno aceito → pedido vai para `ESTORNADO`, comprador notificado.
   - Estorno recusado (saldo insuficiente, conta bloqueada) → pedido vai para
     `ESTORNO_PENDENTE`, registro criado em `estorno_pendente` com o valor devido,
     operador alertado com urgência alta e comprador informado de que a devolução
     está em andamento. Um worker retenta com backoff; o painel mostra a fila aberta.

Nunca aceitar dinheiro sem entregar número. Nunca entregar número sem dinheiro.
E quando não for possível fazer nenhum dos dois na hora, **dizer isso** — ao operador e
ao comprador — em vez de marcar como resolvido (ADR-18).

---

## 6. Protocolo de apuração verificável

O núcleo do produto. Cinco fases.

### Fase 1 — Congelamento (T-2h)

Campanha vai para `CONGELADA`. Criação de pedido passa a retornar `CAMPANHA_CONGELADA`. Reservas pendentes seguem o TTL normal, mas não podem mais virar `PAGO` — pagamentos tardios vão direto para estorno.

### Fase 2 — Snapshot canônico

Lista de todos os números com pedido em `PAGO`, ordenada crescente por número. Formato NDJSON, uma linha por número:

```json
{"n":48221,"h":"a3f1...","t":"2026-09-04T18:22:31Z"}
```

Onde `h` é o *leaf hash* e `t` o timestamp do pagamento. **CPF não aparece.** O leaf é:

```
leaf = SHA256( 0x00 ‖ numero_be32 ‖ Argon2id(cpf, salt_campanha) ‖ pedido_id ‖ pago_em_iso )
```

O `salt_campanha` é gerado por campanha e **nunca publicado**. Ele é o que impede reidentificar compradores a partir do snapshot — que é um artefato **público e permanente**, o pior lugar possível para um derivado fraco.

A primitiva é Argon2id, não HMAC, pela mesma razão de `cpf_indice` (§9): o espaço real de CPFs é ~10⁹, não 10¹¹ — os dois dígitos verificadores são determinísticos — e HMAC é rápido o bastante para varrê-lo numa GPU caso o salt vaze. Argon2id (`m=64MiB, t=3, p=1`) torna essa varredura inviável. O custo entra na construção do snapshot, que é assíncrona e roda uma vez por campanha: 1M de folhas a ~50ms cada exige paralelismo — a derivação é feita em pool de workers durante a Fase 2, não na Fase 3.

Salt **distinto** do de `cpf_indice`, deliberadamente: reusar permitiria cruzar o snapshot publicado com a base e reidentificar por interseção.

O comprador não precisa do salt: ele recebe o leaf pronto no comprovante e apenas confere que ele consta na árvore.

### Fase 3 — Árvore Merkle

Padrão RFC 6962, com separação de domínio obrigatória:

```
folha  = SHA256(0x00 ‖ dados)
interno = SHA256(0x01 ‖ esq ‖ dir)
```

O prefixo de domínio impede o ataque de segunda pré-imagem em que um nó interno é apresentado como folha. Nós ímpares no nível são promovidos sem re-hash (comportamento RFC 6962, não duplicação — duplicar o último nó abre ambiguidade de árvore).

1M de folhas: profundidade 20, prova de inclusão de 20 hashes = 640 bytes. Construção completa em < 2s.

### Fase 4 — Carimbo e publicação

1. `snapshot.ndjson` gravado em storage com object-lock, SHA-256 calculado.
2. Raiz Merkle enviada a autoridade de carimbo do tempo RFC 3161 (ICP-Brasil), token armazenado. Sob a MP 2.200-2/2001 isso tem validade probatória no Brasil — vantagem real sobre ancoragem em blockchain para um contexto sujeito a fiscalização.
3. Publicação imediata na página pública da campanha: raiz em hex, total de folhas, autoridade e horário do carimbo.

Ordem importa: o carimbo **precisa** ser anterior à extração da Federal. Se a TSA falhar, a apuração fica bloqueada e alerta — não prossegue sem carimbo.

### Fase 5 — Apuração e verificação

1. Obtém a extração oficial da data configurada.
2. Forma o número apurado conforme `regra_apuracao` da campanha.
3. Aplica a regra de aproximação: se o número não estiver no snapshot, sobe para o próximo vendido imediatamente superior, com wrap-around. **Cada passo é registrado.**
4. Publica: resultado, extração de origem, log dos passos e link para o `snapshot.ndjson` completo.

### Casos degenerados da regra de aproximação

A regra "sobe para o próximo vendido, com wrap-around" é bem definida **apenas** quando o snapshot tem 2 ou mais números. Os casos abaixo são plausíveis e precisam de comportamento explícito — silêncio aqui vira decisão improvisada no dia do sorteio, que é precisamente o que o produto existe para impedir.

| Caso | Comportamento definido |
|---|---|
| **Snapshot vazio** (zero vendas até o congelamento) | Não há apuração possível. Campanha vai para `CANCELADA_SEM_VENDAS`, o commitment da lista vazia é publicado assim mesmo (prova de que ninguém comprou), e o operador é notificado. **Nunca** sortear entre não-vendidos |
| **Exatamente 1 número vendido** | O wrap-around degenera: o único vendido é o vencedor por definição. Registrar explicitamente que a regra terminou por caso degenerado, não por busca |
| **Número apurado É um número vendido** | Caminho feliz: zero passos de aproximação. O log registra "acerto direto", para distinguir de aproximação com 0 saltos |
| **Todos os números vendidos** | A aproximação nunca é acionada; o apurado é sempre vendido |
| **Empate impossível por construção** | Cada número pertence a no máximo um pedido (invariante de R2), logo não existe empate. Se dois pedidos reivindicarem o mesmo número, é corrupção de dados: a apuração **aborta** e alerta, não escolhe |

Todos os cinco casos têm teste unitário obrigatório. O terceiro e o quinto são os que passam despercebidos numa suíte gerada sem revisão — o quinto especialmente, porque exige o teste afirmar que o sistema *se recusa* a produzir resultado.

**O que o auditor faz:** baixa o snapshot, recomputa a raiz Merkle, compara com a raiz carimbada. Se bater, a base é comprovadamente a mesma de antes da extração. Depois reaplica a regra sobre a lista e confere o vencedor. Não precisa confiar em ninguém.

**O que o comprador faz:** abre o verificador (página estática, sem backend, código aberto), cola seu comprovante, e vê a prova validar contra a raiz pública.

### Retificação de apuração — o caminho que não pode ser improvisado

A apuração é irreversível por construção, e isso é a tese do produto. Mas **irreversível não pode significar incorrigível**: se a apuração rodar sobre insumo errado — fonte primária devolvendo a extração de outra data, regra do regulamento cadastrada errada, extração oficial posteriormente anulada pela CAIXA — não existir caminho de correção não é rigor, é decisão por omissão. O operador honesto ficaria sem saída e o desonesto ganharia o argumento de que "o sistema travou".

**Princípio:** apuração errada não é apagada nem editada. É **superseded** por uma retificação, e ambas permanecem públicas para sempre.

```sql
CREATE TABLE apuracao (
  id                UUID PRIMARY KEY,
  campanha_id       UUID NOT NULL REFERENCES campanha(id),
  sequencia         INTEGER NOT NULL,        -- 1 = original, 2+ = retificação
  numero_apurado    INTEGER NOT NULL,
  extracao_origem   JSONB NOT NULL,          -- concurso, data, prêmios, fonte
  passos_regra      JSONB NOT NULL,
  status            apuracao_status NOT NULL DEFAULT 'VIGENTE',  -- VIGENTE | RETIFICADA
  retifica_id       UUID REFERENCES apuracao(id),  -- aponta para a que ela corrige
  motivo_retificacao TEXT,                   -- obrigatório quando sequencia > 1
  autorizada_por    TEXT,                    -- dupla autorização registrada
  apurada_em        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (campanha_id, sequencia)
);

-- no máximo uma apuração vigente por campanha
CREATE UNIQUE INDEX idx_apuracao_vigente
  ON apuracao (campanha_id) WHERE status = 'VIGENTE';

ALTER TABLE apuracao ADD CONSTRAINT chk_retificacao_justificada
  CHECK (sequencia = 1 OR (motivo_retificacao IS NOT NULL AND retifica_id IS NOT NULL));
```

**Condições de retificação — fechadas, não discricionárias.** Só estas quatro:

| Causa | Quem detecta | Evidência exigida |
|---|---|---|
| Extração de data/concurso divergente do configurado | Automático (conferência pós-apuração) | Concurso e data da fonte vs. `regra_apuracao` |
| Extração oficial anulada ou corrigida pela CAIXA | Operador | Publicação oficial da CAIXA |
| Regra de formação cadastrada divergente do regulamento vigente | Operador / auditor | Regulamento na versão que o comprador aceitou |
| Corrupção de dados detectada (número em dois pedidos) | Automático (a apuração aborta antes de concluir) | Log do abort |

**O que a retificação nunca pode fazer** — estes são os limites que separam correção de fraude:

- ❌ Alterar o snapshot ou o commitment. A base vendida é imutável e já está carimbada; retificação só reinterpreta a **regra** sobre a **mesma** base.
- ❌ Rodar com extração diferente da oficial da data configurada.
- ❌ Ser executada sem dupla autorização registrada em auditoria.
- ❌ Apagar, editar ou despublicar a apuração anterior.
- ❌ Ocorrer após a entrega do prêmio confirmada — nesse ponto o caso sai do sistema e vira questão contratual/jurídica.

**Conferência automática pós-apuração** (fecha a causa mais provável): antes de publicar, o sistema confere que o concurso e a data da extração obtida batem com `regra_apuracao`. Divergência → apuração **não publica**, entra em `PENDENTE` e alerta. Isso transforma o erro mais comum em bloqueio preventivo, não em retificação posterior.

**Visibilidade pública:** a página da campanha mostra a apuração vigente e, quando existe retificação, a original riscada com o motivo ao lado. Esconder a retificação destruiria a tese tanto quanto fraudar o sorteio.

### Por que isso é forte

Para fraudar, seria preciso encontrar colisão de SHA-256 **ou** falsificar carimbo de autoridade credenciada. Comparado com "confie no print do operador", é uma mudança de categoria.

---

## 7. Integrações

### PSP (Pix)

Porta única no domínio:

```typescript
export interface GatewayDePagamento {
  /** A cobrança é emitida SEMPRE com o operador como recebedor (ADR-17). */
  criarCobrancaPix(cmd: CriarCobrancaPix): Promise<Result<CobrancaPix>>;
  consultarCobranca(id: string): Promise<Result<StatusCobranca>>;

  /** Debita a conta do OPERADOR. Pode falhar por saldo — o Result carrega o motivo. */
  estornar(id: string, motivo: string): Promise<Result<void, FalhaDeEstorno>>;

  /** Verifica titularidade da conta contra o CNPJ do organizador. */
  verificarContaRecebimento(conta: ContaRecebimento, cnpj: CNPJ): Promise<Result<void>>;

  /**
   * Autentica a notificação recebida. Deliberadamente NÃO se chama
   * `validarAssinaturaWebhook`: nem todo PSP assina o corpo (ver PicPay abaixo),
   * e um nome que promete assinatura esconderia que a garantia é mais fraca.
   */
  autenticarNotificacao(req: NotificacaoRecebida): Result<void, FalhaDeAutenticacao>;
}

export type FalhaDeEstorno =
  | { tipo: 'SALDO_INSUFICIENTE'; saldoDisponivel: Dinheiro }
  | { tipo: 'CONTA_BLOQUEADA' }
  | { tipo: 'PRAZO_EXCEDIDO' }
  | { tipo: 'INDISPONIVEL' };

export interface CriarCobrancaPix {
  pedidoId: PedidoId;
  valor: Dinheiro;
  /** Sem isto o adapter escolheria o recebedor por conta própria. */
  recebedor: ContaRecebimento;
  expiraEm: Date;
}
```

**`recebedor` é obrigatório no comando, não configuração global do adapter.** Um adapter que
sabe sozinho para onde mandar o dinheiro é um adapter que pode mandar para o lugar errado sem
que o domínio perceba. Tornar o recebedor parte do comando faz o compilador exigir a decisão
em cada cobrança.

**`estornar` devolve `FalhaDeEstorno` tipada, não `void`.** No modelo sem custódia, estorno é
uma operação que **falha de verdade** — e `Result<void>` sem motivo levaria o caso de saldo
insuficiente a virar log genérico em vez de `ESTORNO_PENDENTE` com valor devido.

#### Adapter de partida: PicPay

**`PicPayGateway` é o único adapter do MVP.** A porta acima continua existindo por causa da ADR-20
(troca de PSP), não por um segundo adapter especulativo: um provedor, uma implementação.

| Aspecto | Valor | Consequência de projeto |
|---|---|---|
| Autenticação | OAuth2 `client_credentials` em `POST /oauth2/token` | Token vive **5 minutos** — ver alerta abaixo |
| Base produção | `https://ecommerce-api.svcp.picpay.com` | |
| Base sandbox | `https://ecommerce-api.svcp.ppay.me` | Semana 2 depende deste ambiente estar liberado |
| Criar cobrança | `POST /charge/pix` | Devolve QR Code + Pix copia-e-cola |
| Consultar | `GET /charge/{merchantChargeId}` | Consulta pelo **nosso** identificador — é a rede de segurança do webhook |
| Estorno | endpoint de cancelamento (total ou parcial) | Alimenta `FalhaDeEstorno` da ADR-18 |
| Webhook | header `event_type: TransactionUpdateMessage` | Autenticação por **token no header `Authorization`** |

**Token de 5 minutos é o detalhe que morde.** Renovar por requisição multiplica chamadas no pico de
venda; renovar tarde derruba checkout com 401 no pior momento. O adapter mantém o token em cache no
Redis com renovação **proativa** (aos ~4 min) e **um único renovador por vez** — lock no Redis, porque
sem ele um pico de N requisições concorrentes dispara N chamadas de token, que é exatamente o cenário
contra o qual a própria doc do PicPay recomenda controle de concorrência.

**⚠️ O webhook do PicPay não é assinado — e isso muda a postura de segurança.** A notificação é
autenticada por um **token estático** que o PicPay envia no header `Authorization`, configurado uma
única vez no Painel Lojista (não é recuperável depois — anotar no cofre no ato). Diferente de um HMAC
sobre o corpo, um token estático prova **quem chamou**, não **que o corpo não foi alterado**, e vaza
inteiro se vazar uma vez. Consequências obrigatórias, não opcionais:

1. **Comparação em tempo constante** (`crypto.timingSafeEqual`), nunca `===`.
2. **O corpo do webhook não é fonte de verdade para o valor pago.** Ao receber `PAID`, o worker
   **reconsulta** `GET /charge/{merchantChargeId}` e confere valor e status contra o pedido antes de
   atribuir números. Isto fecha o buraco que a ausência de assinatura abre: confirmar pagamento a
   partir de um corpo não verificado é o caminho direto para número entregue sem dinheiro recebido.
3. **Rotação do token** documentada no runbook, com o webhook aceitando token atual **e** anterior
   durante a janela de troca — caso contrário rotacionar significa derrubar o recebimento.
4. Endpoint restrito a HTTPS, sem query string e sem IPv4 no host (exigências do próprio PicPay).

O passo 2 é o que torna aceitável um PSP sem assinatura. Sem ele, esta escolha de provedor seria um
defeito de segurança, não um trade-off.

**`merchantChargeId` = `pedidoId`.** Como a consulta é feita pelo nosso identificador, o adapter não
precisa persistir o id do PicPay para reconciliar — e a reconsulta do passo 2 funciona mesmo se o
webhook nunca chegar. O worker de expiração aproveita isso: antes de expirar uma reserva, consulta o
PSP. **Expirar sem consultar transformaria uma falha de entrega de webhook em número devolvido ao
estoque com o comprador já tendo pago.**

Fluxo do webhook: autentica o token → grava em `webhook_evento` (o `UNIQUE (provedor, evento_id)` **é**
a idempotência) → enfileira processamento → responde 200 imediatamente. Nunca processar de forma
síncrona no handler; o PSP faz retry por timeout e gera evento duplicado.

### Loteria Federal

```typescript
export interface FonteDeExtracao {
  obterExtracao(data: Date): Promise<Result<ExtracaoFederal>>;
}
```

Duas implementações em cascata (fonte primária oficial + secundária), com um `FonteManualAssistida` para o caso de ambas falharem: bloqueia a apuração, notifica o operador e exige entrada manual com dupla conferência registrada em auditoria. Resultado sintético é proibido por design — não existe caminho de código que o produza.

### Carimbo do tempo

```typescript
export interface AutoridadeDeCarimbo {
  carimbar(hash: Buffer): Promise<Result<TokenRFC3161>>;
  verificar(token: TokenRFC3161, hash: Buffer): Promise<boolean>;
}
```

---

## 8. API — principais endpoints

### Público

```
GET  /api/campanhas/:slug                    dados da campanha + estoque restante
POST /api/pedidos                            cria pedido e reserva (Idempotency-Key)
GET  /api/pedidos/:id                        status + Pix copia-e-cola
POST /api/comprador/acesso/solicitar         CPF + canal → dispara código (rate limit)
POST /api/comprador/acesso/verificar         código → sessão de 30 dias
POST /api/comprador/acesso/sair              revoga a sessão
GET  /api/comprador/painel                   campanhas, estados e prêmios (autenticado)
GET  /api/comprador/comprovantes              provas reunidas (autenticado)
GET  /api/comprador/dados                     dados pessoais e consentimentos (autenticado)
POST /api/comprador/dados/exclusao            solicita exclusão — crypto-shredding (autenticado)
GET  /api/campanhas/:slug/commitment         raiz, total, carimbo
GET  /api/campanhas/:slug/snapshot.ndjson    lista canônica (pós-apuração)
GET  /api/pedidos/:id/comprovante            números + prova de inclusão
GET  /api/campanhas/:slug/apuracao           resultado vigente + retificações + log da regra
GET  /api/campanhas/:slug/entrega            status da entrega (sem PII do ganhador)
POST /api/entrega/:token/confirmar           ganhador confirma recebimento (link autenticado)
```

### Autenticação do operador (R0)

```
POST /api/auth/login                         e-mail + senha → desafio de 2º fator
POST /api/auth/2fa/verificar                 código TOTP → sessão
POST /api/auth/2fa/ativar                    primeiro acesso: confirma TOTP e emite códigos de recuperação
POST /api/auth/2fa/recuperar                 entra com código de recuperação de uso único
POST /api/auth/senha/esquecer                envia token de redefinição por e-mail
POST /api/auth/senha/redefinir               redefine com token de uso único
POST /api/auth/logout                        invalida a sessão corrente
POST /api/auth/refresh                       rotaciona o token de acesso
```

Nenhuma rota `/api/admin/*` responde sem sessão com 2º fator verificado. `login` **nunca**
emite sessão utilizável sozinho: devolve apenas o desafio do segundo fator. Falha de login
não distingue "e-mail inexistente" de "senha errada" — a mensagem é sempre a mesma, para
não confirmar cadastro a quem sonda.

### Admin (2FA obrigatório)

```
POST  /api/admin/campanhas
PATCH /api/admin/campanhas/:id
POST  /api/admin/campanhas/:id/publicar
POST  /api/admin/campanhas/:id/congelar
GET   /api/admin/campanhas/:id/metricas
GET   /api/admin/relatorios/arrecadacao?de=&ate=&formato=xlsx
POST  /api/admin/campanhas/:id/entrega       registra entrega do prêmio + comprovante
POST  /api/admin/campanhas/:id/retificar     retificação de apuração (dupla autorização)
GET   /api/admin/conta-recebimento           conta ativa e situação da verificação
POST  /api/admin/conta-recebimento           cadastra/troca (exige 2º fator)
POST  /api/admin/conta-recebimento/verificar dispara verificação de titularidade
GET   /api/admin/estornos-pendentes          fila de estornos que falharam, com total devido
POST  /api/admin/estornos-pendentes/:id/retry  nova tentativa após regularizar saldo
GET   /api/admin/apuracoes                   estado da apuração de todas as campanhas
GET   /api/admin/apuracoes/:id/tentativas    histórico de obtenção da extração, com falhas
POST  /api/admin/apuracoes/:id/reprocessar   nova tentativa imediata na fonte oficial
POST  /api/admin/apuracoes/:id/manual        entrada manual assistida (exige 2 responsáveis)
POST  /api/admin/apuracoes/:id/confirmar     segunda confirmação de manual ou retificação
GET   /api/admin/operadores                  operadores do tenant, com situação (ativo/desligado)
POST  /api/admin/operadores/:id/desativar    desliga: revoga sessões e bloqueia login (exige 2º fator)
```

`desativar` **não** apaga o operador — carimba `desativado_em` e revoga as sessões na mesma
transação. Não existe rota de exclusão: a anonimização acontece por prazo, executada pelo
worker de retenção, nunca a pedido pela API. Expor um botão que apaga o autor de uma apuração
manual seria entregar ao fraudador o apagador do próprio rastro.

### Webhook

```
POST /webhooks/psp/:provedor
```

`POST /api/pedidos` exige header `Idempotency-Key`. Chave em Redis com TTL de 24h guarda a resposta: retry da mesma chave devolve o mesmo pedido em vez de reservar números de novo.

---

## 9. Segurança e LGPD

| Controle | Implementação |
|---|---|
| Validação de entrada | Zod em todo boundary; nada de `any` cruzando camada |
| SQL Injection | Query builder parametrizado; zero concatenação |
| Rate limit | Redis: 10 req/min por IP no checkout, 5/min na consulta por CPF |
| Autenticação admin | Argon2id na senha; JWT curto + refresh rotativo; TOTP obrigatório (RFC 6238); sessão sem 2º fator não autoriza rota admin |
| Força bruta de login | Bloqueio temporário por tentativas; resposta idêntica para e-mail inexistente e senha errada |
| Segredo do TOTP | Cifrado em coluna, sob a mesma chave externa dos demais segredos |
| Autorização | Guard por rota + verificação de `tenant_id` no repositório |
| Segredos | Variáveis de ambiente; `salt_campanha` e `salt_cpf_tenant` em coluna cifrada sob KEK externa — nunca no ambiente da aplicação |
| Derivado de CPF | Argon2id (`m=64MiB, t=3, p=1`) com salt por tenant (índice) e por campanha (leaf), nunca o mesmo salt nos dois |
| Transporte | TLS 1.3 obrigatório, HSTS |
| Cabeçalhos | CSP, X-Frame-Options, X-Content-Type-Options |
| PII em log | Redator de CPF/telefone/e-mail no logger, aplicado no transporte |
| Direito ao esquecimento (comprador) | Crypto-shredding: PII cifrada por titular; apagar a chave inutiliza o dado sem quebrar o hash chain da auditoria |
| Eliminação (operador) | Base contratual, não consentimento: desligamento revoga acesso, anonimização in-place ao fim do prazo legal. Nunca `DELETE` — as FKs sustentam o ADR-16 |
| Retenção | Snapshot público retém apenas número + leaf hash + timestamp; `ip`/`user_agent` de sessão expurgados em D+90 por worker diário |
| Consentimento | Versão do termo, timestamp e IP gravados na aceitação |

O crypto-shredding é o que permite atender exclusão de dados sem destruir a trilha de auditoria — apagar linha de tabela append-only quebraria a cadeia de hash e invalidaria todo o produto.

### Inventário de PII — onde o dado do titular vive, e o que sobra após o shredding

O crypto-shredding só funciona se **todo** local que guarda PII estiver coberto. Um único campo em claro fora do esquema de chave anula a garantia. Inventário completo:

| Local | Conteúdo | Sob a chave do titular? | O que resta após apagar a chave |
|---|---|---|---|
| `comprador` | nome, CPF, nascimento, telefone, e-mail | ✅ cifrado sob a DEK do titular | Registro ilegível; `id` e FKs intactos |
| `comprador.chave_dek_cifrada` | a própria chave do titular | — é o alvo | Apagada. É a operação de shredding, não um efeito dela |
| `comprador.cpf_indice` | Argon2id(CPF, salt por tenant) | ❌ pseudônimo, fora da chave do titular | Mantido por necessidade: sustenta o limite por CPF e a consulta do comprador. Custo de derivação torna a enumeração dos ~10⁹ CPFs válidos inviável mesmo com o salt vazado (ver abaixo) |
| `pedido` | nenhuma PII direta | — | Intacto (valores, status, timestamps) |
| `entrega_premio.ganhador_cifrado` | identificação do ganhador | ✅ cifrado | Ilegível; `numero_apurado`, datas e status **preservados** |
| `entrega_premio.confirmado_ip_cifrado` | IP do aceite | ✅ cifrado junto | Ilegível |
| `entrega_premio.comprovante_uri` | documento/foto | ✅ objeto cifrado | Objeto inacessível; a URI permanece como referência morta |
| `auditoria.dados` | payload das transições | ✅ campos PII cifrados | Hash chain **intacto** — é o ponto central |
| `snapshot.ndjson` | número + leaf + timestamp | ❌ não contém PII | Intacto por design; o leaf usa `Argon2id(cpf, salt_campanha)` e o salt nunca é publicado (ver abaixo) |
| `webhook_evento.payload` | payload bruto do PSP (pode conter nome/CPF) | ✅ cifrado na gravação | Ilegível; a idempotência usa `(provedor, evento_id)`, que não é PII |
| `operador` | e-mail, nome, hash de senha, segredo TOTP | ❌ fora do shredding — **anonimização in-place** | Linha preservada (`id`, `tenant_id`, FKs); `email`/`nome` substituídos por marcador, `senha_hash`/`totp_secret_cifrado` zerados. Auditoria continua atribuindo o ato a um sujeito estável |
| `sessao` | IP e user-agent do operador | ❌ fora do shredding — **expurgo por prazo** | `ip` e `user_agent` viram `NULL` em D+90; `id`, `operador_id` e as datas permanecem, sustentando o histórico de acesso sem o rastro de localização |
| `extracao_tentativa` | sem PII de comprador | ❌ | Intacto — é registro de auditoria operacional |
| Logs | redator de PII no transporte | ❌ nunca grava PII | Nada a apagar |

#### O derivado do CPF é o furo mais provável — e HMAC não o fecha

`cpf_indice` é o único campo que **precisa** sobreviver ao shredding: sem ele não há limite por
CPF (o comprador excluído voltaria a comprar sem teto) nem consulta "meus números". Ele é, por
construção, um pseudônimo — dado pessoal pseudonimizado segue sendo dado pessoal (art. 12, §2º),
então a proteção precisa vir da matemática, não do rótulo.

A v1.x dizia "HMAC do CPF, não reversível sem a chave global". Isso é meia-verdade, e a metade
falsa é a que importa:

| Premissa da v1.x | O que é de fato |
|---|---|
| "10¹¹ CPFs possíveis" | ~10⁹. Os dois dígitos verificadores são determinísticos — o espaço real é o dos 9 primeiros dígitos |
| "não reversível sem a chave" | Correto, e irrelevante. Quem obtém o dump obtém a chave: ambos vivem no mesmo ambiente. O modelo de ameaça é *vazamento conjunto* |
| "HMAC basta" | HMAC-SHA256 é projetado para ser **rápido**. ~10⁹ candidatos numa GPU comum é trabalho de minutos. O CPF inteiro da base é recuperado |
| Chave **global** | Um único comprometimento expõe todos os tenants e todas as campanhas, e nenhum shredding individual reduz o dano |

Três mudanças, cada uma fechando uma das linhas:

1. **Argon2id no lugar de HMAC** (`m=64MiB, t=3, p=1`). O custo deixa de ser desprezível: a mesma
   enumeração passa de minutos para escala inviável, porque cada tentativa custa 64 MiB de memória.
   O preço é real e aceito — ~50ms por derivação, no checkout e na consulta, ambos já com rate
   limit. Não está em caminho quente de alocação.
2. **Salt por tenant, não global.** Vazamento fica contido no tenant, e o custo de ataque não é
   amortizável entre bases — quem quebra um tenant recomeça do zero no próximo.
3. **Salt em coluna cifrada sob a mesma KEK externa** do `salt_campanha`, nunca em variável de
   ambiente da aplicação. Dump do Postgres sozinho não carrega o salt.

**O que isto não resolve, e é honesto declarar:** contra um alvo *específico* — "o CPF 123… está
nesta base?" — nenhuma derivação protege. Uma única verificação custa 50ms. A defesa é contra
recuperação **em massa**, que é o cenário de vazamento real; confirmação pontual de um CPF já
conhecido continua possível e é risco aceito.

**Coerência com o leaf do snapshot (§6).** O leaf usa a mesma primitiva com `salt_campanha` —
por campanha, escopo ainda menor. São dois salts distintos de propósito distinto: `cpf_indice`
vive no banco e serve à operação; o leaf é **publicado** e serve à verificação pública. Nunca
compartilham salt: reusar permitiria cruzar o snapshot público com a base e reidentificar
compradores por interseção.

#### Dado do operador: outro titular, outro regime

As duas linhas acima são as únicas do inventário que **não** entram no crypto-shredding, e a
razão não é que deixaram de ser dado pessoal — é que o titular é outro e a base legal é outra.
O operador é titular pela LGPD tanto quanto o comprador; o que muda é que o tratamento se apoia
em **execução de contrato** (art. 7º, V), não em consentimento. Consequência prática: ele não
pode revogar o tratamento a pedido enquanto o contrato vigora (art. 18, §2º) — o que ele tem é
o direito à **eliminação ao término do tratamento** (art. 16). Prazo e gatilho, não botão.

Colocá-lo sob a chave do titular-comprador seria pior que inútil: um comprador exercendo o
esquecimento apagaria as credenciais do operador da campanha.

E há um conflito que o shredding não resolveria de forma alguma. `auditoria.operador_id` e
`extracao_tentativa.operador_id` são FK: se apagar o operador significasse `DELETE`, sumiria
**quem autorizou a entrada manual da extração** — exatamente o controle que o ADR-16 exige
(dois responsáveis distintos). Um controle antifraude que se apaga a pedido do fraudador não é
controle. Daí o desenho em dois tempos:

| Momento | Gatilho | O que acontece | O que sobrevive |
|---|---|---|---|
| **Desligamento** | Operador sai da organização | `desativado_em` preenchido; todas as `sessao` revogadas na mesma transação; login rejeitado | Tudo. É revogação de acesso, não eliminação de dado |
| **Anonimização** | 5 anos após o desligamento (prescrição do art. 206 CC para pretensão civil), ou antes se nenhuma campanha do tenant estiver sob prazo legal | `email` → `anon+<id>@invalido.local`, `nome` → `Operador removido`, `senha_hash` → string vazia, `totp_secret_cifrado` → `NULL`, `anonimizado_em` carimbado | `id`, `tenant_id`, `criado_em` e **todas as FKs**. A auditoria segue dizendo *que ato foi de qual sujeito*, sem dizer *quem é a pessoa* |

A anonimização é `UPDATE`, nunca `DELETE`, e é a razão do `CHECK (anonimizado_em IS NULL OR
desativado_em IS NOT NULL)`: não existe caminho que anonimize alguém que ainda pode fazer login.
Ela também é registrada em `auditoria` como qualquer outra transição — o ato de eliminar é ele
próprio auditável, senão vira a porta dos fundos que o resto do capítulo fecha.

**Sessão.** `ip` e `user_agent` são dado pessoal do operador e não têm base contratual para
persistir indefinidamente: existem para investigar acesso indevido. Noventa dias cobrem a janela
realista de detecção e mantêm a tabela longe de virar histórico de localização. O worker de
expurgo roda no mesmo BullMQ do worker de expiração, uma vez por dia:

```sql
UPDATE sessao
   SET ip = NULL, user_agent = NULL, purgada_em = now()
 WHERE purgada_em IS NULL AND purgar_em <= now();
```

A linha permanece: `operador_id`, `criada_em`, `segundo_fator_em` e `revogada_em` continuam
respondendo *quando* e *se com 2º fator* houve acesso — que é o valor de auditoria — sem o
*de onde*. `comprador_sessao` tem os mesmos campos e entra no mesmo expurgo; a PII do comprador
sob a chave dele é o que o shredding cobre, o IP da sessão dele não é.

**Onde isso pode dar errado:** o expurgo que não roda é indistinguível do expurgo que roda, até
alguém olhar. Por isso a métrica `sessoes_pendentes_expurgo_gauge` (§10) e o alerta quando ela
passa de zero por mais de 48h — política de retenção sem monitor é declaração de intenção.

**A invariante que precisa ser provada, não assumida:** apagar a chave de um titular deixa `auditoria` **verificável de ponta a ponta**. Isso é possível porque a cadeia encadeia o *hash do registro*, e o registro cifrado não muda quando a chave some — some a capacidade de **ler**, não o **byte**. Se o hash fosse calculado sobre o texto claro, o shredding quebraria a cadeia.

**Teste obrigatório (`crypto-shredding`)**, roda no CI:

1. Popular campanha completa: comprador, pedido pago, apuração, entrega confirmada, ~50 registros de auditoria.
2. Verificar a cadeia de auditoria fim a fim → deve validar.
3. Apagar a chave do titular.
4. **Verificar a cadeia de novo → deve validar igual.** Este é o passo que a v1.1 não provava.
5. Recomputar a raiz Merkle do snapshot → deve bater com a raiz carimbada.
6. Confirmar que nenhum campo do titular é legível em nenhuma das tabelas do inventário.
7. Confirmar que `entrega_premio` mantém `numero_apurado` e o status público legíveis — a prova de entrega sobrevive à exclusão do dado pessoal.
8. **Anonimizar um operador** que autorizou entrada manual da extração → `extracao_tentativa.operador_id` continua resolvendo, a cadeia de auditoria continua validando, e nenhum campo identificável dele sobrevive em qualquer tabela.
9. **Antecipar o relógio em 91 dias** e rodar o worker de expurgo → `ip` e `user_agent` de `sessao` e `comprador_sessao` estão `NULL`, `segundo_fator_em` e `revogada_em` intactos.
10. **Após o shredding, o limite por CPF continua valendo**: novo pedido com o CPF do titular excluído é recusado por `LIMITE_CPF_EXCEDIDO`, provando que `cpf_indice` sobreviveu e ainda casa.
11. **Salts não colidem**: `Argon2id(cpf, salt_cpf_tenant) != Argon2id(cpf, salt_campanha)` para o mesmo CPF — o teste falha se alguém unificar os salts numa refatoração.

O passo 7 é o que concilia LGPD com R8.5: o titular exerce o direito ao esquecimento **sem** apagar a prova de que o prêmio foi entregue. O que era público (número, data, status) continua público; o que era pessoal (quem) fica ilegível.

---

## 10. Observabilidade

- **Logs** estruturados JSON com `correlation_id` propagado do request ao worker
- **Métricas** (Prometheus): `pedidos_criados_total`, `pedidos_pagos_total`, `numeros_alocados_duration_seconds`, `webhook_processamento_duration_seconds`, `estoque_disponivel_gauge`, `sessoes_pendentes_expurgo_gauge`
- **Tracing** OpenTelemetry no caminho checkout → PSP → webhook → atribuição
- **Health checks**: `/health/live`, `/health/ready` (Postgres, Redis, PSP)

**Alertas que importam**
| Condição | Severidade |
|---|---|
| Taxa Pix gerado→pago < 30% em 1h | Alta |
| Webhook não processado > 5 min | Crítica |
| Falha ao carimbar commitment | Crítica |
| Fonte da Federal indisponível em dia de apuração | Crítica |
| Autorização da campanha vence em < 7 dias | Média |
| `sessoes_pendentes_expurgo_gauge` > 0 por mais de 48h | Média |

---

## 11. Estratégia de testes

Meta: **> 90% global, 100% no domínio.** O domínio não tem I/O — não há desculpa para menos que 100%.

| Nível | Ferramenta | Escopo |
|---|---|---|
| Unitário | Vitest | Agregados, VOs, políticas, Merkle. Sem mocks: domínio é puro |
| Integração | Vitest + Testcontainers | Repositórios contra Postgres real. **SQLite não reproduz `SKIP LOCKED`** |
| Contrato | Pact ou fixtures gravadas | Adapters de PSP e Federal |
| E2E | Playwright | Fluxo comprar → pagar → verificar |
| Carga | k6 | 500 req/s no checkout por 60s |

### Regra de verificação para código assistido por IA

Todo o código é escrito com assistência de IA. Isso é ganho real na maior parte do sistema, mas cria um modo de falha específico: **o gerador e o verificador compartilham o ponto cego** quando a mesma sessão escreve o código e o teste. O teste passa porque testa o que o autor pensou, não o que o requisito exige.

Onde isso é apenas incômodo (CRUD, DTO, tela), segue o fluxo normal. Onde o erro é silencioso e destrói o produto — **R2 (concorrência), R4 (commitment), R6 (apuração)** — vale o protocolo abaixo:

| Regra | Motivo |
|---|---|
| Vetores de teste **externos** para Merkle (RFC 6962) e RFC 3161, não gerados na sessão | Implementação errada e teste errado concordam entre si. Vetor publicado não concorda com nenhum dos dois |
| Teste de concorrência escrito **antes** do alocador, e rodado contra uma implementação deliberadamente ingênua para provar que ele falha | Teste de corrida que nunca falhou não prova nada — pode estar testando serialização acidental |
| Revisão humana da **invariante**, não do diff | A IA acerta a sintaxe do lock e erra qual é o predicado que precisa ser atômico |
| Nenhum `--force` / skip em teste de concorrência no CI | O teste é flaky-por-natureza; a tentação de silenciar é o começo do incidente |
| Cripto: comparar contra implementação de referência independente (ex.: recomputar a raiz em Python) | Duas implementações independentes concordando é evidência; uma implementação passando no próprio teste não é |

**Resumo:** a IA escreve; a aceitação vem de fonte que a IA não produziu.

### Testes obrigatórios de concorrência

Não é opcional. Rodam em CI a cada PR:

1. **Sem duplicação**: 200 clientes concorrentes reservando 50 números cada em estoque de 5.000 → soma exata de 5.000, zero repetição.
2. **Estoque insuficiente**: estoque de 10, dois pedidos simultâneos de 8 → exatamente um sucesso.
3. **Idempotência de webhook**: 10 entregas do mesmo evento → uma transição, um conjunto de números.
4. **Corrida expiração vs. pagamento**: pagamento chegando no exato instante da expiração → resultado determinístico, nunca inconsistente.
5. **Integridade do Merkle**: 10.000 folhas, todas as provas validam; qualquer byte alterado invalida. Raiz conferida contra recomputação independente e contra os vetores da RFC 6962.
6. **Casos degenerados da apuração**: snapshot vazio, 1 número vendido, acerto direto, todos vendidos, e número duplicado (deve **abortar**, não escolher).
7. **Expiração em lote**: 50.000 reservas vencendo simultaneamente → worker drena em lotes sem bloquear alocação concorrente.
8. **Crypto-shredding**: cadeia de auditoria válida antes E depois de apagar a chave do titular; raiz Merkle inalterada; prova de entrega preservada (7 passos da §9).
9. **Bloat sob churn**: campanha simulada com 45% de expiração → `pct_morto < 10%` e p95 da alocação < 300ms.
10. **Retificação de apuração**: retificar sem motivo/autorização é rejeitado; snapshot e commitment permanecem intactos; a apuração original continua pública; retificar após entrega confirmada é bloqueado.
11. **Conferência pós-apuração**: extração de concurso/data divergente do configurado → apuração NÃO publica e entra em `PENDENTE`.
12. **Sessão sem 2º fator**: token emitido no login, sem verificar TOTP, é rejeitado em toda rota `/api/admin/*`.
13. **Entrada manual assistida**: só é aceita após falha registrada das duas fontes; com um só responsável é rejeitada; a extração informada é gravada em `extracao_tentativa` com o operador.
14. **Estorno sem saldo**: PSP recusa por saldo insuficiente → pedido vai para `ESTORNO_PENDENTE`, nunca `ESTORNADO`; registro criado com o valor devido; retry posterior com saldo resolve e fecha.
15. **Acesso do comprador**: código expirado, já usado, ou após 5 tentativas é rejeitado; CPF inexistente e CPF sem compras devolvem resposta idêntica; rate limit corta flood por CPF e por IP.
16. **Publicação sem conta de recebimento**: campanha sem conta verificada não publica; conta com CNPJ divergente do organizador é recusada na verificação.

---

## 12. Decisões de arquitetura (ADRs resumidas)

| # | Decisão | Alternativa descartada | Motivo |
|---|---|---|---|
| ADR-01 | Monolito modular | Microsserviços | 1 dev, 6 semanas. Corte por módulo preserva extração futura |
| ADR-02 | Números pré-embaralhados em tabela | `ORDER BY random()` | Aleatoriedade resolvida uma vez; alocação vira O(log n) |
| ADR-03 | `FOR UPDATE SKIP LOCKED` | Lock distribuído em Redis | Postgres já garante; menos componente, menos falha |
| ADR-04 | Merkle RFC 6962 | Hash simples da lista | Prova de inclusão individual em 640 bytes vs. download de 40MB |
| ADR-05 | Carimbo RFC 3161 (ICP-Brasil) | Blockchain / OpenTimestamps | Validade probatória sob MP 2.200-2/2001; interlocutor é fiscal brasileiro, não cypherpunk |
| ADR-06 | Outbox transacional | Publicação direta de evento | Elimina "pago mas sem número" |
| ADR-07 | Pix exclusivo | Pix + cartão | Cartão custa 2 semanas em antifraude e chargeback para <10% do volume |
| ADR-08 | `tenant_id` desde o dia 1 | Adicionar depois | Migração de multi-tenancy em base com dados reais é o pior refactor possível |
| ADR-09 | Enquadramento como dado, não código | Hardcode do regime | Troca de regime regulatório não exige redeploy |
| ADR-10 | Campanha encerra na entrega, não na apuração | Encerrar em `APURADA` | O vetor de fraude do caso Buzeira é a atribuição/entrega, não o sorteio. Provar metade do percurso torna o selo falso |
| ADR-11 | Teto de 1M números na v1, com `CHECK` como fonte única | `CHECK` permissivo de 10M | Teto acima do que o alocador atual sustenta é promessa que o banco aceita e o sistema não cumpre |
| ADR-12 | Código de concorrência/cripto não é aceito contra teste da mesma sessão de IA | Confiar na suíte gerada junto | Gerador e verificador correlacionados compartilham o mesmo ponto cego; em R2/R4/R6 o erro é silencioso e caro |
| ADR-13 | Apuração errada é corrigida por retificação pública, nunca por edição | Apuração absolutamente imutável, sem correção | Imutável sem saída não é rigor: insumo errado (extração de outra data, anulação da CAIXA) deixaria o operador honesto sem caminho e daria ao desonesto o argumento de que "o sistema travou". Retificação com causa fechada + dupla autorização + original preservada corrige sem abrir espaço para fraude |
| ADR-14 | `fillfactor` + autovacuum por tabela em `numero_sorte` antes de particionar | Particionar por campanha desde já | 1M por campanha e 1 cliente não justificam a complexidade; o gatilho de particionamento fica registrado com critério medido |
| ADR-15 | Sessão só autoriza rota admin **após** o 2º fator verificado | Emitir sessão válida no login e checar 2FA por middleware | O estado intermediário existe de qualquer forma; torná-lo explícito na tabela impede que um bug de middleware libere tudo com só a senha |
| ADR-16 | Entrada manual da extração exige dois responsáveis distintos | Um operador com confirmação dupla na mesma sessão | O controle existe contra erro de digitação e contra ação unilateral. Duas confirmações do mesmo humano não protegem de nenhum dos dois |
| ADR-17 | **Sem custódia**: Pix cai direto na conta do operador | Conta da plataforma com repasse (escrow) | Custodiar recurso de terceiro em operação de sorteio aproxima a bit4devs do risco regulatório do operador — mais gravemente que o percentual que Q5 já recusa. Exige licença e controles que o prazo do MVP não comporta |
| ADR-19 | Comprador entra por código de uso único, nunca por senha | Conta com e-mail e senha | Senha vira o principal motivo de suporte num público que compra em 60s e volta raramente. O código prova posse do canal — o que basta — sem campo extra no checkout nem fluxo de recuperação |
| ADR-18 | `ESTORNO_PENDENTE` como estado de primeira classe | Retry silencioso até conseguir | Consequência direta da ADR-17: sem custódia o estorno falha de verdade. Estado explícito força o produto a tratar o pior incidente possível — dinheiro recebido, número não entregue — em vez de escondê-lo em log |
| **ADR-20** | **App Expo/RN como superfície primária; web reduzida a página pública + admin** | PWA mobile-first sobre o Next.js | O público compra por celular e volta pelo link. PWA custaria menos, mas empurra push, ícone na home e sessão longa para o terreno mais frágil do iOS. **Custo assumido: +1 semana e a fila da loja** — ver §13 |
| **ADR-21** | **PicPay como PSP único do MVP** | Asaas/Celcoin (adapters da spec anterior) | Decisão do operador. A porta `GatewayDePagamento` já existia, então a troca custou o adapter, não a arquitetura — a prova de que a porta valeu o preço |
| **ADR-22** | **Derivado de CPF é Argon2id com salt por escopo** | HMAC-SHA256 com chave global (v1.x) | O espaço real de CPFs é ~10⁹ (dígitos verificadores são determinísticos) e HMAC é rápido por projeto: dump + chave no mesmo ambiente devolve a base inteira em minutos de GPU. Argon2id troca ~50ms por derivação — fora de caminho quente — por inviabilidade de enumeração em massa. Salt por tenant no índice e por campanha no leaf contém o raio de dano e impede cruzar o snapshot público com a base |
| **ADR-23** | **Operador se anonimiza, não se apaga** | `DELETE` na linha do operador | `auditoria.operador_id` e `extracao_tentativa.operador_id` são FK: apagar destruiria a atribuição de quem autorizou a entrada manual da extração — o controle do ADR-16. Um antifraude que o fraudador apaga a pedido não é controle |
| **ADR-22** | **Confirmação de pagamento reconsulta o PSP; o corpo do webhook não é fonte de verdade** | Confiar no payload autenticado pelo token | O webhook do PicPay é autenticado por token estático, **não assinado**: prova o chamador, não a integridade do corpo. Sem a reconsulta, um corpo forjado vira número entregue sem dinheiro |
| **ADR-23** | **Node 24 LTS + TypeScript 5.9** | Node 22 (spec anterior) / TypeScript 7.x | 22 saiu de Active LTS. TS 7 é `latest` mas o ecossistema de decorators do NestJS e o Metro do RN ainda não seguiram; risco de terceiro no caminho crítico sem ganho de produto |
| **ADR-24** | **SQL parametrizado + migrations `.sql`, sem ORM** | Prisma | `SKIP LOCKED`, `COPY` de 1M linhas e hash chain são SQL de qualquer forma. Além disso a `latest` do Prisma hoje é RC — dependência instável no núcleo de valor |

---

## 13. Plano de execução — 6 semanas

> **Como este plano foi dimensionado.** Todo o código é assistido por IA. O ganho foi aplicado onde ele existe (boilerplate, testes, telas, adapters, migrations) e **não** foi aplicado onde não existe (espera por terceiro, verificação de concorrência e cripto). O resultado não foi comprimir 4 semanas em 3 — foi tornar o prazo realista com uma folga nomeada, em vez de um cronograma sem folga nenhuma. **A v1.6 acrescentou uma semana por escopo novo (app), não por reestimativa do que já existia.** Ver a tabela de produtividade na §0 do PRD.

> ### ⚠️ O prazo mudou de 5 para 6 semanas — e a razão precisa estar escrita
>
> A decisão de ir a app nativo (ADR-20) **não cabia nas 5 semanas**. As telas em si são baratas com IA;
> o que não é barato, e não encolhe com assistência, é o que está fora do editor:
>
> | Custo novo | Por que a IA não encurta |
> |---|---|
> | Conta Apple Developer + Google Play, certificados, perfis | Relógio de terceiro (~US$ 99/ano + prazo de aprovação da conta) |
> | **Primeira revisão da App Store** | Fila da Apple: dias, e **rejeição é provável na primeira submissão de app de sorteio** |
> | Build EAS, assinatura, versionamento, canais de OTA | Configuração de pipeline, uma vez, sem atalho |
> | Deep link / universal link (link da campanha abre o app) | Verificação de domínio nos dois sistemas operacionais |
>
> **Risco nomeado: política de loja.** Apple (guideline 4.7 / jogos de azar) e Google tratam sorteio
> pago com escrutínio: costumam exigir comprovação de conformidade legal do operador e restrição
> geográfica. **A autorização SEAE/SPA que a campanha já precisa ter (R1) é o que sustenta essa
> defesa** — por isso ela vira insumo de submissão, não só de compliance. Mesmo assim, a aprovação
> **não está sob controle do time**.
>
> **Mitigação que preserva a data de go-live:** a campanha continua vendendo pelo link web desde o
> primeiro dia (é a mesma API). O app é a superfície primária do produto, mas **não é caminho único de
> compra na v1** — se a loja atrasar, o negócio não para. Tornar o app bloqueante do go-live seria
> colocar a data de faturamento do cliente na fila de revisão da Apple.
>
> **Recomendação, se 6 semanas não for aceitável:** cortar o app da v1 e entregar a web mobile-first
> em 5 semanas, com o app em v1.1. O que **não** funciona é manter 5 semanas *e* o app — nesse cenário
> o que cede é a semana de folga e, depois dela, os testes de concorrência e cripto, que são
> exatamente a tese do produto.

### Semana 1 — Fundação e domínio

| Dia | Entrega |
|---|---|
| 1 | Repo (monorepo `apps/api` + `apps/app` + `apps/web`), Docker Compose, CI, ESLint com regra de dependência, conventional commits, husky |
| 1 | **Em paralelo, no dia 1, três relógios de terceiro:** (a) conta PicPay + credenciais de sandbox; (b) contratação da ACT (ICP-Brasil); (c) **contas Apple Developer e Google Play**. Todos bloqueiam; nenhum encurta com IA. A conta de loja é a que tem o prazo mais imprevisível — abrir no dia 1, não na semana 5 |
| 2–3 | Domínio `Campanha`, `NumeroDaSorte`, VOs, eventos. 100% de cobertura |
| 3–4 | Migrations, repositórios, geração de estoque com `COPY` |
| 5 | Teste de carga da geração de 1M; admin de campanha (CRUD + publicar) |

**Definition of done:** campanha publicada gera 1M de números em < 60s, com teste de integração provando.

### Semana 2 — Checkout e Pix

| Dia | Entrega |
|---|---|
| 6–7 | Domínio `Pedido` + máquina de estados + limite por CPF. 100% |
| 7–8 | Alocação com `SKIP LOCKED` + **testes de concorrência (bloqueante)** |
| 8–9 | **`PicPayGateway`**: OAuth com cache/lock do token de 5 min, `POST /charge/pix`, reconsulta (ADR-22), webhook idempotente com token em tempo constante; outbox |
| 9–10 | Worker de expiração **com consulta ao PSP antes de expirar**; **app: onboarding do Expo, navegação, tela da campanha, pacotes, checkout, tela de Pix com copia-e-cola** |

**Definition of done:** comprar → pagar Pix no sandbox do PicPay → números atribuídos, ponta a ponta **pelo app em emulador**, com E2E verde. Testes de concorrência passando. **Teste obrigatório: webhook com corpo adulterado e token válido não atribui números** (prova a ADR-22).

### Semana 3 — Apuração verificável

| Dia | Entrega |
|---|---|
| 11–12 | Merkle RFC 6962 + geração de prova. 100% de cobertura, com vetores de teste |
| 12–13 | Congelamento, snapshot canônico, carimbo RFC 3161 |
| 13–14 | Fonte da Federal (2 adapters + manual assistida); regra de aproximação com log |
| 14–15 | Verificador público estático (**web** — é a peça que precisa ser auditável sem instalar nada); comprovante com prova; **"Meus números" no app**, com acesso por código de uso único (ADR-19) |

**Definition of done:** apuração completa ensaiada com 10.000 números sintéticos e verificada por uma segunda pessoa usando só o verificador público.

### Semana 4 — Apuração, entrega e compliance

| Dia | Entrega |
|---|---|
| 16 | Apuração automática + 5 casos degenerados + conferência pós-apuração e retificação |
| 16–17 | **Entrega do prêmio (R8.5)**: registro, confirmação do ganhador, `ENTREGA_PENDENTE` |
| 17–18 | Cadastro 18+, validação de CPF, consentimento LGPD, auditoria com hash chain, **teste de crypto-shredding** |
| 18–19 | Painel do operador, exportações, relatório de arrecadação |
| 19–20 | Rate limit, cabeçalhos de segurança, redator de PII, revisão OWASP Top 10 |

**Definition of done:** ciclo completo apuração → entrega → encerramento, com os casos degenerados verdes.

### Semana 5 — App: fechamento, build e submissão

| Dia | Entrega |
|---|---|
| 21–22 | Deep link/universal link (link da campanha abre no app), estados de erro e offline, acessibilidade do app |
| 22 | **E2E do app com Maestro** nos fluxos do Gherkin: comprar → Pix → números → comprovante |
| 23 | Pipeline `eas build` (Android + iOS), assinatura, canal de OTA, ícone/splash/store listing |
| 24 | **Submissão às duas lojas** — com a autorização SEAE/SPA anexada como comprovação de conformidade |
| 25 | Build web mobile-first paritário (o caminho de compra que não depende de aprovação de loja) |

**Definition of done:** app submetido às duas lojas, **e** compra completa funcionando pelo navegador
mobile sem o app. A segunda metade é o que impede a fila da Apple de virar risco de faturamento.

> **A submissão não é gate de go-live.** Se a loja rejeitar, o ciclo de correção roda na semana 6 e,
> se não fechar, na v1.1 — com a campanha já vendendo pela web. Rejeição na primeira submissão de app
> de sorteio é o cenário esperado, não a exceção.

### Semana 6 — Hardening, go-live e folga

| Dia | Entrega |
|---|---|
| 26–27 | Teste de carga k6; ajuste de índices e pool; expiração em lote; **medição de bloat sob churn** |
| 27–28 | Deploy, domínio, TLS, backup automatizado, runbook de incidente (**incluindo rotação do token de webhook do PicPay**) |
| 28–29 | Treinamento do operador; ensaio de apuração em produção com dados sintéticos; **resposta a eventual rejeição de loja** |
| 30 | **Folga.** Reservada para o imprevisto que sempre aparece — não para escopo novo |

**Definition of done:** campanha real publicada, com runbook de incidente escrito e operador treinado.

**Regra da folga:** se a semana 6 chegar sem imprevisto acumulado, ela **não** vira espaço para P1. Vira encerramento antecipado ou ensaio adicional. Folga consumida por escopo novo deixa de ser folga — e o feature freeze em D+35 existe para tornar isso explícito. **A folga da semana 6 é a primeira candidata a absorver um ciclo de rejeição de loja** — motivo a mais para não gastá-la antes.

---

## 14. Definition of Done global

Nada é considerado pronto sem:

- [ ] Cobertura > 90% global, 100% no domínio
- [ ] Testes de concorrência verdes
- [ ] OpenAPI atualizado
- [ ] Migration versionada e reversível
- [ ] Logs estruturados nos caminhos críticos
- [ ] Sem `any`, sem `@ts-ignore`
- [ ] Complexidade ciclomática < 10
- [ ] Conventional commit + PR revisado
- [ ] ADR escrita para toda decisão não óbvia
- [ ] Código de R2/R4/R6 validado contra fonte externa (vetor publicado ou implementação independente), não só contra a própria suíte
- [ ] Nenhum segredo, PII ou CPF em log, snapshot ou artefato público
- [ ] Toda nova tabela com PII entra no inventário da §9 e no teste de crypto-shredding
- [ ] Toda etapa irreversível tem caminho de correção definido (retificação), com limites explícitos do que ela não pode fazer

---

## 15. Fora de escopo — parking lot

Registrado para não virar discussão no meio do sprint: bilhetes premiados instantâneos, logística de entrega do prêmio (a plataforma **registra e prova** a entrega, não a executa), multi-tenant self-service, cartão de crédito, afiliados, ranking de compradores, sorteador próprio, notificação por WhatsApp não-oficial, integração contábil, **segundo PSP** (a porta existe; o adapter só nasce quando houver motivo real), **push notification** (o app sai da v1 sem push — entra na v1.1, depois de a loja aprovar).

> **"App nativo" saiu desta lista** — era item de parking lot na v1.5 e virou a superfície primária na
> v1.6 (ADR-20). Registrado aqui em vez de apagado: quem leu a versão anterior precisa ver que a
> mudança foi decidida, não esquecida.

Regra do kickoff: **qualquer item que entre precisa de um item que saia, ou de extensão explícita de prazo.**

---

**Ø 1 MU1TØ 4L3M DØ CØD1GØ !**
