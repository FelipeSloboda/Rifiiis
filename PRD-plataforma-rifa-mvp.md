# PRD — Plataforma de Rifa com Apuração Verificável

**Codinome interno:** Rifiiis
**Versão:** 1.6
**Data:** 30/08/2026
**Autor:** bit4devs
**Status:** Draft para validação

---

## 0. Premissas deste documento

Este PRD assume o seguinte recorte. Qualquer divergência aqui invalida o cronograma e deve ser corrigida antes do kickoff.

| Premissa | Valor assumido |
|---|---|
| Escopo comercial | 1 operador cliente (single-tenant lógico, schema multi-tenant-ready) |
| Prazo | **6 semanas** corridas até campanha real em produção (5 de execução + 1 de folga nomeada). Era 5 na v1.5; o app nativo (ADR-20 da spec) acrescentou uma semana de escopo — não de reestimativa |
| Time | 1 dev sênior full-time + arquiteto part-time (revisão/ADR) |
| Modo de execução | Desenvolvimento assistido por IA (agentes de código) sob revisão humana obrigatória |
| Meio de pagamento | Pix exclusivamente, via **PicPay** (PSP único do MVP — ADR-21 da spec) |
| Fluxo financeiro | **Sem custódia**: o Pix cai direto na conta do operador no PSP. A plataforma orquestra a cobrança e nunca detém dinheiro de terceiros |
| Sorteio | Loteria Federal (CAIXA) — sem sorteador próprio |
| Enquadramento regulatório | Responsabilidade do cliente; a plataforma **exige e valida** o documento, não o fornece |
| Superfície | **Mobile-first: app Expo/React Native é a superfície primária**; a web cobre a página pública da campanha (link compartilhável) e o admin do operador |
| Reuso interno | Arquitetura de ledger append-only com hash chaining e RFC 3161 já existente; padrões de adapter de PSP (idempotência, máquina de estados de webhook) reaproveitados das skills BaaS |

O reuso desses ativos é o que torna o prazo viável. Sem eles, o prazo realista é 8–9 semanas.

> **Atenção ao reuso do PSP.** A v1.5 contava com as skills Asaas/Celcoin prontas. Com a troca para PicPay, o que se reaproveita é o **padrão** (porta, idempotência, outbox), não o código do adapter — e o PicPay tem duas particularidades que custam tempo próprio: token OAuth de 5 minutos e **webhook sem assinatura**. O ganho de "~4 dias viram ~1" da v1.5 não se transfere inteiro; conte ~2–3 dias.

### Premissa de produtividade com IA — o que a assistência acelera e o que não acelera

Todo o desenvolvimento é assistido por IA. Isso muda a estimativa, mas **não uniformemente** — e tratar o ganho como um multiplicador global sobre o cronograma inteiro é o erro que estoura o prazo.

| Classe de trabalho | Efeito da IA | Exemplos neste projeto |
|---|---|---|
| **Acelera muito (2–4×)** | Código com padrão conhecido e teste verificável | Migrations, DTOs/Zod, CRUD do admin, adapters de PSP, telas do storefront, suíte de testes, OpenAPI, boilerplate de NestJS |
| **Acelera pouco (1–1,3×)** | Exige julgamento de domínio ou verificação difícil | Modelagem dos agregados e invariantes, regra de aproximação, máquina de estados do pedido, desenho do leaf hash |
| **Não acelera (1×)** | Latência externa e trabalho de terceiros — a IA não encurta relógio de outra pessoa | Aprovação da conta no PSP, contratação da ACT/ICP-Brasil, homologação de sandbox, entrega do enquadramento pelo cliente |
| **Pode desacelerar** | Erro plausível e caro de detectar | Concorrência (`SKIP LOCKED`), criptografia (Merkle/RFC 3161), LGPD. Código que *parece* correto e passa em teste ingênuo |

**Consequência para o cronograma:** o caminho crítico deste projeto é dominado pelas duas últimas linhas. As semanas não encolhem na proporção do código escrito, porque o gargalo real é (a) espera por terceiro e (b) verificação de coisa que erro silencioso destrói.

**Regra de uso da IA nas áreas críticas** — vale para R2, R4 e R6:
- Código de concorrência e de criptografia é **escrito com IA, mas aceito só contra teste adversarial e vetor de referência externo** (RFC 6962 test vectors), nunca contra teste gerado pela mesma sessão que escreveu o código.
- Toda decisão de invariante de domínio é revisada por humano antes de virar código, não depois.
- A IA não é fonte de verdade normativa: enquadramento regulatório, contrato da ACT e regra do regulamento do cliente vêm de documento, não de geração.

---

## 1. Problem Statement

Operadores de rifa online no Brasil vendem confiança, mas não conseguem prová-la. Hoje o comprador paga via Pix, recebe uma lista de números por e-mail e não tem nenhuma forma de verificar que (a) o número dele estava de fato na base no momento do sorteio, (b) a base não foi alterada depois da extração da Loteria Federal, ou (c) a regra de aproximação foi aplicada honestamente.

Essa opacidade não é teórica. O caso Buzeira (denúncia do GAECO/MPF, out/2025) documentou exatamente a fraude que ela habilita: quando o número apurado não havia sido vendido, o prêmio era atribuído a "ganhadores laranjas" para que o bem permanecesse com o organizador. O resultado é um mercado inteiro sob suspeita, com MPF apurando o modelo de licenciamento estadual e mais de 20 influenciadores alvos de operação só em 2025.

**Custo de não resolver:** o operador honesto paga o preço reputacional do desonesto. Conversão cai, CAC sobe, e o negócio fica exposto a um evento regulatório que pode encerrá-lo de um dia para o outro.

---

## 2. Objetivos

