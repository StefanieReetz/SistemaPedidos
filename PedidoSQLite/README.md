# Sistema de Pedidos com SQLite — Delphi 13

Projeto de estudo: cadastro de **produtos** e **serviços** e lançamento de **pedidos**,
com orientação a objetos, **herança** e banco de dados **SQLite** (via FireDAC, que já
vem no Delphi, inclusive no Community).

- Um único projeto, todos os arquivos na mesma pasta
- Uma única tela, com 3 abas
- O banco `pedidos.db` é criado sozinho ao lado do `.exe`, já com 4 itens de exemplo

## Como abrir

1. Extraia o zip numa pasta **sem acentos no caminho** (ex.: `C:\Estudos\PedidoSQLite`).
2. Delphi → **File > Open Project...** → escolha `PedidoSQLite.dpr`.
3. Se o Delphi perguntar algo sobre criar/atualizar o projeto, confirme. Depois **File > Save All**.
4. **F9** para rodar.

Para ver as tabelas e os dados gravados, abra o `pedidos.db` no programa gratuito
**DB Browser for SQLite** (feche o sistema antes).

### Se der erro em alguma unit do FireDAC
Crie um projeto VCL qualquer, coloque um `TFDConnection` no formulário e mude o
`DriverName` para `SQLite`. O Delphi adiciona sozinho as units certas no `uses`:
copie essa lista para o `uses` do `uBancoDados.pas`.

## Arquivos

| Arquivo | O que tem |
|---|---|
| `uBancoDados.pas` | `TBancoDados` (conexão e criação das tabelas) e `TRepositorio` (classe base) |
| `uItem.pas` | `TItem` (pai), `TProduto` e `TServico` (filhos) — **herança** |
| `uCatalogo.pas` | `TCatalogo` (herda de `TRepositorio`): SQL de produtos e serviços |
| `uPedido.pas` | `TItemPedido`, `TPedido` e `TListaPedidos` (herda de `TRepositorio`) |
| `uPrincipal.pas/.dfm` | A tela |

## Tabelas

- **item** — produtos e serviços juntos; a coluna `tipo` vale `P` ou `S`
- **pedido** — número, data e cliente
- **pedido_item** — itens de cada pedido (com cópia da descrição e do preço)

## Conceitos para observar no código

- **Herança**: `TProduto = class(TItem)` e `TCatalogo = class(TRepositorio)`.
- **Polimorfismo**: `Tipo`, `Detalhe` e `Validar` são `virtual` no pai e `override` nos filhos.
- **`inherited`**: `TProduto.Validar` chama primeiro a validação do pai.
- **`is` e typecast**: `if Item is TProduto then TProduto(Item).Unidade`.
- **SQL com parâmetros** (`:descricao`): nunca juntar texto digitado direto no SQL.
- **Transação**: `TListaPedidos.Adicionar` grava pedido + itens juntos, ou nada.
- **Memória**: quem cria com `.Create` libera com `.Free`, sempre com `try..finally`.
  Ao fechar o programa, se algo vazar, o Delphi avisa.

## Exercícios sugeridos

1. Criar a busca por descrição (`WHERE descricao LIKE :filtro`).
2. Botão para excluir um pedido (lembre de apagar também os itens dele).
3. Adicionar estoque em `TProduto` (nova coluna) e não deixar vender acima do estoque.
4. Criar a tabela e o cadastro de clientes (`TCliente`) e escolher o cliente numa lista.
5. Criar um terceiro tipo de item, por exemplo `TKit = class(TItem)`.
