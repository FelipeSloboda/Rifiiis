---
id: deck-executivo
etapa: 13
data: 2026-09-08
status: done
---

# DECK EXECUTIVO — Dream RI

Roteiro de 10 slides. Conteúdo, não design.

---

**1 · Abertura**
> "Como você prova que sua rifa não foi fraudada?"
Hoje a resposta é um print. Um print prova nada.

**2 · O problema**
Rifa online opera por confiança cega. Três perguntas sem resposta verificável: meu número estava
na lista? A lista mudou depois do sorteio? O prêmio foi entregue?
O efeito colateral: **o operador honesto é indistinguível do desonesto.**

**3 · O tamanho do problema**
Acusação pública de fraude derruba venda e não tem defesa. Quem organiza rifa já viveu isso.
*(Sem número de mercado — não temos pesquisa primária. Ver [MARKET.md](../MARKET.md).)*

**4 · A solução**
Compromisso criptográfico publicado **antes** do sorteio, carimbado por autoridade ICP-Brasil.
Aleatoriedade da Loteria Federal. Verificação por qualquer um, sem nos consultar.

**5 · Como funciona** — quatro passos
Congela a lista → publica a impressão digital carimbada → a Federal sorteia → qualquer um
recomputa e confere.

**6 · O diferencial**
| | Mercado | Dream RI |
|---|---|---|
| Sorteio | Interno ou Federal sem prova | Federal com commitment |
| Lista | Editável | Congelada e carimbada |
| Prova | Print | Prova de inclusão |
| Verificação | Impossível | Sem contato conosco |
| Custódia | Frequente | **Nunca** |

**7 · A tecnologia, em uma frase**
Merkle RFC 6962 + carimbo RFC 3161 com validade sob a MP 2.200-2/2001. Não é blockchain — é o
mecanismo que o fiscal brasileiro já reconhece.

**8 · O que já está decidido**
26 decisões de arquitetura registradas com a alternativa recusada. Sem custódia, sem edição de
apuração, sem resultado sintético — todas garantidas por construção, não por política.

**9 · Estado e prazo**
Seis semanas. Marco de verdade em D+21: apuração ensaiada e conferida por terceiro usando só o
que é público. Três dependências externas em D+7 (PSP, autoridade de carimbo, lojas).

**10 · Fechamento**
> "Não pedimos que confiem em nós. Pedimos que confiram."

---

## Perguntas difíceis, e as respostas honestas

| Pergunta | Resposta |
|---|---|
| "E se o comprador não se importar?" | Risco real (RSK-01). A mitigação é o operador vender a prova, não nós educarmos o comprador |
| "Por que não blockchain?" | Porque o destinatário da prova é o fiscal brasileiro, e a MP 2.200-2 já resolve isso |
| "Vocês podem manipular?" | Não temos a fonte de aleatoriedade. E o carimbo é anterior à extração — está fora do nosso alcance |
| "E se a autoridade de carimbo cair?" | A campanha bloqueia. É o gap mais caro do projeto, e está declarado |
| "Qual o modelo de receita?" | Licença ou mensalidade. Sem custódia, não há percentual — foi decisão consciente |