| # | Objetivo | Métrica de sucesso |
|---|---|---|
| G1 | Tornar a apuração matematicamente auditável por terceiros | 100% das campanhas com commitment carimbado antes da extração; verificação independente reproduz o resultado |
| G2 | Colocar 1 campanha real em produção em 6 semanas | Campanha publicada, vendida e apurada até D+42 |
| G3 | Eliminar risco de dupla alocação de número sob concorrência | Zero números duplicados em teste de carga de 500 req/s |
| G4 | Automatizar a prestação de contas do operador | Relatório mensal gerado sem intervenção manual |
| G5 | Provar o wedge comercial | Cliente renova ou indica após a 1ª campanha apurada |

**Objetivo de negócio da bit4devs:** validar "apuração verificável" como diferencial vendável antes de investir em produto multi-tenant. O MVP é um teste de tese com receita, não um produto final.

---

## 3. Não-objetivos (v1)

| Fora de escopo | Por quê |
|---|---|
| Self-service multi-tenant | O aprendizado vem de 1 cliente operando de verdade, não de 10 cadastros vazios |
| Cartão de crédito e parcelamento | Pix é >90% do volume neste mercado; cartão adiciona antifraude, chargeback e conciliação — 2 semanas sozinho |
| Bilhetes premiados instantâneos | É o principal driver de conversão, mas premiação instantânea exige controle de sigilo auditável. Fase 2, com desenho próprio |
| Sistema de afiliados | Só faz sentido com volume; adiciona split de pagamento e antifraude de auto-indicação |
| ~~App mobile nativo~~ | **Saiu desta lista na v1.6 — virou escopo (ADR-20).** O argumento do PWA foi revisto: push, ícone na home e sessão longa são frágeis no iOS, e são justamente o que sustenta a recompra. Custo assumido: +1 semana e a fila de revisão das lojas |
| Sorteador próprio (RNG interno) | A Loteria Federal é a fonte de aleatoriedade externa e não-manipulável. RNG interno destrói a tese do produto |
| Emissão do enquadramento regulatório | A plataforma exige o documento e trava sem ele. Não presta consultoria jurídica |

---

## 4. Personas

**P1 — Operador (cliente pagante).** Roda campanhas, precisa vender e precisa prestar contas. Dor: perde tempo com planilha, teme questionamento de comprador e de órgão fiscalizador.

**P2 — Comprador.** Chega por link de rede social. Quer comprar em menos de 60 segundos pelo celular, e quer saber que não está sendo enganado. Dor: desconfiança e checkout que trava.

**P3 — Auditor externo.** Jornalista, advogado, comprador cético, ou fiscal. Quer verificar o resultado sem depender da palavra do operador. Hoje não tem nenhuma ferramenta.

P3 é a persona que ninguém no mercado atende. É ela que gera o diferencial de P1 e a confiança de P2.

---

## 5. User Stories

### Operador (P1)

1. Como operador, quero cadastrar uma campanha com prêmio, preço, total de números e data de apuração, para publicá-la sem depender de um dev.
2. Como operador, quero registrar meu número de autorização e sua validade, para que a campanha não vá ao ar sem lastro documental.
3. Como operador, quero acompanhar em tempo real vendas, Pix gerados e Pix não pagos, para saber onde estou perdendo conversão.
4. Como operador, quero que a apuração seja executada e publicada automaticamente após a extração da Federal, para não ter que fazer nada manualmente no dia do sorteio.
5. Como operador, quero exportar o relatório mensal de arrecadação, para cumprir a prestação de contas do meu órgão autorizador.
6. Como operador, quero congelar a campanha antes do sorteio, para que ninguém alegue que vendi número depois da extração.
7. Como operador, quero entrar no sistema com e-mail, senha e segundo fator, para que só eu tenha acesso à operação e ao dinheiro da campanha.
8. Como operador, quero consultar e filtrar meus pedidos por status, para investigar uma reclamação específica de comprador sem abrir o banco.
9. Como operador, quero acompanhar o estado da apuração e agir quando ela travar, para não descobrir no dia do sorteio que faltava alguma coisa.
10. Como operador, quero cadastrar minha conta de recebimento antes de publicar, para que o dinheiro das vendas caia direto na minha conta, sem intermediário.
11. Como operador, quero ver qual conta está recebendo antes de publicar a campanha, para não descobrir um erro de cadastro depois da primeira venda.
12. Como operador, quero ser avisado com urgência quando um estorno falhar por saldo, para regularizar antes que vire reclamação do comprador.

### Comprador (P2)

13. Como comprador, quero me cadastrar com poucos dados no meio da compra, para não abandonar o checkout num formulário longo.
14. Como comprador, quero escolher um pacote e pagar via Pix em menos de 60 segundos no celular, para não desistir no meio.
15. Como comprador, quero receber meus números imediatamente após o Pix cair, para ter certeza de que a compra valeu.
16. Como comprador, quero entrar com um código enviado ao meu WhatsApp, para ver minhas compras sem criar nem lembrar de senha.
17. Como comprador, quero ver todas as campanhas de que participei num lugar só, para não caçar e-mail antigo a cada sorteio.
18. Como comprador, quero um comprovante que prove que meu número estava na base antes do sorteio, para poder contestar se necessário.
19. Como comprador, quero ser avisado no resultado da campanha, para não precisar acompanhar o site.

### Auditor (P3)

20. Como auditor, quero baixar a lista completa de números vendidos após a apuração, para conferir o resultado por conta própria.
21. Como auditor, quero recomputar a raiz Merkle da lista e comparar com o commitment carimbado antes da extração, para provar que a base não foi alterada.
22. Como auditor, quero ver a aplicação passo a passo da regra de aproximação, para verificar que o vencedor não foi escolhido a dedo.

### Entrega do prêmio (fecha o loop da tese)

23. Como auditor, quero ver que o prêmio foi efetivamente entregue ao portador do número apurado, para que a prova não pare no sorteio — é exatamente aqui que a fraude do caso Buzeira acontecia.
24. Como operador, quero registrar a identificação do ganhador e o comprovante de entrega na mesma trilha de auditoria, para encerrar a campanha com lastro documental.
25. Como comprador ganhador, quero confirmar o recebimento do prêmio, para que meu aceite seja parte do registro público.

### Casos de borda

