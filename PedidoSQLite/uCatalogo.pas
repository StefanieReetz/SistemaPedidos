unit uCatalogo;

{ TCatalogo: lê e grava produtos e serviços no banco.
  Herda de TRepositorio (ganha o NovaQuery pronto).

  Os itens também ficam numa lista em memória (Itens), que a tela usa
  para mostrar. A lista é do tipo TItem, mas guarda TProduto e TServico,
  porque um produto "é um" item e um serviço "é um" item (herança). }

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  uBancoDados, uItem;

type
  TCatalogo = class(TRepositorio)
  private
    FItens: TObjectList<TItem>;
    procedure PreencherParametros(AQuery: TFDQuery; AItem: TItem);
  public
    constructor Create(ABanco: TBancoDados);
    destructor Destroy; override;

    /// Lê todos os itens do banco para a lista Itens
    procedure Carregar;
    /// Inclui (Codigo = 0) ou altera (Codigo > 0). Quem chamou continua dono do objeto.
    procedure Gravar(AItem: TItem);
    procedure Excluir(ACodigo: Integer);
    function BuscarPorCodigo(ACodigo: Integer): TItem;

    property Itens: TObjectList<TItem> read FItens;
  end;

implementation

constructor TCatalogo.Create(ABanco: TBancoDados);
begin
  inherited Create(ABanco);
  FItens := TObjectList<TItem>.Create(True);   // True = a lista libera os objetos
end;

destructor TCatalogo.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TCatalogo.Carregar;
var
  Qry: TFDQuery;
  Item: TItem;
  Produto: TProduto;
  Servico: TServico;
begin
  FItens.Clear;
  Qry := NovaQuery('SELECT * FROM item ORDER BY tipo, descricao');
  try
    Qry.Open;
    while not Qry.Eof do
    begin
      // Conforme a coluna "tipo", cria um TProduto ou um TServico
      if Qry.FieldByName('tipo').AsString = 'P' then
      begin
        Produto := TProduto.Create;
        Produto.Unidade := Qry.FieldByName('unidade').AsString;
        Item := Produto;
      end
      else
      begin
        Servico := TServico.Create;
        Servico.DuracaoMinutos := Qry.FieldByName('duracao_minutos').AsInteger;
        Item := Servico;
      end;

      // Campos comuns (que existem no pai TItem)
      Item.Codigo := Qry.FieldByName('codigo').AsInteger;
      Item.Descricao := Qry.FieldByName('descricao').AsString;
      Item.Preco := Qry.FieldByName('preco').AsCurrency;
      FItens.Add(Item);

      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TCatalogo.PreencherParametros(AQuery: TFDQuery; AItem: TItem);
begin
  AQuery.ParamByName('descricao').AsString := AItem.Descricao;
  AQuery.ParamByName('preco').AsCurrency := AItem.Preco;

  // "is" pergunta qual é a classe real do objeto
  // TProduto(AItem) é um "typecast": trata o item como produto para ler a Unidade
  if AItem is TProduto then
  begin
    AQuery.ParamByName('tipo').AsString := 'P';
    AQuery.ParamByName('unidade').AsString := TProduto(AItem).Unidade;
    AQuery.ParamByName('duracao').AsInteger := 0;
  end
  else if AItem is TServico then
  begin
    AQuery.ParamByName('tipo').AsString := 'S';
    AQuery.ParamByName('unidade').AsString := '';
    AQuery.ParamByName('duracao').AsInteger := TServico(AItem).DuracaoMinutos;
  end;
end;

procedure TCatalogo.Gravar(AItem: TItem);
var
  Qry: TFDQuery;
begin
  AItem.Validar;   // chama o Validar do produto OU do serviço (polimorfismo)

  // Sempre use parâmetros (:nome). Nunca junte texto digitado direto no SQL!
  if AItem.Codigo = 0 then
    Qry := NovaQuery(
      'INSERT INTO item (tipo, descricao, preco, unidade, duracao_minutos) ' +
      'VALUES (:tipo, :descricao, :preco, :unidade, :duracao)')
  else
  begin
    Qry := NovaQuery(
      'UPDATE item SET tipo = :tipo, descricao = :descricao, preco = :preco, ' +
      '  unidade = :unidade, duracao_minutos = :duracao ' +
      'WHERE codigo = :codigo');
    Qry.ParamByName('codigo').AsInteger := AItem.Codigo;
  end;

  try
    PreencherParametros(Qry, AItem);
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;

  Carregar;   // relê a lista para a tela mostrar os dados atualizados
end;

procedure TCatalogo.Excluir(ACodigo: Integer);
begin
  Banco.Conexao.ExecSQL('DELETE FROM item WHERE codigo = :codigo', [ACodigo]);
  Carregar;
end;

function TCatalogo.BuscarPorCodigo(ACodigo: Integer): TItem;
var
  Item: TItem;
begin
  Result := nil;
  for Item in FItens do
    if Item.Codigo = ACodigo then
      Exit(Item);
end;

end.
