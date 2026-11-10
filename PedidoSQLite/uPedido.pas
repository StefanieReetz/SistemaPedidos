unit uPedido;

{ Classes do pedido:
  - TItemPedido: uma linha do pedido (guarda uma CÓPIA da descrição e do preço,
    assim, se o preço do produto mudar depois, o pedido antigo não muda)
  - TPedido: cliente + lista de itens + total
  - TListaPedidos: lê e grava os pedidos no banco (herda de TRepositorio) }

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  uBancoDados, uItem;

type
  TItemPedido = class
  private
    FCodigoItem: Integer;
    FTipo: string;
    FDescricao: string;
    FQuantidade: Double;
    FPrecoUnitario: Currency;
  public
    function Subtotal: Currency;

    property CodigoItem: Integer read FCodigoItem write FCodigoItem;
    property Tipo: string read FTipo write FTipo;
    property Descricao: string read FDescricao write FDescricao;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property PrecoUnitario: Currency read FPrecoUnitario write FPrecoUnitario;
  end;

  TPedido = class
  private
    FNumero: Integer;
    FData: TDateTime;
    FCliente: string;
    FItens: TObjectList<TItemPedido>;
  public
    constructor Create;
    destructor Destroy; override;

    /// Aceita qualquer TItem: produto ou serviço
    procedure AdicionarItem(AItem: TItem; AQuantidade: Double);
    procedure RemoverItem(AIndice: Integer);
    function Total: Currency;
    procedure Validar;
    function Resumo: string;

    property Numero: Integer read FNumero write FNumero;
    property Data: TDateTime read FData write FData;
    property Cliente: string read FCliente write FCliente;
    property Itens: TObjectList<TItemPedido> read FItens;
  end;

  TListaPedidos = class(TRepositorio)
  private
    FPedidos: TObjectList<TPedido>;
    procedure CarregarItens(APedido: TPedido);
  public
    constructor Create(ABanco: TBancoDados);
    destructor Destroy; override;

    procedure Carregar;
    /// Valida e grava o pedido no banco. Quem chamou continua dono do objeto.
    procedure Adicionar(APedido: TPedido);

    property Pedidos: TObjectList<TPedido> read FPedidos;
  end;

implementation

{ TItemPedido }

function TItemPedido.Subtotal: Currency;
begin
  Result := FPrecoUnitario * FQuantidade;
end;

{ TPedido }

constructor TPedido.Create;
begin
  inherited Create;
  FItens := TObjectList<TItemPedido>.Create(True);
  FData := Now;
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TPedido.AdicionarItem(AItem: TItem; AQuantidade: Double);
var
  ItemPedido: TItemPedido;
begin
  if AItem = nil then
    raise Exception.Create('Selecione um item.');
  if AQuantidade <= 0 then
    raise Exception.Create('A quantidade deve ser maior que zero.');

  // Se o item já está no pedido, só aumenta a quantidade
  for ItemPedido in FItens do
    if (ItemPedido.CodigoItem = AItem.Codigo) and (ItemPedido.Tipo = AItem.Tipo) then
    begin
      ItemPedido.Quantidade := ItemPedido.Quantidade + AQuantidade;
      Exit;
    end;

  ItemPedido := TItemPedido.Create;
  ItemPedido.CodigoItem := AItem.Codigo;
  ItemPedido.Tipo := AItem.Tipo;            // 'Produto' ou 'Serviço' (polimorfismo)
  ItemPedido.Descricao := AItem.Descricao;
  ItemPedido.PrecoUnitario := AItem.Preco;
  ItemPedido.Quantidade := AQuantidade;
  FItens.Add(ItemPedido);
end;

procedure TPedido.RemoverItem(AIndice: Integer);
begin
  if (AIndice < 0) or (AIndice >= FItens.Count) then
    raise Exception.Create('Selecione o item que deseja remover.');
  FItens.Delete(AIndice);
end;

function TPedido.Total: Currency;
var
  ItemPedido: TItemPedido;
begin
  Result := 0;
  for ItemPedido in FItens do
    Result := Result + ItemPedido.Subtotal;
end;

procedure TPedido.Validar;
begin
  if Trim(FCliente) = '' then
    raise Exception.Create('Informe o nome do cliente.');
  if FItens.Count = 0 then
    raise Exception.Create('Adicione pelo menos um item ao pedido.');
end;

function TPedido.Resumo: string;
var
  ItemPedido: TItemPedido;
