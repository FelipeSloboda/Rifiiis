# Protótipo Rifiiis — decisões de design

**Companion de:** `PRD-plataforma-rifa-mvp.md` v1.6 · `SPEC-TECNICA-plataforma-rifa-mvp.md` v1.5
**Data:** 30/08/2026
**Telas:** `hi-fi/index.html` (índice navegável)

---

## 1. Pesquisa de mercado — o que existe hoje

Foram examinadas as plataformas brasileiras de rifa online em operação:
Rifei, Rifafy, RifApp, VouRifar, TecnoRifa, RiffaDigital, 123Rifas, Rifa.online,
Rifeme, Sistema BRN e Plataforma Rifa.

### Padrão consolidado (adotado)

Estes elementos são convenção de mercado. Fugir deles sem motivo custaria conversão:

| Padrão | Onde aparece | Por que foi mantido |
|---|---|---|
| Barra de progresso de cotas vendidas | Tela 01 | Gatilho de escassez, e o comprador espera vê-lo |
| Pacotes de quantidade com atalho (10/50/100/250/500/1000) | Tela 01 | Reduz fricção; digitar quantidade é o caminho lento |
| Destaque de "mais escolhido" num pacote | Tela 01 | Âncora de decisão consolidada no segmento |
| Pix com QR + copia-e-cola lado a lado | Tela 02 | Cobre quem paga no mesmo device e quem paga em outro |
| Confirmação automática por webhook, sem envio de comprovante | Tela 02 | Todas as plataformas relevantes já fazem; enviar print é fricção morta |
| Consulta de números por CPF sem senha | Tela 03 | Padrão do segmento; senha derruba conversão de consulta |
| Mobile-first com CTA fixo no rodapé | Telas 01–03 | O tráfego vem de link de Instagram/WhatsApp |

### O que foi deliberadamente recusado

| Prática comum no mercado | Por que NÃO entrou |
|---|---|
| **Estética de cassino** (vermelho/dourado/neon, roleta, confete) | O produto vende *prova*, não sorte. A paleta é de documento auditável — tinta, papel, verde-selo. Parecer cassino contradiz a tese |
| **Cotas premiadas instantâneas** | Não-objetivo declarado do PRD (§3). É o maior driver de conversão do mercado, e está fora da v1 por exigir sigilo auditável — Fase 2 (R14) |
| **Ranking de maiores compradores** | Fora de escopo (parking lot da spec §15). Expõe comprador e incentiva gasto sem guarda-corpo |
| **Contador regressivo agressivo / "últimas unidades" piscando** | Urgência artificial num produto cujo argumento é honestidade seria autossabotagem. O progresso real já comunica escassez |
| **Escolha manual do número no grid** | Incompatível com R2: alocação é pré-embaralhada e atômica. Grid de 1M números também é inviável em mobile |

**A ausência mais importante:** nenhuma das plataformas examinadas oferece
verificação independente do resultado. Todas pedem confiança no organizador.
As telas 04 e 05 não têm concorrente direto no mercado brasileiro — é exatamente
o vazio que o PRD §4 identifica na persona P3.

---

## 2. Sistema visual

### Paleta — laranja/azul, e a regra do verde

Direção visual derivada da referência de campanha fornecida pelo cliente (laranja quente
+ azul institucional). É mais popular e converte melhor que uma paleta sóbria para tráfego
que chega de Instagram e WhatsApp.

```
--ink        #14243a   azul-tinta, texto e topo
--paper      #fdf6ee   papel quente
--muted      #5e6b7c   texto secundário
--brand      #123a6b   azul institucional (marca, links, navegação)
--brand-2    #1b5aa8   azul de foco e realce
--acao       #c94508   LARANJA DE AÇÃO — botões com texto branco
--acao-viva  #e8590c   laranja vibrante — superfícies e gradientes, NUNCA com texto
--verify     #0f6b46   SELO DE PROVA — uso restrito
--warn       #8a5f00   prazo, vencimento
--danger     #a3232b   erro, expiração
--gold       #8a6a1f   prêmio ganho (exclusivo do estado de ganhador)
```

