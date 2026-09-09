---
id: lean-canvas
etapa: 1
data: 2026-09-08
status: done
---

# LEAN CANVAS — Dream RI

| Bloco | Conteúdo |
|---|---|
| **1. Problema** | (a) Comprador não tem como verificar se o sorteio foi honesto. (b) Operador honesto não tem como provar que é. (c) Órgão autorizador recebe prestação de contas que não dá para auditar. **Alternativas hoje:** print/live no Instagram, planilha, palavra do operador. |
| **2. Segmentos** | Operador de rifa autorizado (P1) · comprador (P2) · auditor/órgão (P3). **Early adopter:** operador que já sofreu acusação pública de fraude e quer se diferenciar. |
| **3. Proposta de valor única** | *O único sorteio que o comprador verifica sozinho.* Commitment carimbado antes da extração + prova Merkle no comprovante. |
| **4. Solução** | Congelamento → snapshot → árvore Merkle → carimbo RFC 3161 → apuração pela Loteria Federal → verificador público. |
| **5. Canais** | Página pública da campanha (SEO/link compartilhável) · app nas duas lojas · WhatsApp do operador. |
| **6. Fontes de receita** | Licença por campanha ou mensalidade do operador. **Não** é percentual sobre arrecadação — ver Q5 e ADR-17. |
| **7. Estrutura de custo** | VPS + Postgres/Redis · carimbo do tempo por campanha (ACT) · taxa Pix do PSP (paga pelo operador) · contas de loja. Detalhe em [infra/COST_MODEL.md](../infra/COST_MODEL.md). |
| **8. Métricas-chave** | Taxa Pix gerado→pago · verificações do comprovante por campanha · apurações sem intervenção manual. |
| **9. Vantagem injusta** | A prova pública é **antifrágil**: quanto mais gente verifica, mais forte fica. Um concorrente que copie a tela não copia o carimbo já emitido — e o histórico de campanhas verificadas não se falsifica retroativamente. |

## O risco que o canvas esconde

O bloco 3 assume que **o comprador se importa** com verificabilidade. É a hipótese mais frágil do
produto: ele pode simplesmente querer o prêmio. A mitigação não é convencê-lo — é fazer o
operador ser o vendedor da prova ("compre aqui, aqui você confere"). Registrado como
[RSK-01](../RISKS.md).