begin
  Result := Format('Pedido nº %d - %s', [FNumero, FormatDateTime('dd/mm/yyyy hh:nn', FData)]) +
    sLineBreak + 'Cliente: ' + FCliente + sLineBreak + sLineBreak;

  for ItemPedido in FItens do
    Result := Result + Format('%s x %s = R$ %s', [FormatFloat('0.###', ItemPedido.Quantidade),
      ItemPedido.Descricao, FormatCurr('#,##0.00', ItemPedido.Subtotal)]) + sLineBreak;

  Result := Result + sLineBreak + 'Total: R$ ' + FormatCurr('#,##0.00', Total);
end;

{ TListaPedidos }

constructor TListaPedidos.Create(ABanco: TBancoDados);
begin
  inherited Create(ABanco);
  FPedidos := TObjectList<TPedido>.Create(True);
end;

destructor TListaPedidos.Destroy;
begin
  FPedidos.Free;
  inherited;
end;

procedure TListaPedidos.Carregar;
var
  Qry: TFDQuery;
  Pedido: TPedido;
begin
  FPedidos.Clear;
  Qry := NovaQuery('SELECT * FROM pedido ORDER BY numero DESC');
  try
    Qry.Open;
    while not Qry.Eof do
    begin
      Pedido := TPedido.Create;
      FPedidos.Add(Pedido);
      Pedido.Numero := Qry.FieldByName('numero').AsInteger;
      Pedido.Data := Qry.FieldByName('data').AsDateTime;
      Pedido.Cliente := Qry.FieldByName('cliente').AsString;
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;

  for Pedido in FPedidos do
    CarregarItens(Pedido);
end;

procedure TListaPedidos.CarregarItens(APedido: TPedido);
var
  Qry: TFDQuery;
  ItemPedido: TItemPedido;
begin
  Qry := NovaQuery('SELECT * FROM pedido_item WHERE numero_pedido = :numero ORDER BY id');
  try
    Qry.ParamByName('numero').AsInteger := APedido.Numero;
    Qry.Open;
    while not Qry.Eof do
    begin
      ItemPedido := TItemPedido.Create;
      APedido.Itens.Add(ItemPedido);
      ItemPedido.CodigoItem := Qry.FieldByName('codigo_item').AsInteger;
      ItemPedido.Tipo := Qry.FieldByName('tipo').AsString;
      ItemPedido.Descricao := Qry.FieldByName('descricao').AsString;
      ItemPedido.Quantidade := Qry.FieldByName('quantidade').AsFloat;
      ItemPedido.PrecoUnitario := Qry.FieldByName('preco_unitario').AsCurrency;
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TListaPedidos.Adicionar(APedido: TPedido);
var
  Qry: TFDQuery;
  ItemPedido: TItemPedido;
begin
  APedido.Validar;   // se der erro, para aqui e nada é gravado
  APedido.Data := Now;

  // TRANSAÇÃO: grava o pedido e todos os itens juntos. Se algo falhar, desfaz tudo.
  Banco.Conexao.StartTransaction;
  try
    Qry := NovaQuery('INSERT INTO pedido (data, cliente) VALUES (:data, :cliente)');
    try
      Qry.ParamByName('data').AsDateTime := APedido.Data;
      Qry.ParamByName('cliente').AsString := APedido.Cliente;
      Qry.ExecSQL;
    finally
      Qry.Free;
    end;

    // Pega o número que o banco gerou (AUTOINCREMENT)
    APedido.Numero := Banco.Conexao.GetLastAutoGenValue('');

    Qry := NovaQuery(
      'INSERT INTO pedido_item (numero_pedido, codigo_item, tipo, descricao, quantidade, preco_unitario) ' +
      'VALUES (:numero, :codigo, :tipo, :descricao, :quantidade, :preco)');
    try
      for ItemPedido in APedido.Itens do
      begin
        Qry.ParamByName('numero').AsInteger := APedido.Numero;
        Qry.ParamByName('codigo').AsInteger := ItemPedido.CodigoItem;
        Qry.ParamByName('tipo').AsString := ItemPedido.Tipo;
        Qry.ParamByName('descricao').AsString := ItemPedido.Descricao;
        Qry.ParamByName('quantidade').AsFloat := ItemPedido.Quantidade;
        Qry.ParamByName('preco').AsCurrency := ItemPedido.PrecoUnitario;
        Qry.ExecSQL;
      end;
    finally
      Qry.Free;
    end;

    Banco.Conexao.Commit;
  except
    Banco.Conexao.Rollback;
    APedido.Numero := 0;
    raise;
  end;

  Carregar;
end;

end.
