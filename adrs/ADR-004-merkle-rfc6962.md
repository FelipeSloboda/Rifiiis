# ADR-004 — Árvore Merkle no padrão RFC 6962

**Status:** aceita · **Contexto:** SPEC §6 fase 3

## Decisão

Árvore Merkle conforme RFC 6962 (Certificate Transparency), com separação de domínio obrigatória:

```
folha   = SHA256(0x00 ‖ dados)
interno = SHA256(0x01 ‖ esq ‖ dir)
```

Nós ímpares são **promovidos** sem re-hash — comportamento do RFC, não duplicação.

## Alternativa recusada

**Hash simples da lista inteira.** Muito mais simples de implementar.

## Por quê

Com hash único da lista, provar que *um* número estava incluído exige baixar a lista **inteira**
— 40 MB para 1M de números. Com Merkle, a prova de inclusão são ~20 hashes: **640 bytes**.

A diferença não é de performance, é de **viabilidade da persona P3**: um comprador no celular não
baixa 40 MB para conferir um número. Se a verificação for cara, ninguém verifica, e a tese morre
por desuso.

## Por que a separação de domínio não é opcional

Sem os prefixos `0x00`/`0x01`, um nó interno pode ser apresentado como folha — ataque de segunda
pré-imagem. E duplicar o último nó (em vez de promover) abre **ambiguidade de árvore**: duas
listas diferentes podem produzir a mesma raiz.

Ambos os erros são silenciosos: a implementação funciona, os testes passam, e a prova não vale
nada. Por isso este é um dos pontos cobertos pelo [ADR-012](ADR-012-verificacao-independente-ia.md)
— vetores vêm do RFC, nunca da sessão que escreveu o código.

## Consequências

- Prova de inclusão de 640 bytes cabe no comprovante e no app.
- Construção de 1M de folhas em < 2s (RNF-04).
- A raiz é recomputável por qualquer implementação que siga o RFC — o auditor não precisa da nossa.