26. Como comprador, se meu Pix expirar, quero que meus números voltem para o estoque e eu veja uma mensagem clara, em vez de um erro genérico.
27. Como comprador, se dois de nós tentarmos comprar os últimos 50 números ao mesmo tempo, um deve receber os números e o outro uma mensagem de estoque insuficiente — nunca ambos.
28. Como operador, se a autorização vencer durante a campanha, quero que a venda seja bloqueada automaticamente e eu seja notificado.

---

## 6. Requisitos

### P0 — Must have (sem isso não sobe)

---

**R0. Acesso do operador ao sistema**

Sem isto, nenhum outro requisito do operador é alcançável — R1, R9 e R8.5 pressupõem alguém autenticado. Estava implícito na v1.2 (só uma linha de "2FA obrigatório" em R9) e por isso não tinha critério, tela nem esforço estimado.

*Critérios de aceite*
- [ ] Operador entra com e-mail + senha; segundo fator (TOTP) é **obrigatório**, não opcional
- [ ] Primeiro acesso força a configuração do TOTP antes de liberar qualquer tela
- [ ] Recuperação de acesso por e-mail, com token de uso único e expiração curta
- [ ] Perda do segundo fator tem caminho de recuperação documentado que **não** desliga o 2FA
- [ ] Sessão expira por inatividade; encerrar sessão invalida o acesso de imediato
- [ ] Toda tentativa de login (sucesso e falha) entra na trilha de auditoria com IP e horário
- [ ] Após N tentativas falhas, a conta é bloqueada temporariamente
- [ ] Nenhuma tela administrativa é acessível sem sessão válida — inclusive por link direto
- [ ] Códigos de recuperação de uso único são gerados na ativação do 2FA e exibidos uma única vez
- [ ] O aviso de tentativas restantes é mostrado antes do bloqueio, não depois

**Por que é P0 e por que é R0:** é pré-requisito de todos os outros. Numerado como R0 para deixar explícito que vem antes, sem renumerar o que já foi referenciado em outros documentos.

---

**R0.5. Provisionamento da conta do operador**

R0 cobre *entrar* no sistema, mas não cobria *existir*. Alguém precisa criar a primeira conta, e sem isso o produto não tem porta de entrada.

*Critérios de aceite*
- [ ] A conta do operador é provisionada pela bit4devs durante o setup — **não** há auto-cadastro público
- [ ] O operador recebe convite por e-mail com token de uso único e validade curta
- [ ] No primeiro acesso, define a senha e ativa o segundo fator antes de qualquer outra tela (R0)
- [ ] Dados do organizador (razão social, CNPJ, contato) são registrados no provisionamento
- [ ] Convite expirado pode ser reemitido, e o token anterior é invalidado

**Por que não é auto-cadastro:** self-service é R15, explicitamente fora do escopo. Aqui há um cliente, provisionado à mão, e o custo disso é de minutos. Abrir cadastro público criaria superfície de abuso num produto que não tem antifraude de operador.

---

**R1. Cadastro e publicação de campanha**

Operador cria campanha com: título, descrição, imagem, prêmio principal, preço do bilhete, números por bilhete, total de números, pacotes de venda, data da extração da Federal, regulamento, número da autorização + órgão + validade.

*Critérios de aceite*
- [ ] Campanha em `RASCUNHO` não é acessível publicamente
- [ ] Publicação é bloqueada se autorização ausente ou vencida, com mensagem explícita
- [ ] Publicação dispara geração assíncrona do estoque de números
- [ ] Total de números aceita até 1.000.000 e a geração conclui em < 60s
- [ ] Preço e total de números tornam-se imutáveis após a publicação
- [ ] Upload da imagem do prêmio aceita apenas formato de imagem, com limite de tamanho, e o tipo real é validado pelo conteúdo — não pela extensão
- [ ] Campanha publicada tem endereço público estável (slug), e o slug não muda depois

---

**R2. Estoque e alocação atômica de números**

Cada número da sorte pertence a no máximo um bilhete. Alocação é concorrente-segura.

*Critérios de aceite*
- [ ] Teste de carga com 500 req/s por 60s não produz nenhum número duplicado
- [ ] Dado estoque de 10 e duas requisições simultâneas de 8, uma recebe 8 e a outra recebe erro `ESTOQUE_INSUFICIENTE`
- [ ] Números alocados são pseudoaleatórios do ponto de vista do comprador (não sequenciais)
- [ ] p95 da alocação de 1.000 números < 300ms

---

**R3. Checkout Pix com reserva temporária**

*Critérios de aceite*
- [ ] Reserva expira em 15 minutos (configurável) e devolve os números ao estoque
- [ ] Dado Pix pago dentro da janela, os números viram definitivos e o pedido vai para `PAGO`
- [ ] Dado Pix pago **após** a expiração, o sistema realoca automaticamente a mesma quantidade de números; se não houver estoque, aciona estorno e notifica o operador (ver **R10** para o caso de o estorno falhar por saldo)
- [ ] Webhook do PSP é idempotente: 10 entregas do mesmo evento produzem exatamente 1 transição de estado
- [ ] Nenhuma transição de estado do pedido é possível fora da máquina de estados definida

---

**R4. Congelamento e commitment criptográfico**

Em T-2h da extração (configurável), a campanha entra em `CONGELADA`, a venda é encerrada e o commitment é gerado.

*Critérios de aceite*
- [ ] Após o congelamento, qualquer tentativa de criar pedido retorna `CAMPANHA_CONGELADA`
- [ ] Snapshot canônico inclui todos os números com pedido em `PAGO` e nenhum outro
- [ ] Raiz Merkle é gerada com separação de domínio no padrão RFC 6962
- [ ] Raiz é carimbada por autoridade RFC 3161 e o token é armazenado
- [ ] Raiz, total de números vendidos e timestamp ficam públicos imediatamente
- [ ] Qualquer alteração posterior no snapshot é impossível por construção (tabela append-only + hash chain)

---

**R5. Comprovante verificável do comprador**