**Dois laranjas, e o motivo é medido.** O laranja vibrante da referência (`#e8590c`) rende
apenas **3,58:1** com texto branco — reprova AA. Ele fica para superfícies, gradientes e a
barra de progresso, onde não carrega texto. Botões usam `#c94508`, que dá **4,84:1** e passa.
Usar o vibrante no botão seria fiel à arte e inacessível.

**`--verify` continua reservado — e agora isso importa mais.** Numa paleta laranja/azul,
o verde é a única cor que não aparece em mais nada: quando ele surge, é porque algo foi
criptograficamente provado. Se o selo "verificado" tivesse a cor do botão "comprar", o
selo deixaria de significar algo — e ele é o único diferencial do produto.

**Divisão de papéis:**
- **Laranja** = ação e venda (CTA, progresso, urgência)
- **Azul** = marca, estrutura e navegação
- **Verde** = prova criptográfica, e nada mais
- **Dourado** = prêmio ganho

### Tipografia
`Inter` para interface, `JetBrains Mono` para tudo que é **verificável**: números
da sorte, hashes, raiz Merkle, protocolos. Monoespaçado aqui não é estética — é
sinalização de que aquele conteúdo é conferível caractere a caractere.

---

## 3. Decisões por tela

### 01 — Página da campanha
- **Selo de verificação acima da dobra, antes do preço.** A ordem importa: o
  argumento de confiança precisa chegar antes do pedido de dinheiro. Em todas as
  plataformas examinadas, o preço vem primeiro e a confiança nunca vem.
- **Autorização visível sobre a imagem do prêmio** (R8), não escondida no rodapé.
- **Aviso 18+ como faixa fixa** no topo de toda página pública (R8).
- **Limite por CPF exibido antes da compra** — o comprador descobre o teto agora,
  não no erro do checkout.

### 02a — Cadastro do comprador
- **Dentro do checkout, não em tela isolada** (R7). O comprador chega de link de rede
  social; mandá-lo para uma página de "criar conta" é onde o funil vaza.
- **CPF é o primeiro campo**, não o último. É a identidade natural do comprador —
  perguntá-lo primeiro permite reconhecer quem já comprou e não pedir o resto de novo.
- **Cinco campos, nada além do que R7 exige.** Cada campo a mais custa conversão, e
  o PRD não pede endereço, senha nem confirmação de e-mail.
- **A tela mostra o estado de ERRO**, não o feliz: bloqueio de menor de 18 com a
  mensagem que R7 exige ("aponta o campo, em linguagem comum"), e CTA desabilitado
  em coerência. Estado de erro é o que costuma faltar em protótipo — e é onde a
  implementação erra.
- **Versão do regulamento visível** no aceite (R8: "comprador aceita a versão vigente").
- **Nota de privacidade sobre o CPF** ao pé: reduz o atrito real de pedir CPF a um
  comprador que chegou por Instagram.

### 02 — Checkout Pix
- **Cronômetro de reserva em destaque** (R3, 15 min). O comprador precisa saber que
  o número não é dele ainda. Esconder o prazo gera a reclamação de "sumiu meu número".
- **Espera do webhook com feedback vivo** e `aria-live` — sem isso, o comprador
  paga e fica olhando tela morta, que é onde nasce o ticket de suporte.
- **"O que acontece quando o Pix cair"** explicitado antes de acontecer: reduz a
  ansiedade do intervalo entre pagar e receber os números.
- Passos do checkout (3 de 3) visíveis: mostra que falta pouco.

### 03a — Acesso do comprador (R7.5)
- **Código de uso único, não senha.** O comprador compra em 60 segundos e volta raramente:
  senha seria mais uma coisa para esquecer, e viraria o principal motivo de suporte.
  O código por WhatsApp prova posse do telefone — que é o que importa.
- **Corrige uma falha de segurança da versão anterior:** CPF + telefone permitia que
  qualquer um que soubesse os dois dados abrisse a consulta alheia. O código exige
  posse do canal, não conhecimento de dado público.
- **A tela explica por que não pede senha.** Sem isso, a ausência parece descuido —
  e alguém "corrige" depois, destruindo a conversão que a decisão protege.
- **Canal mascarado** antes de entrar: nunca exibir telefone ou e-mail completos
  a quem ainda não provou ser o titular.

