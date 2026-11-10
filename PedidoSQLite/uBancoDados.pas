unit uBancoDados;

{ Acesso ao banco SQLite usando FireDAC (já vem no Delphi, inclusive no Community).

  - TBancoDados: abre o arquivo do banco e cria as tabelas na primeira vez.
  - TRepositorio: classe BASE para quem lê/grava no banco.
    TCatalogo e TListaPedidos HERDAM dela e ganham o acesso ao banco pronto.

  O banco é um arquivo só (pedidos.db), criado ao lado do .exe.
  Para "olhar" as tabelas, use o programa gratuito "DB Browser for SQLite". }

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TBancoDados = class
  private
    FConexao: TFDConnection;
    procedure CriarTabelas;
    procedure InserirDadosExemplo;
  public
    constructor Create(const AArquivo: string);
    destructor Destroy; override;
    property Conexao: TFDConnection read FConexao;
  end;

  TRepositorio = class
  private
    FBanco: TBancoDados;
  protected
    /// Cria uma query já ligada ao banco e com o SQL. Quem chama dá o Free.
    function NovaQuery(const ASQL: string): TFDQuery;
    property Banco: TBancoDados read FBanco;
  public
    constructor Create(ABanco: TBancoDados);
  end;

implementation

{ TBancoDados }

constructor TBancoDados.Create(const AArquivo: string);
begin
  inherited Create;
  FConexao := TFDConnection.Create(nil);
  FConexao.DriverName := 'SQLite';
  FConexao.Params.Database := AArquivo;   // se o arquivo não existir, o SQLite cria
  FConexao.LoginPrompt := False;
  FConexao.Connected := True;

  CriarTabelas;
  InserirDadosExemplo;
end;

destructor TBancoDados.Destroy;
begin
  FConexao.Free;
  inherited;
end;

procedure TBancoDados.CriarTabelas;
begin
  // Produtos e serviços ficam na MESMA tabela; a coluna "tipo" diz quem é quem
  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS item (' +
    '  codigo          INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  tipo            CHAR(1)       NOT NULL,' +    // P = produto, S = serviço
    '  descricao       VARCHAR(100)  NOT NULL,' +
    '  preco           NUMERIC(15,2) NOT NULL,' +
    '  unidade         VARCHAR(5),' +                // só produto usa
    '  duracao_minutos INTEGER)');                   // só serviço usa

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS pedido (' +
    '  numero  INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  data    DATETIME      NOT NULL,' +
    '  cliente VARCHAR(100)  NOT NULL)');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS pedido_item (' +
    '  id             INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  numero_pedido  INTEGER       NOT NULL,' +
    '  codigo_item    INTEGER       NOT NULL,' +
    '  tipo           VARCHAR(10)   NOT NULL,' +
    '  descricao      VARCHAR(100)  NOT NULL,' +
    '  quantidade     NUMERIC(15,3) NOT NULL,' +
    '  preco_unitario NUMERIC(15,2) NOT NULL)');
end;

procedure TBancoDados.InserirDadosExemplo;
begin
  if FConexao.ExecSQLScalar('SELECT COUNT(*) FROM item') > 0 then
    Exit;

  FConexao.ExecSQL('INSERT INTO item (tipo, descricao, preco, unidade) ' +
    'VALUES (''P'', ''Teclado USB'', 89.90, ''UN'')');
  FConexao.ExecSQL('INSERT INTO item (tipo, descricao, preco, unidade) ' +
    'VALUES (''P'', ''Mouse sem fio'', 59.90, ''UN'')');
  FConexao.ExecSQL('INSERT INTO item (tipo, descricao, preco, duracao_minutos) ' +
    'VALUES (''S'', ''Formatação de computador'', 150.00, 120)');
  FConexao.ExecSQL('INSERT INTO item (tipo, descricao, preco, duracao_minutos) ' +
    'VALUES (''S'', ''Instalação de programas'', 50.00, 30)');
end;

{ TRepositorio }

constructor TRepositorio.Create(ABanco: TBancoDados);
begin
  inherited Create;
  FBanco := ABanco;
end;

function TRepositorio.NovaQuery(const ASQL: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FBanco.Conexao;
  Result.SQL.Text := ASQL;
end;

end.
