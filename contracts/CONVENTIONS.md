---
id: contracts-conventions
etapa: 7
data: 2026-09-08
status: done
---

# CONVENÇÕES DE CONTRATO — Dream RI

## Fonte única

O OpenAPI é **gerado dos decorators do NestJS**, nunca escrito à mão. App e web consomem cliente
gerado. Isso elimina a classe de bug "o front acha que o campo é opcional e o back acha que não".

Consequência prática: **não edite o arquivo em `contracts/openapi/`** — ele é artefato de build.
Para mudar o contrato, mude o DTO.

## Versionamento

| Regra | Detalhe |
|---|---|
| Prefixo | `/api` para privado, `/webhooks` para entrada de terceiro |
| Versão | Sem versão na URL no MVP — um cliente, controlado por nós |
| Quebra de contrato | Exige ADR. O app na loja pode estar em versão antiga por dias |

> **A restrição que o app impõe.** Diferente da web, o app do usuário não atualiza quando
> publicamos. Uma mudança incompatível quebra quem não atualizou — e a fila da loja pode levar
> dias. Toda mudança de contrato é aditiva por padrão.

## Erros

Formato único, sem exceção:

```json
{
  "code": "LIMITE_CPF_EXCEDIDO",
  "message": "Mensagem legível ao usuário final",
  "details": { }
}
```

| Regra | Motivo |
|---|---|
| `code` é constante em UPPER_SNAKE_CASE | O cliente decide comportamento por `code`, nunca por `message` |
| `message` é em PT-BR, para o usuário | i18n do app usa `code` como chave |
| `details` nunca contém PII | RNF-06 |
| 401 e 404 não revelam existência | TH-070: campanha de outro tenant é 404, não 403 |

### Códigos de erro do domínio

| Code | HTTP | Quando |
|---|:-:|---|
| `CAMPANHA_CONGELADA` | 409 | Pedido após congelamento |
| `ESTOQUE_INSUFICIENTE` | 409 | Números pedidos > disponíveis |
| `LIMITE_CPF_EXCEDIDO` | 422 | Limite da campanha atingido |
| `AUTORIZACAO_INVALIDA` | 422 | Publicar sem autorização válida |
| `CONTA_NAO_VERIFICADA` | 422 | Publicar sem conta de recebimento |
| `SEGUNDO_FATOR_NECESSARIO` | 401 | Sessão sem 2FA em rota admin |
| `CODIGO_EXPIRADO` | 401 | Código de acesso do comprador vencido |
| `RESPONSAVEL_DUPLICADO` | 422 | Mesma pessoa nas duas confirmações |

## Idempotência

| Rota | Chave | TTL |
|---|---|---|
| `POST /api/pedidos` | Header `Idempotency-Key` (obrigatório) | 24h em Redis |
| `POST /webhooks/psp/:provedor` | `(provedor, evento_id)` no banco | permanente |

## Paginação

`?limit=` e `?cursor=`. **Não** usar `offset` — a listagem de pedidos muda sob concorrência, e
offset repete ou pula registro.

## Datas e valores

| Tipo | Formato | Motivo |
|---|---|---|
| Timestamp | ISO 8601 em UTC, com `Z` | Sem ambiguidade de fuso |
| Data (extração) | `YYYY-MM-DD` | É data civil, não instante |
| Dinheiro | Inteiro em **centavos**, sufixo `_cents` | Float em dinheiro é defeito |
| CPF | String de 11 dígitos, sem máscara | Máscara é da apresentação |

## Nomenclatura

Campos em `snake_case` no JSON (espelha o banco e o SQL sem ORM); `camelCase` no cliente TS
gerado. A conversão é do gerador, não manual.