*Critérios de aceite*
- [ ] Cada pedido pago gera comprovante com: números, leaf hash de cada número, prova de inclusão (Merkle path), raiz e identificador do carimbo
- [ ] O comprovante é obtido pela área "Meus números" e por link direto
- [ ] Uma página de verificação estática, sem backend, valida a prova offline
- [ ] Prova adulterada em qualquer byte falha na verificação

---

**R6. Apuração automática**

*Critérios de aceite*
- [ ] Sistema obtém a extração da Federal da data configurada de fonte oficial
- [ ] Número apurado é formado conforme o regulamento da campanha (configurável: 3 últimos do 1º prêmio, ou combinação 1º+2º)
- [ ] Regra de aproximação sobe para o próximo número vendido imediatamente superior, com wrap-around no fim da faixa
- [ ] Cada passo da regra é registrado e exibido publicamente
- [ ] Se a fonte oficial estiver indisponível, a apuração fica `PENDENTE` e alerta o operador — **nunca** cai para um resultado inventado
- [ ] Lista completa de números vendidos é publicada para download após a apuração
- [ ] Antes de publicar, o sistema confere que concurso e data da extração batem com o configurado; divergência bloqueia a publicação e alerta
- [ ] Apuração incorreta é corrigida por **retificação** — nunca por edição ou exclusão. Original e retificação ficam ambas públicas, com o motivo
- [ ] Retificação exige causa de uma lista fechada, dupla autorização e registro em auditoria; **não pode** alterar snapshot nem commitment
- [ ] Retificação é bloqueada após a entrega do prêmio confirmada

---

**R7. Cadastro do comprador**

*Critérios de aceite*
- [ ] Cadastro exige nome, CPF válido (dígito verificador), data de nascimento, telefone e e-mail
- [ ] Menores de 18 anos são bloqueados com mensagem clara
- [ ] Consentimento LGPD registrado com timestamp, versão do texto e IP
- [ ] Consulta de números por CPF + telefone, sem senha, com rate limit
- [ ] CPF nunca aparece em qualquer artefato público
- [ ] O cadastro acontece **dentro** do fluxo de compra, sem redirecionar para uma tela isolada — o comprador chega de link de rede social e não volta se sair do checkout
- [ ] Comprador recorrente é reconhecido pelo CPF e não repreenche o cadastro
- [ ] Erro de validação aponta o campo específico, com texto em linguagem comum — nunca "dados inválidos" genérico
- [ ] O regulamento aceito fica registrado com a versão vigente no momento da compra

---

**R7.5. Acesso e painel do comprador**

A v1.5 tratava isso como "consulta por CPF + telefone". Dois problemas: qualquer pessoa que soubesse os dois dados abria a consulta alheia, e o comprador de várias campanhas não tinha onde ver tudo junto.

**Decisão: acesso por código de uso único, sem senha.** O comprador informa o CPF e recebe um código de 6 dígitos por WhatsApp ou e-mail. Isso cria sessão real — e portanto painel com histórico — sem introduzir senha.

*Por que não senha:* o comprador chega de link de rede social, compra em 60 segundos e volta raramente. Senha seria mais uma coisa para esquecer, viraria o principal motivo de suporte e derrubaria a conversão da consulta. O código prova posse do telefone, que é o que importa.

*Critérios de aceite — acesso*
- [ ] Acesso por CPF + código de 6 dígitos enviado por WhatsApp ou e-mail, à escolha do comprador
- [ ] O código expira em 10 minutos e é de uso único
- [ ] Máximo de 5 tentativas por código; excedido, é preciso solicitar outro
- [ ] Rate limit no envio, por CPF e por IP, para não virar vetor de flood de SMS/WhatsApp
- [ ] A sessão dura 30 dias e pode ser encerrada pelo próprio comprador
- [ ] O canal de envio é mascarado na tela — nunca exibir telefone ou e-mail completos a quem ainda não entrou
- [ ] CPF inexistente e CPF sem compras produzem a **mesma** resposta, para não confirmar cadastro a quem sonda

*Critérios de aceite — painel*
- [ ] Todas as campanhas do comprador numa lista só, com o estado de cada uma
- [ ] Estados cobertos: aguardando pagamento, confirmado, apurado não premiado, **premiado**, expirado
- [ ] Comprador premiado vê destaque inequívoco, com o número sorteado e o prazo de entrega
- [ ] Do destaque de prêmio, acesso direto à confirmação de recebimento (US 21)
- [ ] Comprovantes verificáveis reunidos numa seção, com link para o verificador público
- [ ] Área de dados pessoais com correção, exportação e solicitação de exclusão (LGPD, art. 18)
- [ ] A tela de exclusão explica que os números permanecem na lista pública **sem** o nome, porque removê-los invalidaria a prova dos demais compradores
- [ ] Consentimentos aceitos ficam visíveis, com data e versão

**Sobre o direito ao esquecimento:** o crypto-shredding já está desenhado, mas sem esta tela o titular não tem como exercer o direito — e um produto que trata dado pessoal precisa da porta, não só do mecanismo.

---

**R8. Guarda-corpos de compliance**

*Critérios de aceite*
- [ ] Limite de gasto por CPF por campanha, configurável, bloqueando na criação do pedido
- [ ] Campanha é suspensa automaticamente se a autorização vencer
- [ ] Trilha de auditoria append-only registra toda transição de estado com ator, timestamp e hash encadeado
- [ ] Aviso 18+ visível em todas as páginas públicas
- [ ] Regulamento versionado; comprador aceita a versão vigente na compra

---

**R8.5. Entrega do prêmio e encerramento da campanha**

Provar quem ganhou sem provar que o ganhador recebeu deixa aberto exatamente o vetor de fraude que motiva o produto. O caso Buzeira não foi fraude de sorteio — foi fraude de **atribuição e entrega**.

