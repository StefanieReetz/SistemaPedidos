unit uItem;

{ CLASSES DO CATÁLOGO - aqui está a HERANÇA:

        TItem            (classe "pai": Codigo, Descricao, Preco)
       /     \
  TProduto  TServico     (classes "filhas": herdam tudo do pai e acrescentam o seu)

  - TProduto acrescenta Unidade (UN, KG, CX...)
  - TServico acrescenta DuracaoMinutos

  Os métodos "virtual" do pai podem ser substituídos ("override") pelos filhos.
  Isso se chama POLIMORFISMO: o mesmo método (Tipo, Detalhe, Validar) faz
  coisas diferentes dependendo se o objeto é um produto ou um serviço. }

interface

uses
  System.SysUtils;

type
  TItem = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FPreco: Currency;
  public
    function Tipo: string; virtual;
    function Detalhe: string; virtual;
    procedure Validar; virtual;

    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property Preco: Currency read FPreco write FPreco;
  end;

  TProduto = class(TItem)
  private
    FUnidade: string;
  public
    constructor Create;
    function Tipo: string; override;
    function Detalhe: string; override;
    procedure Validar; override;

    property Unidade: string read FUnidade write FUnidade;
  end;

  TServico = class(TItem)
  private
    FDuracaoMinutos: Integer;
  public
    function Tipo: string; override;
    function Detalhe: string; override;
    procedure Validar; override;

    property DuracaoMinutos: Integer read FDuracaoMinutos write FDuracaoMinutos;
  end;

implementation

{ TItem }

function TItem.Tipo: string;
begin
  Result := 'Item';
end;

function TItem.Detalhe: string;
begin
  Result := '';
end;

procedure TItem.Validar;
begin
  if Trim(FDescricao) = '' then
    raise Exception.Create('Informe a descrição.');
  if FPreco <= 0 then
    raise Exception.Create('O preço deve ser maior que zero.');
end;

{ TProduto }

constructor TProduto.Create;
begin
  inherited Create;
  FUnidade := 'UN';
end;

function TProduto.Tipo: string;
begin
  Result := 'Produto';
end;

function TProduto.Detalhe: string;
begin
  Result := 'Unidade: ' + FUnidade;
end;

procedure TProduto.Validar;
begin
  inherited Validar;   // primeiro faz as validações do pai (descrição e preço)
  if Trim(FUnidade) = '' then
    raise Exception.Create('Informe a unidade do produto (UN, KG, CX...).');
end;

{ TServico }

function TServico.Tipo: string;
begin
  Result := 'Serviço';
end;

function TServico.Detalhe: string;
begin
  Result := IntToStr(FDuracaoMinutos) + ' minutos';
end;

procedure TServico.Validar;
begin
  inherited Validar;
  if FDuracaoMinutos <= 0 then
    raise Exception.Create('Informe a duração do serviço em minutos.');
end;

end.