### 03 — Painel do comprador
- **Cinco estados de campanha**: aguardando, confirmado, apurado não premiado,
  **premiado** e expirado. O expirado diz explicitamente que *não houve cobrança* —
  é a dúvida real do comprador nessa situação.
- **O estado de ganhador é o que mais faltava.** Antes, quem ganhou veria os números
  como qualquer outro dia. Agora há destaque inequívoco, o número sorteado em
  evidência, o prazo de entrega do organizador e o acesso à confirmação de recebimento.
- **A confirmação avisa para não confirmar antes de receber** — ela encerra a campanha
  e entra no registro público, então confirmar cedo prejudica o próprio ganhador.
- **Comprovante dentro do pedido E reunidos numa aba.** A prova precisa estar onde a
  pessoa já está, e também num lugar só para quem participou de várias campanhas.
- **Aba de dados com exclusão (LGPD).** O crypto-shredding já existia na spec, mas
  sem tela o titular não tinha como exercer o direito. A tela explica o que **não**
  muda: os números seguem na lista pública sem o nome, porque removê-los invalidaria
  a prova de todos os outros compradores.

### 04 — Resultado da apuração
- **Passo a passo da regra como linha do tempo** (R6). Inclui o caso "acerto direto"
  — que a spec §6 lista como caso degenerado a registrar explicitamente, para
  distinguir de aproximação com zero saltos.
- **Entrega do prêmio na mesma página do resultado** (R8.5). Provar quem ganhou sem
  provar que recebeu deixaria aberto exatamente o vetor do caso Buzeira.
- Dados pessoais do ganhador **não** aparecem — só número, status e datas.