*Critérios de aceite*
- [ ] Após a apuração, a campanha entra em `AGUARDANDO_ENTREGA` e só vai para `ENCERRADA` com registro de entrega
- [ ] Operador registra: identificação do ganhador (dado sensível, não público), data da entrega, comprovante (documento/foto) e forma de entrega
- [ ] Ganhador confirma o recebimento por link autenticado; a confirmação é registrada com timestamp e IP
- [ ] Cada passo entra na trilha append-only com hash encadeado, igual às demais transições
- [ ] A página pública mostra apenas: número apurado, status da entrega e data — **nunca** nome, CPF ou contato do ganhador
- [ ] Campanha apurada há mais de N dias (configurável, default 30) sem registro de entrega gera alerta ao operador e marca a campanha como `ENTREGA_PENDENTE` publicamente
- [ ] Prazo de entrega estourado não pode ser apagado nem editado retroativamente

**Por que é P0 e não P1:** sem isso, o produto prova a metade do percurso e o operador desonesto continua com o mesmo espaço de manobra. O selo "verificado" ficaria falso.

---

**R9. Painel do operador**

A v1.2 resumia o painel em quatro linhas. Isso subespecificava a única superfície pela qual o operador opera o produto — e escondia esforço real de semana 4. As áreas abaixo são o escopo fechado da v1: o que não está aqui **não** entra sem trocar por algo que sai.

*R9.1 — Visão geral (a tela inicial)*
- [ ] Arrecadação, números vendidos, Pix gerados vs. pagos e taxa de conversão
- [ ] Funil de conversão explícito: visitas → pedidos → Pix gerados → Pix pagos, com a queda de cada etapa
- [ ] Alerta visível quando a autorização vence em menos de 30 dias
- [ ] Estado da preparação da apuração, incluindo se a autoridade de carimbo está acessível

*R9.2 — Pedidos*
- [ ] Lista com filtro por status (aguardando, pago, expirado, estornado)
- [ ] Busca por identificador do pedido e por CPF do comprador
- [ ] Detalhe do pedido com o histórico de transições de estado e horários
- [ ] Exportação CSV/XLSX respeitando o filtro aplicado na tela

*R9.3 — Apurações*
- [ ] Estado da apuração de cada campanha, incluindo `PENDENTE` quando a fonte oficial falha
- [ ] Ação de reprocessar a apuração quando ela ficou pendente por indisponibilidade da fonte
- [ ] Entrada manual assistida da extração, com dupla conferência, quando as duas fontes falham
- [ ] Registro da entrega do prêmio e acompanhamento da confirmação do ganhador (R8.5)
- [ ] Retificação de apuração, exigindo motivo de uma lista fechada e segunda autorização
- [ ] O histórico de tentativas de obtenção da extração é visível, com horário e motivo de cada falha
- [ ] A tela informa quando ocorre a próxima tentativa automática e que a campanha segue congelada
- [ ] A entrada manual só fica disponível **depois** que as duas fontes automáticas falharam — nunca como atalho
- [ ] A entrada manual exige comprovante da fonte oficial e confirmação de dois responsáveis distintos
- [ ] A tela declara explicitamente que o sistema não produz resultado sem origem oficial
- [ ] Os limites da retificação (o que ela nunca pode fazer) são exibidos na própria tela, não só na documentação

*R9.4 — Relatórios*
- [ ] Arrecadação por período, exportável em CSV/XLSX
- [ ] Relatório de prestação de contas com os dados que o órgão autorizador exige

*R9.5 — Requisitos transversais do painel*
- [ ] Toda tela exige sessão autenticada com 2FA (R0)
- [ ] Toda ação que altera estado entra na trilha de auditoria com ator e horário
- [ ] Ações irreversíveis (congelar, retificar, registrar entrega) pedem confirmação explícita
- [ ] Estados de carregamento, vazio e erro definidos em todas as listagens — nunca tela em branco

**Fora do escopo do painel na v1:** gestão de usuários e permissões (há um operador só), configurações da conta além do 2FA, e personalização visual da campanha. Entram com o multi-tenant (R15).

---

**R9.6. Estados de exceção visíveis ao público**

Os documentos definem o comportamento do sistema nos casos degenerados, mas nenhuma tela os mostrava. São exatamente os momentos em que a interface mais importa: quando algo saiu do caminho feliz e o silêncio da tela vira desconfiança.

*Critérios de aceite*
- [ ] Campanha sem nenhuma venda até o congelamento exibe publicamente que foi cancelada por ausência de vendas, com o commitment da lista vazia
- [ ] Apuração pendente por indisponibilidade da fonte oficial é exibida como **pendente**, com a data da próxima tentativa — nunca em branco nem com resultado provisório
- [ ] Campanha suspensa por autorização vencida informa a suspensão na página pública
- [ ] Prêmio não entregue no prazo aparece publicamente como entrega pendente
- [ ] Apuração retificada mostra o resultado vigente **e** o anterior, com o motivo da retificação
- [ ] Pix pago após a expiração informa ao comprador se houve realocação de números ou estorno

**Por que é P0:** um produto que vende transparência não pode ficar mudo justamente quando algo dá errado. Esconder o estado de exceção contradiz a tese com mais força do que qualquer falha técnica.

---

**R10. Conta de recebimento do operador**

O documento definia como cobrar, mas não **para onde o dinheiro vai**. Sem isto, a decisão seria tomada por omissão na semana 2, por quem estivesse escrevendo o adapter do PSP.

**Decisão: a plataforma não custodia dinheiro de terceiros.** O Pix do comprador cai direto na conta do operador no PSP. A plataforma cria a cobrança, acompanha o pagamento e atribui os números — mas o dinheiro nunca passa por conta da bit4devs.

*Critérios de aceite*
- [ ] O operador cadastra a conta de recebimento no PSP antes de publicar qualquer campanha
- [ ] Publicação é **bloqueada** enquanto não houver conta de recebimento válida e verificada
- [ ] A titularidade da conta é conferida contra o CNPJ do organizador — conta de terceiro é recusada
- [ ] A cobrança Pix é emitida com o operador como recebedor, nunca a plataforma
- [ ] O painel mostra qual conta está recebendo, para o operador conferir antes de publicar
- [ ] Troca de conta de recebimento exige reautenticação com segundo fator e entra na auditoria
- [ ] Nenhuma tela, relatório ou API sugere que a plataforma detém saldo do operador

