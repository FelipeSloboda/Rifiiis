---
id: glossario-ubiquo
etapa: 2
data: 2026-09-08
status: done
---

# GLOSSÁRIO UBÍQUO — Dream RI

Vocabulário vinculante: o termo aqui é o termo no código, na issue, na tela e na conversa.
Onde houver sinônimo de uso comum, ele está listado como **evitar**.

---

## Domínio do sorteio

| Termo | Definição | Evitar |
|---|---|---|
| **Campanha** | Uma rifa: título, prêmio, preço, total de números, data de extração, regra de apuração e autorização do órgão | "sorteio", "rifa" (no código) |
| **Número da sorte** | Unidade vendável. Tem `numero` (visível) e `ordem` (posição pré-embaralhada de alocação) | "bilhete" — bilhete é a unidade de **compra** |
| **Bilhete** | Unidade de compra; pode conter N números | usar como sinônimo de número |
| **Congelamento** | Transição que encerra a venda, T-2h da extração. Depois dela nenhum pedido vira pago | "fechar campanha" |
| **Commitment** | Compromisso criptográfico: raiz Merkle da lista de vendidos + carimbo do tempo | "hash da lista" (impreciso) |
| **Snapshot** | Lista canônica NDJSON dos números pagos no congelamento. Público, sem PII | "dump", "backup" |
| **Leaf hash** | Hash da folha do comprador: `SHA256(0x00 ‖ numero ‖ Argon2id(cpf, salt) ‖ pedido ‖ pago_em)` | "hash do comprador" |
| **Prova de inclusão** | Caminho Merkle (~20 hashes) que prova que uma folha está na árvore | "prova", sozinho |
| **Extração** | Resultado oficial da Loteria Federal de uma data | "sorteio", "resultado da Caixa" |
| **Apuração** | Aplicação da regra publicada à extração para achar o ganhador | "sorteio" |
| **Retificação** | Correção pública de apuração com insumo errado; preserva a original | "edição", "correção" (sugere sobrescrita) |
| **Entrega** | Registro de que o prêmio chegou ao ganhador, com comprovante | "conclusão" |

---

## Domínio do dinheiro

| Termo | Definição | Evitar |
|---|---|---|
| **Pedido** | Intenção de compra com números reservados e cobrança emitida | "carrinho", "order" |
| **Reserva** | Estado temporário do número, com TTL; não é posse | "pré-venda" |
| **Atribuição** | Passagem do número a definitivo após pagamento confirmado | "confirmação" |
| **Conta de recebimento** | Conta do **operador** no PSP para onde o Pix vai direto | "conta da plataforma" — não existe |
| **Estorno pendente** | Devolução que falhou (tipicamente saldo) e está na fila com retry | "reembolso falho" |
| **PSP** | Provedor de serviço de pagamento. No MVP, PicPay (ADR-21) | "gateway" (o código usa `GatewayDePagamento` como porta) |

---

## Domínio dos atores

| Termo | Definição | Evitar |
|---|---|---|
| **Operador** | Quem organiza a campanha; cliente da plataforma; titular da conta de recebimento | "admin", "lojista" |
| **Comprador** | Quem compra números. Titular de dados no sentido da LGPD | "cliente" — cliente é o operador |
| **Titular-comprador** | Comprador, quando o assunto é LGPD. Distingue do operador, que também é titular | — |
| **Auditor** | Terceiro que verifica sem acesso ao sistema | "fiscal" |
| **Ganhador** | Comprador cujo número foi apurado | "vencedor" |

---

## Domínio técnico com carga de negócio

| Termo | Definição | Por que importa |
|---|---|---|
| **Crypto-shredding** | Apagar a chave do titular torna a PII ilegível **sem** remover bytes | Preserva a cadeia de auditoria (SPEC §9) |
| **DEK / KEK** | Chave de dados do titular / chave que a embrulha, externa ao banco | Apagar a DEK **é** o shredding |
| **`cpf_indice`** | Argon2id(CPF, salt do tenant). Pseudônimo que sobrevive ao shredding | Sustenta limite por CPF e consulta |
| **Cadeia de auditoria** | Tabela append-only encadeada por hash do registro | Se o hash fosse do texto claro, o shredding a quebraria |
| **Alocação atômica** | `SKIP LOCKED` sobre tabela pré-embaralhada | Duas pessoas nunca recebem o mesmo número |
| **Anonimização** | `UPDATE` que zera PII do **operador** preservando FKs | Não confundir com shredding (que é do comprador) |
| **Expurgo** | Remoção de `ip`/`user_agent` de sessão em D+90 | Retenção, não direito do titular |

---

## Termos proibidos

| Não use | Porque |
|---|---|
| "sortear" para escolher ganhador | O sistema **não** sorteia — aplica regra à extração externa. A palavra sugere aleatoriedade nossa |
| "cancelar apuração" | Não existe. Existe **retificação**, que preserva a original |
| "deletar comprador" | Não existe. Existe apagar a **chave** (shredding) |
| "conta da plataforma" | Não existe. ADR-17: sem custódia |
| "resultado provisório" | Resultado publicado é definitivo até retificação formal |