### 05 — Verificador público
- **Duas camadas**, conforme a mitigação de risco do PRD §8 ("comprador não entende
  a prova criptográfica"): veredito em linguagem comum na frente, detalhe técnico
  em `<details>` fechado. Nenhuma das camadas é o padrão da outra.
- **Selo "roda no seu navegador, sem servidor"** no topo. É a propriedade que torna
  o verificador confiável: se ele consultasse a API do Rifiiis, verificaria nada.
- **Seção "por que isso prova alguma coisa?"** em 4 passos, sem jargão. O auditor
  cético é jornalista ou advogado, não criptógrafo.

### 00 — Acesso do operador (R0)
- **Três estados na mesma tela**, alternáveis pelo rodapé: credenciais (com erro e
  aviso de tentativas restantes), segundo fator, e primeiro acesso configurando o TOTP.
- **O 2FA é apresentado como obrigatório, não como recurso de segurança opcional.**
  O texto diz por quê: "sua conta controla campanhas e dinheiro de compradores".
  Um checkbox "ativar 2FA depois" tornaria R0 decorativo.
- **Aviso de tentativas restantes antes do bloqueio**, não depois — o operador
  legítimo que errou a senha precisa saber que está perto do limite.
- **Nota de auditoria** ao pé: toda tentativa é registrada. É coerente com um produto
  cuja tese é trilha auditável — inclusive para quem opera.

### 07 — Apurações (R9.3)
Esta é a tela do pior dia: 20h de um sábado, a Federal já sorteou, e o sistema não
conseguiu obter a extração. É onde a UI decide se o operador age com método ou no impulso.

- **O estado crítico vem primeiro**, antes da lista de campanhas. Quem abre esta tela
  num dia normal não precisa dela; quem abre no dia do problema precisa dela imediatamente.
- **"O sistema não inventa resultado"** em bloco escuro de alto contraste. É a garantia
  da spec (`resultado sintético é proibido por design`) dita ao operador no momento em que
  ele está tentado a improvisar. A tela precisa dizer não antes que ele pergunte.
- **Histórico de tentativas com motivo de cada falha** — timeout, HTTP 503, concurso
  divergente. Sem isso o operador não sabe se espera ou se age.
- **Entrada manual assistida como formulário desabilitado até a segunda confirmação.**
  A tela mostra "Segundo responsável: aguardando" e o botão inerte: o controle é visível,
  não uma validação escondida que falha depois de preencher tudo.
- **Limites da retificação exibidos na própria tela**, não só na documentação. Os cinco
  "❌ nunca faz" ficam ao lado do botão que executa a ação — é onde eles importam.
- **Lista de causas fechada, sem opção "outro"**. A spec define quatro causas; um campo
  livre transformaria o controle em formalidade.

### 06 — Painel do operador
- **Funil de conversão, não só total vendido** (US 3). O operador precisa saber
  *onde* perde, e a métrica que importa é Pix gerado → pago.
- **Preparação da apuração como checklist de estado** — inclui a conexão com a ACT,
  que é dependência de caminho crítico (PRD Q6). O operador vê o risco antes do dia.
- **Alerta de vencimento da autorização** (R8), com os 23 dias restantes explícitos.

### 00a — Provisionamento da conta (R0.5)
- **A tela recusa auto-cadastro em voz alta**, e o estado 4 existe só para isso.
  Quem chega pela URL sem convite não vê um formulário nem um 404: vê a razão
  pela qual conta de operador é provisionada à mão. Sem essa tela, alguém
  "conserta" a ausência de cadastro público na semana 3 e abre a superfície
  de abuso que R15 recusa por desenho.
- **Convite expirado é estado de primeira classe** (estado 3), não mensagem de erro.
  É o caminho mais provável na prática — convite de 24 h esquecido numa caixa de
  e-mail — e ele precisa dizer o que fazer agora, com o pedido de reemissão à mão.
- **Os dados do organizador aparecem antes de definir a senha.** Razão social e
  CNPJ visíveis são a única chance de o operador perceber que o convite é da
  empresa errada antes de assumir a conta.
- **A trilha de 3 passos mostra o 2FA como terceiro passo, não como opção.**
  Encadear provisionamento → senha → 2FA na mesma barra torna visualmente
  impossível a leitura de que o segundo fator vem depois, "quando der".

### 01a — Campanha, admin (R1)
- **O portão de publicação é a tela, não um alerta no rodapé.** Os quatro itens
  ficam em lista com o motivo e o atalho para resolver. Publicação bloqueada sem
  dizer *o quê* e *onde consertar* é o padrão que gera ticket de suporte.
- **As duas travas são de naturezas diferentes e a tela diz isso:** autorização
  vencida é lei (R8), conta de recebimento é dinheiro (R10). Nenhuma é
  dispensável por decisão do operador — e a tela não oferece "publicar mesmo assim".
- **Preço e total de números mostram o cadeado antes de travar**, não depois.
  O aviso de imutabilidade aparece junto do campo enquanto ainda é rascunho,
  que é o único momento em que ele serve para algo.
- **A geração de 1M de números é assíncrona e a tela assume isso** (estado 2):
  a campanha já está publicada, a barra informa o progresso e diz que pode
  fechar a aba. Bloquear a tela por 41 s seria mentir sobre o que o backend faz.
- **O upload declara que valida o conteúdo, não a extensão.** É requisito de R1
  e também a explicação de por que um arquivo pode ser recusado.

### 08a — Pedidos, admin (R9.2)
- **O CPF vive mascarado e a busca aceita o completo.** São coisas diferentes:
  procurar por um documento que o operador já tem em mãos é legítimo; exibir
  1.058 CPFs numa listagem é vazamento por conveniência. A tela declara que
  ver o número inteiro é ação registrada.
- **O detalhe escolhido para o protótipo é o pior caso, não o caminho feliz.**
  O pedido #8841 é o Pix pago após a expiração, sem estoque, com estorno
  recusado por saldo — o encadeamento que R10 assumiu como consequência da
  não-custódia. Um detalhe de pedido pago não teria mostrado nada que a
  listagem já não diga.
- **O histórico é uma linha do tempo com origem e horário**, não um `updated_at`.
  Cada transição diz quem a causou — comprador, job de expiração, webhook do
  PicPay — porque a pergunta real do operador nunca é "qual o estado", é
  "como chegou nesse estado".
- **A linha final não é um estado da máquina**, é a espera. `ESTORNO_PENDENTE`
  já apareceu acima; o que o operador precisa ver embaixo é há quanto tempo
  o comprador está esperando e quando é a próxima tentativa.
- **Busca vazia diz que a busca funcionou.** Sem essa frase, resultado vazio é
  lido como sistema quebrado — e o operador liga para o suporte em vez de
  conferir o identificador.
- **Filtro e exportação são a mesma seleção.** O CSV respeita o filtro aplicado
  (R9.2); exportar sempre-tudo transformaria o filtro em decoração.

### 10 — Conta de recebimento (R10)
- **O diagrama do dinheiro tem a bit4devs riscada.** A não-custódia (ADR-17) é
  decisão jurídica e comercial, mas quem lê a tela é o operador: ele precisa ver
  que o Pix vai direto para a conta dele, sem intermediário. Texto explicando
  não teria a mesma força que o nó tachado no fluxo.
- **Titularidade recusada mostra o nome divergente** (estado 3). "Conta inválida"
  não ensina nada; "esta conta é de João P. de Almeida, não do CNPJ da campanha"
  resolve o problema em um passo.
- **Estornos pendentes ficam nesta tela, não em Relatórios.** É aqui que está a
  conta que precisa de saldo — e o `ESTORNO_PENDENTE` só existe porque não há
  custódia. Consequência e causa na mesma tela.
- **O total devido é o número em destaque, em vermelho.** O operador precisa
  sentir que são R$ 145,00 de compradores esperando, não uma linha de tabela.

### 09 — Relatórios (R9.4)
- **Duas coisas diferentes na mesma tela, separadas visualmente:** arrecadação
  (gerencial, exportável) e prestação de contas (documento para o órgão). Misturá-las
  produziria um relatório que não serve para nenhum dos dois usos.
- **O estornado aparece na mesma linha do arrecadado.** Um relatório que só soma
  entradas mente por omissão justamente onde há dinheiro a devolver — e a nota de
  rodapé liga os R$ 145,00 ao `ESTORNO_PENDENTE` da tela 10.
- **O commitment entra na prestação de contas.** É o que diferencia este produto:
  o órgão autorizador recebe a raiz Merkle carimbada, não a palavra do operador.
- **Período vazio é estado desenhado** (R9.5), e diz explicitamente "não é erro de
  carregamento". Tabela vazia sem essa frase é lida como falha do sistema.

### 11 — Estados de exceção, público (R9.6)
- **Esta é a tela que sustenta a tese do produto.** Um produto que vende
  transparência não pode ficar mudo quando algo dá errado — e os seis cenários
  são exatamente os momentos em que o silêncio viraria desconfiança.
- **Apuração pendente nunca mostra número provisório**, e a tela declara isso
  em texto: "o Rifiiis não produz resultado sem origem oficial". O histórico de
  tentativas com horário e código de erro está à vista, porque a alternativa —
  tela em branco com "aguarde" — é indistinguível de sistema quebrado.
- **A retificação exibe o resultado anterior tachado ao lado do vigente.** Esconder
  o resultado revogado seria tecnicamente mais simples e destruiria a auditabilidade:
  quem viu o primeiro número precisa entender o que mudou e por quê.
- **Os limites da retificação estão na tela pública**, não só na documentação
  do operador. É o que impede a leitura de que "retificar" é sinônimo de
  "escolher outro resultado".
- **Suspensão por autorização vencida afirma que bilhete vendido continua válido.**
  A dúvida real de quem já comprou é essa, e ela vem antes de qualquer explicação
  sobre o motivo da suspensão.
- **Cancelamento por ausência de vendas publica o commitment da lista vazia.**
  É o caso em que ninguém foi lesado e a prova parece dispensável — mas é ela
  que impede inserir uma venda retroativa numa campanha "sem movimento".

---

## 4. Acessibilidade

Aplicado em todas as telas:

- Foco visível preservado (`:focus-visible` com contorno de 3px) — nunca removido
- `aria-label` em barra de progresso, QR Code e controles de quantidade
- `aria-live="polite"` na espera do pagamento
- `prefers-reduced-motion` respeitado (spinner e transições)
- Alvos de toque ≥ 44px nos controles de quantidade e CTAs
- Contraste **medido** (não estimado), todos ≥ 4.5:1 (WCAG AA texto normal):

  | Par | Ratio |
  |---|---|
  | texto `#14243a` / papel `#fdf6ee` | 14,59:1 |
  | branco / azul do topo `#123a6b` | 11,39:1 |
  | `--ink-2` / card | 9,67:1 |
  | `--danger` / `--danger-bg` | 6,38:1 |
  | link azul `#1b5aa8` / papel | 6,37:1 |
  | `--verify` `#0f6b46` / `--verify-bg` | 5,76:1 |
  | `--muted` `#5e6b7c` / card | 5,43:1 |
  | `--muted` / papel | 5,06:1 |
  | `--warn` / `--warn-bg` | 5,12:1 |
  | branco / botão laranja `#c94508` | 4,84:1 |

  > **Duas correções vindas de medição, não de olho.** Na paleta anterior, `--muted` e
  > `--warn` reprovaram (4,11 e 4,25). Nesta, o laranja vibrante da referência reprovou
  > em botão (3,58) e virou dois tokens. Em ambos os casos o erro estava na faixa que
  > mais aparece na tela — e em ambos passaria despercebido sem calcular.
- Estrutura semântica (`header`/`main`/`section`/`article`/`nav`), heading hierárquico
- Estados nunca comunicados só por cor: sempre cor + ícone + texto

**Não verificado ainda:** axe-core no browser. O gate de a11y da esteira (`a11y-auditor`)
roda contra a implementação, não contra o protótipo.

---

## 5. Limites deste protótipo

- **Estático.** Botões navegam entre telas; não há estado, cálculo nem backend.
  O stepper não soma, o cronômetro não conta, o verificador não verifica.
- **Dados fictícios.** Campanha, valores, hashes e ganhador são ilustrativos.
  A raiz Merkle exibida é um hash de exemplo, não computada de uma árvore real.
- **Não cobre** — telas com requisito no PRD v1.3 e sem protótipo (ver §6.1 do PRD,
  tabela de rastreabilidade):
  - R1 · admin de campanha (criar, editar, publicar, upload da imagem)
  - R9.2 · detalhe do pedido e busca por CPF
  - R9.4 · relatórios
  - R9.6 · estados de exceção (sem vendas, apuração pendente, suspensa, entrega pendente, retificada)

  Estas são a próxima leva do protótipo. A mais relevante que resta é R9.6 (estados
  de exceção na área pública) — a contraparte visível ao comprador do que a tela 07
  já resolve do lado do operador.

- **Correção aplicada em 30/08:** a navegação do painel mostrava "Configurações",
  item sem requisito correspondente e fora do escopo da v1. Removido. O protótipo
  não deve prometer superfície que o PRD não especifica — foi essa divergência que
  quase levou a área administrativa para desenvolvimento sem especificação.
- **Fontes via CDN Google Fonts** — na implementação, servir localmente para não
  depender de terceiro no caminho crítico da página de campanha.

---

## 6. Fontes da pesquisa

- [Rifei](https://rifei.com.br/) · [Rifafy](https://rifafy.com/) · [RifApp](https://rifapp.com.br/)
- [VouRifar](https://vourifar.com.br/) · [TecnoRifa](https://www.tecnorifa.com.br/sobre)
- [RiffaDigital](https://www.riffadigital.com.br/) · [123Rifas](https://123rifas.com/acao/rifa-online)
- [Rifa.online](https://www.rifa.online/) · [Rifeme](https://www.rifeme.com.br/)
- [Plataforma Rifa](https://plataformarifa.com.br/) · [Sistema BRN](https://brnsistema.com.br/)

---

## 6.1 Estilo de app mobile (segunda referência do cliente)

Uma segunda peça — mockup de duas telas de celular — trouxe uma direção mais próxima
de aplicativo do que de site. Foi adotada em `08-home-app` e `03a-acesso-comprador`.

**O que foi adotado:**

| Elemento | Aplicação |
|---|---|
| Fundo azul sólido (`--app-bg` `#1c4fa1`) | Substitui o papel claro nas telas de app |
| Card laranja com borda dura e sombra sólida | `3px` de `--borda-dura` + `box-shadow: 0 6px 0` — dá o volume de adesivo do mockup |
| Cantos muito arredondados, botões em pílula | `border-radius: 99px` nos CTAs e campos |
| Tipografia mais pesada | `font-weight: 900` em títulos, com sombra de texto |
| **Barra de navegação inferior** | Home / Meus Bilhetes / Perfil / Suporte — padrão mobile que faltava |
| Grade de sorteios numerada | Números em círculo na quina do card, como na referência |
| Bordões da marca | "Participis já", "Digitis o códigis", "Meus bilhetis" |

**O que foi ajustado, e por quê medido:** o mockup usa **texto branco sobre o card laranja**,
que rende apenas **2,45:1** — reprova até o limite de texto grande (3:1). A pedido do cliente,
todo o texto sobre os cards laranja usa **verde escuro** `--texto-card` (`#0d3324`): **5,64:1**
sobre o laranja claro e **4,70:1** sobre o tom mais fechado do gradiente — passa AA nos dois.
Entre os candidatos de verde escuro testados, foi o único que passou em ambos os tons.

Nota de disciplina: `#0d3324` não colide com o verde-selo `--verify` (`#0f6b46`) — são
tons distantes (o selo é claramente mais vivo), e o selo continua aparecendo apenas em
contexto de prova, sobre fundo claro próprio, nunca sobre o card laranja.

**O que não foi adotado:** o login por usuário e senha que o mockup mostra. O acesso do
comprador continua sendo CPF → código por WhatsApp (R7.5 / ADR-19), decisão tomada
deliberadamente para não reintroduzir senha num público que compra em 60 segundos.
O visual da tela seguiu o mockup; o mecanismo, não.

---

## 6.2 Retema completo para o tema app (30/08/2026)

O tema app deixou de ser exclusivo das telas 08/03a: **todas as 12 páginas** agora seguem
a mesma linguagem. Executado por workflow de 20 agentes (10 restyle + 10 verificação
adversarial por tela, zero reprovações), com passada final de conferência humana
(links, tags, tokens, renders).

Regra de superfície consolidada:
- **Card de ação** (compra, formulário, login) = laranja com borda dura, texto `--texto-card`
- **Card de documento** (tabela, resultado, prova, KPI, listas densas) = branco com a mesma
  borda dura — conteúdo denso não vai para laranja
- **Tabbar** só nas telas do comprador (01, 02a, 02, 03, 03a, 08); páginas públicas de
  auditoria (04, 05) e admin (00, 06, 07) não têm
- Verde de prova, dourado de prêmio e semânticas warn/danger preservados em todas

## 6.3 Logo

Wordmark **RIFIIIS** fornecido pelo cliente como arte bitmap e **recriado em SVG vetorial**
(autocontido, inline em cada tela — sem asset externo): "RIF" branco + "IIIS" em gradiente
laranja, contorno azul-marinho com contorno branco externo de adesivo, dois trevos de
3 lóbulos e celular atrás do S. Fonte Nunito 900 (adicionada ao link de fonts).

- Inserido no topo/sidebar de todas as 12 páginas, `role="img" aria-label="Rifiiis"`
- Preview e fonte de edição: `hi-fi/_logo-preview.html`
- Por ser SVG, escala do favicon ao hero sem perda; funciona sobre azul, creme e escuro

---

## 7. Marca e identidade

**Nome:** Rifiiis · domínio `rifiiis.com.br` (verificado disponível em 30/08/2026).

A identidade visual deriva da peça de campanha do próprio cliente: laranja quente,
azul institucional e tom popular, dirigido a tráfego de Instagram e WhatsApp.

**O que foi adotado da referência:** paleta laranja/azul, calor visual, energia de
campanha popular.

**O que não foi adotado, e por quê:** a peça original usa a imagem e o bordão de uma
personalidade real. Personagem, bordão e pastiche de fala ficaram fora do produto —
direito de imagem de pessoa falecida pertence aos herdeiros, e uma pendência dessas
contradiz frontalmente a tese de um produto que vende lastro documental e conformidade.
A paleta é livre; a persona não é.

**Ponto em aberto para o cliente:** o nome deriva de um bordão associado a essa mesma
personalidade. Vale consultar o INPI antes de investir na marca — é decisão comercial
do cliente, não impedimento técnico.