**Consequência assumida — estorno depende de saldo do operador.** Sem custódia, a plataforma não consegue estornar com dinheiro próprio. O caso de R3 (Pix pago após a expiração, sem estoque para realocar) passa a ter um desfecho a mais, que precisa ser tratado e não escondido:

- [ ] Estorno é solicitado ao PSP na conta do operador
- [ ] Se o estorno falhar por saldo insuficiente, o pedido vai para `ESTORNO_PENDENTE` — **nunca** para `ESTORNADO`
- [ ] O operador é notificado com urgência alta, com o valor e o prazo para regularizar
- [ ] O comprador é informado de que o estorno está em andamento, com previsão — nunca fica sem resposta
- [ ] `ESTORNO_PENDENTE` aberto há mais de N dias (configurável) escala para alerta crítico
- [ ] O painel lista todos os estornos pendentes com o total devido

**Por que isso é P0:** dinheiro recebido, número não entregue e estorno que falhou em silêncio é o pior incidente que este produto pode ter — e é o único cenário em que ele viraria, na prática, o problema que se propõe a resolver.

---

### P1 — Should have (entra se sobrar semana 4)

- **R10.** Notificação WhatsApp de compra confirmada e de resultado
- **R11.** Contador de urgência (números restantes) na página da campanha
- **R12.** Recuperação de carrinho: lembrete de Pix pendente em 10 min
- **R13.** Relatório de prestação de contas em PDF já no layout do órgão autorizador

### P2 — Future considerations (arquitetar para, não construir)

- **R14.** Bilhetes premiados instantâneos com sigilo verificável (compromisso pré-selado dos números premiados publicado junto ao commitment)
- **R15.** Multi-tenant self-service com onboarding e billing
- **R16.** Cartão de crédito com split
- **R17.** Sistema de afiliados com split no PSP
- **R18.** API pública de verificação para integração de terceiros
- **R19.** Permutação por cifra Feistel para campanhas acima de 5 milhões de números

**Impacto arquitetural de P2:** `tenant_id` presente em todas as tabelas desde o dia 1; interface `AlocadorDeNumeros` como porta, com implementação `TabelaPreSorteada` na v1; commitment desenhado para aceitar múltiplas árvores por campanha (vendas + premiados instantâneos).

---

## 6.1 Rastreabilidade — requisito ↔ tela

Esta seção existe porque a v1.2 não a tinha, e foi exatamente aí que o buraco apareceu: o protótipo prometia áreas que o PRD não especificava, e o PRD definia estados que nenhuma tela mostrava. A tabela é o contrato entre os dois.

| Req | Tela do protótipo | Situação |
|---|---|---|
| R0 · acesso do operador | `00-login` | ✅ 3 estados |
| R0.5 · provisionamento | — | ⚠️ **falta protótipo** (convite, definir senha) |
| R1 · publicar campanha | — | ⚠️ **falta protótipo** (admin de campanha) |
| R10 · conta de recebimento | — | ⚠️ **falta protótipo** (cadastro e verificação) |
| R2 · alocação atômica | sem tela (backend) | ✅ n/a |
| R3 · checkout Pix | `02-checkout-pix` | ✅ |
| R4 · commitment | `04-apuracao` | ✅ |
| R5 · comprovante | `03-meus-numeros` (aba) + `05-verificador` | ✅ |
| R6 · apuração | `04-apuracao` | ✅ caminho feliz |
| R7 · cadastro do comprador | `02a-cadastro` | ✅ |
| R7.5 · acesso e painel do comprador | `03a-acesso-comprador` + `03-meus-numeros` | ✅ |
| R8 · compliance | `01-campanha` (18+, autorização, limite CPF) | ✅ |
| R8.5 · entrega do prêmio | `04-apuracao` | ✅ visão pública; falta a do operador |
| R9.1 · visão geral | `06-painel-operador` | ✅ |
| R9.2 · pedidos | `06-painel-operador` (listagem) | ⚠️ falta detalhe e busca |
| R9.3 · apurações | `07-apuracoes-admin` | ✅ |
| R9.4 · relatórios | — | ⚠️ **falta protótipo** |
| R9.6 · estados de exceção | — | ⚠️ **falta protótipo** |

**Regra:** nenhuma tela entra no protótipo sem requisito correspondente, e nenhum requisito P0 com interface vai para desenvolvimento sem tela. Divergência aqui é defeito de planejamento, não detalhe de design — foi assim que a área administrativa quase entrou em desenvolvimento sem especificação.

**Nota sobre o protótipo atual:** a navegação de `06-painel-operador` mostra um item "Configurações" que **não** tem requisito correspondente e está fora do escopo da v1. O protótipo prometeu mais do que o PRD pede — o defeito é do protótipo, e ele deve ser corrigido para reduzir a navegação ao escopo real.

---

## 7. Métricas de sucesso

### Leading (medir em D+7 após a 1ª campanha)

| Métrica | Meta | Stretch | Como medir |
|---|---|---|---|
| Conversão Pix gerado → pago | ≥ 55% | 70% | Eventos do pedido |
| Tempo mediano do checkout | ≤ 60s | 40s | Timestamp `pedido.criado` → `pedido.pago` |
| Taxa de erro do checkout | < 0,5% | < 0,1% | Logs estruturados |
| p95 da página da campanha | < 800ms | < 500ms | APM |
| Números duplicados | 0 | 0 | Constraint + auditoria |

### Lagging (medir em D+30)

| Métrica | Meta | Como medir |
|---|---|---|
| Campanhas apuradas com commitment válido | 100% | Verificação independente |
| Contestação de resultado | 0 | Suporte |
| Tempo de fechamento contábil do operador | < 1h/mês | Entrevista |
| Renovação ou indicação do cliente | Sim | Comercial |

