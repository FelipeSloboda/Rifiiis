---
id: security-checklist
etapa: 12
data: 2026-09-08
status: done
---

# CHECKLIST DE SEGURANÇA POR FEATURE — Dream RI

Usado pelo `security-auditor` (Etapa 11). Derivado do
[THREAT_MODEL](THREAT_MODEL.md) e do OWASP Top 10 (2025).

## Transversal — vale para todo PR

- [ ] Zod em todo boundary novo; nenhum `any`
- [ ] SQL parametrizado; zero concatenação
- [ ] Erro não vaza stack nem estrutura interna
- [ ] `tenant_id` verificado **no repositório**, não só no guard
- [ ] Nenhum segredo literal
- [ ] Log sem PII (redator no transporte)
- [ ] 404 em vez de 403 quando revelar existência é problema

## F01 · Acesso (TH-001..007)

- [ ] Argon2id na senha, parâmetros do RFC 9106
- [ ] Login não emite sessão utilizável em rota admin
- [ ] `segundo_fator_em` verificado no guard **e** no repositório
- [ ] Resposta idêntica para e-mail inexistente e senha errada
- [ ] Bloqueio por tentativas
- [ ] Refresh rotativo; reuso revoga
- [ ] Segredo TOTP cifrado

## F02 · Campanha e conta (TH-010..014)

- [ ] Publicação bloqueada sem conta verificada e autorização válida
- [ ] Preço, total e regra imutáveis após publicar
- [ ] Titularidade conferida contra CNPJ
- [ ] Troca de conta exige 2º fator

## F03 · Alocação (TH-020..023)

- [ ] `SKIP LOCKED` sobre índice parcial
- [ ] Teste de concorrência **falha** contra ingênua
- [ ] TTL de reserva + rate limit contra exaustão de estoque
- [ ] `ordem` nunca exposta em API pública

## F04 · Pagamento (TH-030..036)

- [ ] **Valor vem da reconsulta ao PSP, nunca do corpo do webhook**
- [ ] Idempotência `(provedor, evento_id)`
- [ ] `Idempotency-Key` obrigatório na criação de pedido
- [ ] Payload do webhook cifrado
- [ ] Rate limit no checkout
- [ ] Consentimento com versão, timestamp e IP

## F05 · Commitment (TH-040..046)

- [ ] Carimbo **anterior** à extração, verificado
- [ ] Um commitment por campanha (cardinalidade no banco)
- [ ] Separação de domínio `0x00`/`0x01`
- [ ] Nó ímpar promovido, não duplicado
- [ ] `salt_campanha` nunca em resposta de API nem em log
- [ ] Salts de índice e leaf **distintos**
- [ ] Object-lock ativo no storage

## F06 · Apuração (TH-050..055)

- [ ] Nenhum caminho de código produz extração sintética
- [ ] Entrada manual exige dois `operador_id` distintos
- [ ] Nenhuma rota edita apuração publicada
- [ ] Retificação: causa fechada + dupla autorização + original preservada
- [ ] Números não vendidos fora da apuração

## F07 · LGPD (TH-060..065)

- [ ] `cpf_indice` em Argon2id com salt por tenant
- [ ] Salt em coluna cifrada, **não** em variável de ambiente
- [ ] Teste `crypto-shredding` verde
- [ ] Cadeia de auditoria sobre registro cifrado
- [ ] Nenhuma rota apaga operador
- [ ] Expurgo de sessão em D+90 rodando (métrica > 0 alerta)

## F08 · Painel (TH-070..072)

- [ ] Campanha de outro tenant retorna 404
- [ ] CPF mascarado por padrão
- [ ] Exportação com o mínimo de PII

---

## O item que reprova mais PR do que se espera

**`tenant_id` verificado no repositório.** É fácil confiar no guard e esquecer a segunda camada —
e o teste que pega isso não é o de feature, é o de segurança. Está na lista transversal por isso.