> **Origem das metas:** os alvos de conversão (55%/70%) são **arbitrados**, não medidos — e sua validação é o item **C3 do gate comercial** (§11) — não há baseline público confiável de Pix→pago neste segmento, e o cliente não forneceu histórico. Tratar como hipótese a ser substituída pelo número real da 1ª campanha, que passa a ser o baseline das seguintes. Documentar a fonte assim que o cliente entregar dado histórico.

**Critério de kill:** se a conversão Pix→pago ficar abaixo de 35% na 1ª campanha, o problema é de produto ou de audiência do cliente, não de tecnologia. Parar e diagnosticar antes de investir em v2.

---

## 8. Riscos

| Risco | Prob. | Impacto | Mitigação |
|---|---|---|---|
| Cliente não tem enquadramento regulatório sólido | Alta | Crítico | Bloqueio técnico na publicação. Contrato com cláusula de responsabilidade exclusiva do operador. Validar **antes** do kickoff |
| Mudança regulatória durante o projeto | Média | Alto | Enquadramento é dado de campanha, não código. Trocar de regime não exige redeploy |
| Fonte da Loteria Federal instável | Média | Médio | Duas fontes + fallback manual assistido. Nunca resultado sintético |
| PSP recusa o segmento (MCC de sorteio) | Média | Alto | Validar aprovação de conta na **semana 1**, antes de escrever integração. **Com PSP único, este risco ficou mais concentrado que na v1.5** — a mitigação é a porta `GatewayDePagamento`, que mantém a troca barata, não um segundo adapter pronto |
| **Loja (Apple/Google) rejeita app de sorteio** | **Alta** | Médio | Submeter na semana 5 com a autorização SEAE/SPA anexada. **A compra pela web permanece funcional** — por isso a rejeição atrasa o app, não o faturamento |
| Pico de tráfego no lançamento derruba o site | Média | Alto | Teste de carga na semana 4. Página da campanha em cache/CDN, checkout isolado |
| Escopo criativo do cliente (ranking, afiliado, instantâneas) | Alta | Alto | Não-objetivos assinados no kickoff. Qualquer adição troca por remoção |
| Comprador não entende a prova criptográfica | Alta | Baixo | UX em duas camadas: selo simples ("verificado") + detalhe técnico opcional |
| **ACT ICP-Brasil não contratada a tempo** | Média | **Crítico** | Marco duro em D+7 junto do PSP. Sem carimbo não há apuração — é dependência de caminho crítico, não detalhe de engenharia |
| **Bug sutil em concorrência ou cripto gerado por IA** | Média | **Crítico** | Nenhum código de R2/R4/R6 é aceito contra teste escrito na mesma sessão. Vetores RFC 6962 externos + testes adversariais + revisão humana obrigatória |
| **Excesso de confiança na velocidade da IA** | Alta | Alto | Cronograma dimensionado pela tabela da §0, não por "IA escreve rápido". Feature freeze em D+28 |
| Prêmio não entregue ou entrega não comprovada | Média | **Crítico** | R8.5: campanha não encerra sem registro; `ENTREGA_PENDENTE` público após o prazo |
| **Área administrativa subestimada** | Alta | Alto | R0 e R9 detalhados nesta versão. O painel é a superfície pela qual o operador opera tudo; resumi-lo em 4 linhas escondia esforço de semana 4 |
| **Estorno falha por saldo insuficiente na conta do operador** | Média | **Crítico** | Consequência assumida do modelo sem custódia. `ESTORNO_PENDENTE` explícito, alerta ao operador, comprador informado e escalonamento por tempo aberto (R10) |
| Operador cadastra conta de recebimento de terceiro | Baixa | Alto | Titularidade conferida contra o CNPJ do organizador; publicação bloqueada sem conta verificada |
| Apuração rodada sobre extração errada | Média | **Crítico** | Conferência automática bloqueia a publicação; retificação pública como último recurso (§6 da spec) |
| Bloat de `numero_sorte` degrada alocação no pico | Média | Alto | `fillfactor` + autovacuum por tabela; medido no teste de carga da semana 5 |

---

## 9. Questões em aberto

**Bloqueantes (resolver antes do kickoff)**

| # | Questão | Responde |
|---|---|---|
| Q1 | Qual o enquadramento regulatório do cliente e o documento está vigente? | Jurídico / Cliente |
| Q2 | O **PicPay** aprova a conta para este segmento (MCC de sorteio)? | Comercial / Cliente |
| Q3 | Quem responde pelo pagamento do prêmio e pela entrega física? Qual o prazo contratual de entrega? | Cliente |
| Q4 | Qual a regra exata de formação do número apurado no regulamento do cliente? | Cliente |
| Q5 | O modelo comercial é setup + mensalidade, ou % sobre arrecadação? A segunda opção pode caracterizar sociedade no risco regulatório | bit4devs |
| Q6 | Qual ACT (Autoridade de Carimbo do Tempo) ICP-Brasil será contratada, e qual o lead time real de credenciamento/contrato? | Engenharia / Comercial |

Q3 deixou de ser apenas jurídica: ela agora tem contraparte no sistema (**R8.5**). O prazo contratual de entrega vira o parâmetro `N` do alerta de `ENTREGA_PENDENTE`.

Q6 foi **promovida a bloqueante** nesta versão. O motivo: a §6 fase 4 da spec estabelece que sem carimbo não há apuração — logo a ACT é dependência de mesma classe que a conta no PSP, e contratação com ICP-Brasil tem lead time comercial de dias a semanas, que nenhuma assistência de IA encurta. Descobrir isso na semana 3 inviabiliza a apuração da 1ª campanha.

**Não bloqueantes**

| # | Questão | Responde |
|---|---|---|
| Q7 | Retenção do snapshot: quanto tempo manter público? | Jurídico |
| Q8 | Notificação por WhatsApp: API oficial ou não-oficial? | Engenharia |
| Q9 | Fallback da ACT: se a autoridade primária cair no dia, qual a secundária? | Engenharia |

Q5 merece destaque: cobrar percentual sobre arrecadação de uma operação de sorteio aproxima a bit4devs do risco do operador. Recomendação forte: **setup + mensalidade fixa**, sem participação na receita.

---

## 10. Cronograma

| Semana | Entregável verificável |
|---|---|
| 1 | Domínio modelado e testado; **acesso e provisionamento do operador (R0, R0.5)**; **conta de recebimento (R10)**; campanha publicável; estoque de 1M gerado; **conta no PicPay aprovada, contrato da ACT assinado e contas Apple/Google abertas** |
| 2 | Fluxo completo **cadastrar** → comprar → Pix → números atribuídos, fim a fim em homologação **pelo app** |
| 3 | Congelamento, commitment carimbado, comprovante com prova, verificador público |
| 4 | Apuração automática, entrega do prêmio (R8.5), compliance, **painel completo (R9.1–R9.5)**, relatórios |
| 5 | **App fechado**: deep link, E2E Maestro, build EAS e **submissão às duas lojas**; web mobile-first paritária como caminho de compra que não depende de aprovação |
| 6 | **Estados de exceção (R9.6)**, teste de carga, hardening, deploy, campanha real no ar — **e a folga que absorve o imprevisto** |

A 6ª semana **não é gordura**: é a folga nomeada que a v1.0 deste documento não tinha. Um cronograma com zero buffer não é agressivo, é um cronograma que já falhou e ainda não sabe. A assistência de IA foi aplicada para tornar o prazo confortável, não para espremê-lo — ver a tabela de produtividade na §0. **Na v1.6 essa folga ganhou um segundo dono provável: um ciclo de resposta a rejeição de loja.**

**Marcos duros**
- **D+7:** conta no PicPay aprovada **e** ACT contratada **e** contas de loja ativas. Qualquer um dos três faltando, o cronograma para e é renegociado. Todos são espera por terceiro — a IA não os encurta.
- **D+21:** apuração ensaiada com dados sintéticos e verificada por terceiro usando só o verificador público.
- **D+28:** apuração e compliance fechados.
- **D+35:** feature freeze **e** app submetido às lojas. Nada novo entra depois disso.
- **D+42:** campanha real publicada. **A publicação não espera aprovação de loja** — a compra pela web é o caminho garantido.

**Faseamento se atrasar:** cortar nesta ordem — P1 inteiro → **app adiado para v1.1, mantendo a web mobile-first** (é o corte de maior alívio e menor dano, porque o caminho de compra continua de pé) → R9.4 (relatórios além da exportação básica) → R9.2 reduzido a listagem sem busca por CPF → notificação por e-mail em vez de WhatsApp → confirmação de entrega pelo ganhador vira registro só do operador (mantendo o registro em si). **Nunca cortar:** R0 (acesso), R10 (conta de recebimento e estorno pendente), R2 (alocação atômica), R4 (commitment), R6 (apuração), R8 (compliance), R8.5 (registro de entrega), R9.3 (apurações) e R9.6 (estados de exceção). Esses nove são o produto.

R0 e R9.3 entraram nessa lista nesta versão: sem acesso não há operação, e sem a tela de apurações o operador não tem como agir quando a apuração trava — que é justamente o cenário em que ele mais precisa do sistema.

---

## 11. Modelo comercial sugerido

| Item | Valor de referência |
|---|---|
| Setup (implantação + 1ª campanha) | Cobrado uma vez, cobre as 6 semanas |
| Mensalidade | Fixa, inclui hospedagem, suporte e apuração |
| Sem participação na arrecadação | Decisão deliberada de isolamento de risco |
| Propriedade do código | bit4devs mantém; cliente recebe licença de uso |

**Números a preencher antes do kickoff** — G5 é "provar o wedge comercial" e não se prova wedge sem número. Estes campos estão deliberadamente em aberto e devem ser fechados na proposta comercial, não no PRD:

| Variável | Precisa de |
|---|---|
| Valor do setup | Custo das 6 semanas + margem |
| Valor da mensalidade | Custo de infra + suporte + rateio da apuração |
| Ticket médio esperado da campanha | Dado do cliente (histórico de campanhas anteriores) |
| Volume de campanhas/mês do cliente | Dado do cliente |
| Payback do cliente nº 2 | Meta: ≤ 1 semana de implantação, contra 5 do nº 1 |

O último item é a métrica que define se isto virou produto ou continuou sendo serviço. Se o cliente nº 2 custar mais de 2 semanas, a arquitetura multi-tenant-ready não cumpriu o que prometeu e a tese comercial precisa ser revista antes de escalar.

### Gate comercial — D-3 (três dias antes do kickoff)

Estes números **não são deriváveis por engenharia**: dependem de dado do cliente e de decisão da bit4devs. Mas deixá-los "em aberto" sem dono e sem prazo é como um cronograma sem folga — o problema não some, só aparece tarde. Por isso viram gate com data:

| # | A definir | Dono | Sem isso, o que quebra |
|---|---|---|---|
| C1 | Valor do setup e da mensalidade | bit4devs | Não há proposta; o projeto não começa |
| C2 | Ticket médio e volume histórico de campanhas do cliente | Cliente | G5 fica inavaliável e a meta de conversão segue sendo chute |
| C3 | Baseline real de conversão Pix→pago do cliente | Cliente | As metas de 55%/70% continuam arbitradas (ver §7) |
| C4 | Custo mensal de infra + ACT + PSP **+ contas de loja (US$ 99/ano Apple, US$ 25 único Google)** | bit4devs | A mensalidade pode nascer abaixo do custo |

**Regra do gate:** C1 e C4 são bloqueantes — sem eles não há proposta assinável. C2 e C3 **não bloqueiam o kickoff**, mas se não vierem até D+7, as metas da §7 ficam formalmente registradas como hipótese não validada, e o critério de kill passa a ser avaliado contra o número da própria 1ª campanha em vez de contra a meta. Isso é aceitável uma vez; não é aceitável na segunda campanha.

Manter a propriedade do código é o que transforma este projeto de serviço em produto. É a única forma de o cliente nº 2 custar 1 semana em vez de 4.

---

**Ø 1 MU1TØ 4L3M DØ CØD1GØ !**
