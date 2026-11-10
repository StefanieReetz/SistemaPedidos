unit uPrincipal;

{ Tela única do sistema, com 3 abas:
  1) Produtos e Serviços  2) Novo Pedido  3) Pedidos Realizados

  A tela NÃO guarda regras: quem valida é o objeto (TProduto.Validar,
  TPedido.Validar...). A tela só lê os campos, chama os objetos e mostra. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  uBancoDados, uItem, uCatalogo, uPedido;

type
  TfrmPrincipal = class(TForm)
    PageControl1: TPageControl;
    tsCatalogo: TTabSheet;
    tsPedido: TTabSheet;
    tsPedidos: TTabSheet;
    // aba 1 - catálogo
    lvCatalogo: TListView;
    pnlCadastro: TPanel;
    rgTipo: TRadioGroup;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lblPreco: TLabel;
    edtPreco: TEdit;
    lblUnidade: TLabel;
    edtUnidade: TEdit;
    lblDuracao: TLabel;
    edtDuracao: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    // aba 2 - novo pedido
    pnlTopoPedido: TPanel;
    lblCliente: TLabel;
    edtCliente: TEdit;
    lblItem: TLabel;
    cbItem: TComboBox;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    btnAdicionar: TButton;
    lvItensPedido: TListView;
    pnlRodapePedido: TPanel;
    lblTotal: TLabel;
    btnRemover: TButton;
    btnFinalizar: TButton;
    // aba 3 - pedidos realizados
    lvPedidos: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rgTipoClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure lvCatalogoSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverClick(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
    procedure lvPedidosDblClick(Sender: TObject);
  private
    FBanco: TBancoDados;
    FCatalogo: TCatalogo;
    FListaPedidos: TListaPedidos;
    FPedidoAtual: TPedido;
    FCodigoEditando: Integer;   // 0 = item novo
    procedure LimparCadastro;
    procedure AjustarCamposPorTipo;
    function CriarItemDaTela: TItem;
    procedure AtualizarListaCatalogo;
    procedure AtualizarComboItens;
    procedure AtualizarItensPedido;
    procedure AtualizarListaPedidos;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

{ ===================== Início e fim ===================== }

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  Pasta: string;
begin
  Pasta := ExtractFilePath(ParamStr(0));   // pasta onde está o .exe

  // Abre (ou cria) o banco pedidos.db e as tabelas
  FBanco := TBancoDados.Create(Pasta + 'pedidos.db');

  // Os dois "repositórios" usam o mesmo banco
  FCatalogo := TCatalogo.Create(FBanco);
  FCatalogo.Carregar;

  FListaPedidos := TListaPedidos.Create(FBanco);
  FListaPedidos.Carregar;

  FPedidoAtual := TPedido.Create;

  PageControl1.ActivePageIndex := 0;
  LimparCadastro;
  AtualizarListaCatalogo;
  AtualizarComboItens;
  AtualizarItensPedido;
  AtualizarListaPedidos;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  // Tudo que criamos com .Create precisa de .Free
  FPedidoAtual.Free;
  FListaPedidos.Free;
  FCatalogo.Free;
  FBanco.Free;        // o banco por último, pois os outros usam ele
end;

{ ===================== Aba 1: Produtos e Serviços ===================== }

procedure TfrmPrincipal.AjustarCamposPorTipo;
var
  EhProduto: Boolean;
begin
  EhProduto := rgTipo.ItemIndex = 0;
  edtUnidade.Enabled := EhProduto;
  lblUnidade.Enabled := EhProduto;
  edtDuracao.Enabled := not EhProduto;
  lblDuracao.Enabled := not EhProduto;
end;

procedure TfrmPrincipal.LimparCadastro;
begin
  FCodigoEditando := 0;
  rgTipo.Enabled := True;
  edtDescricao.Clear;
  edtPreco.Text := '0,00';
  edtUnidade.Text := 'UN';
  edtDuracao.Text := '0';
  btnExcluir.Enabled := False;
  AjustarCamposPorTipo;
end;

procedure TfrmPrincipal.rgTipoClick(Sender: TObject);
begin
  AjustarCamposPorTipo;
end;

function TfrmPrincipal.CriarItemDaTela: TItem;
var
  Preco: Currency;
  Produto: TProduto;
  Servico: TServico;
begin
  if not TryStrToCurr(edtPreco.Text, Preco) then
    raise Exception.Create('Preço inválido. Exemplo: 10,50');

  // Cria um TProduto ou um TServico, mas devolve como TItem (o "pai")
  if rgTipo.ItemIndex = 0 then
  begin
    Produto := TProduto.Create;
    Produto.Unidade := UpperCase(Trim(edtUnidade.Text));
    Result := Produto;
  end
  else
  begin
    Servico := TServico.Create;
    Servico.DuracaoMinutos := StrToIntDef(edtDuracao.Text, 0);
    Result := Servico;
  end;

  // Propriedades que existem no pai valem para os dois
  Result.Codigo := FCodigoEditando;
  Result.Descricao := Trim(edtDescricao.Text);
  Result.Preco := Preco;
end;

procedure TfrmPrincipal.btnNovoClick(Sender: TObject);
begin
  lvCatalogo.ClearSelection;
  LimparCadastro;
  edtDescricao.SetFocus;
end;

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
var
  Item: TItem;
begin
  Item := CriarItemDaTela;   // TProduto ou TServico, conforme o tipo escolhido
  try
    FCatalogo.Gravar(Item);
  finally
    Item.Free;               // criamos, então liberamos (o catálogo já releu do banco)
  end;
  LimparCadastro;
  AtualizarListaCatalogo;
  AtualizarComboItens;
  ShowMessage('Salvo com sucesso!');
end;

procedure TfrmPrincipal.btnExcluirClick(Sender: TObject);
begin
  if FCodigoEditando = 0 then
    Exit;
  if MessageDlg('Deseja excluir este item?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FCatalogo.Excluir(FCodigoEditando);
  LimparCadastro;
  AtualizarListaCatalogo;
  AtualizarComboItens;
end;

procedure TfrmPrincipal.lvCatalogoSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  ItemCatalogo: TItem;
begin
  if not Selected then
    Exit;

  ItemCatalogo := FCatalogo.BuscarPorCodigo(StrToInt(Item.Caption));
  if ItemCatalogo = nil then
    Exit;

  FCodigoEditando := ItemCatalogo.Codigo;
  edtDescricao.Text := ItemCatalogo.Descricao;
  edtPreco.Text := FormatCurr('0.00', ItemCatalogo.Preco);

  // "is" descobre a classe real; TProduto(...) acessa o que só o produto tem
  if ItemCatalogo is TProduto then
  begin
    rgTipo.ItemIndex := 0;
    edtUnidade.Text := TProduto(ItemCatalogo).Unidade;
    edtDuracao.Text := '0';
  end
  else if ItemCatalogo is TServico then
  begin
    rgTipo.ItemIndex := 1;
    edtDuracao.Text := IntToStr(TServico(ItemCatalogo).DuracaoMinutos);
    edtUnidade.Text := 'UN';
  end;

  rgTipo.Enabled := False;   // não deixa trocar o tipo de um item já cadastrado
  btnExcluir.Enabled := True;
  AjustarCamposPorTipo;
end;

procedure TfrmPrincipal.AtualizarListaCatalogo;
var
  ItemCatalogo: TItem;
  Linha: TListItem;
begin
  lvCatalogo.Items.BeginUpdate;
  try
    lvCatalogo.Items.Clear;
    for ItemCatalogo in FCatalogo.Itens do
    begin
      Linha := lvCatalogo.Items.Add;
      Linha.Caption := IntToStr(ItemCatalogo.Codigo);
      Linha.SubItems.Add(ItemCatalogo.Tipo);       // POLIMORFISMO: 'Produto' ou 'Serviço'
      Linha.SubItems.Add(ItemCatalogo.Descricao);
      Linha.SubItems.Add(FormatCurr('#,##0.00', ItemCatalogo.Preco));
      Linha.SubItems.Add(ItemCatalogo.Detalhe);    // POLIMORFISMO: unidade ou minutos
    end;
  finally
    lvCatalogo.Items.EndUpdate;
  end;
end;

{ ===================== Aba 2: Novo Pedido ===================== }

procedure TfrmPrincipal.AtualizarComboItens;
var
  ItemCatalogo: TItem;
begin
  cbItem.Items.Clear;
  for ItemCatalogo in FCatalogo.Itens do
    // AddObject guarda o texto E o próprio objeto junto (para pegar depois)
    cbItem.Items.AddObject(Format('%s - %s (R$ %s)', [ItemCatalogo.Tipo,
      ItemCatalogo.Descricao, FormatCurr('#,##0.00', ItemCatalogo.Preco)]), ItemCatalogo);

  if cbItem.Items.Count > 0 then
    cbItem.ItemIndex := 0;
end;

procedure TfrmPrincipal.AtualizarItensPedido;
var
  ItemPedido: TItemPedido;
  Linha: TListItem;
begin
  lvItensPedido.Items.BeginUpdate;
  try
    lvItensPedido.Items.Clear;
    for ItemPedido in FPedidoAtual.Itens do
    begin
      Linha := lvItensPedido.Items.Add;
      Linha.Caption := ItemPedido.Tipo;
      Linha.SubItems.Add(ItemPedido.Descricao);
      Linha.SubItems.Add(FormatFloat('0.###', ItemPedido.Quantidade));
      Linha.SubItems.Add(FormatCurr('#,##0.00', ItemPedido.PrecoUnitario));
      Linha.SubItems.Add(FormatCurr('#,##0.00', ItemPedido.Subtotal));
    end;
  finally
    lvItensPedido.Items.EndUpdate;
  end;
  lblTotal.Caption := 'Total: R$ ' + FormatCurr('#,##0.00', FPedidoAtual.Total);
end;

procedure TfrmPrincipal.btnAdicionarClick(Sender: TObject);
var
  Quantidade: Double;
  ItemCatalogo: TItem;
begin
  if cbItem.ItemIndex < 0 then
    raise Exception.Create('Selecione um item.');
  if not TryStrToFloat(edtQuantidade.Text, Quantidade) then
    raise Exception.Create('Quantidade inválida.');

  ItemCatalogo := TItem(cbItem.Items.Objects[cbItem.ItemIndex]);
  FPedidoAtual.AdicionarItem(ItemCatalogo, Quantidade);

  edtQuantidade.Text := '1';
  AtualizarItensPedido;
end;

procedure TfrmPrincipal.btnRemoverClick(Sender: TObject);
begin
  FPedidoAtual.RemoverItem(lvItensPedido.ItemIndex);
  AtualizarItensPedido;
end;

procedure TfrmPrincipal.btnFinalizarClick(Sender: TObject);
begin
  FPedidoAtual.Cliente := Trim(edtCliente.Text);

  // Se o pedido for inválido, Adicionar gera erro e as linhas abaixo não rodam
  FListaPedidos.Adicionar(FPedidoAtual);
  ShowMessage(Format('Pedido nº %d finalizado!', [FPedidoAtual.Numero]));

  // Pedido já está no banco: liberamos e começamos um novo, vazio
  FPedidoAtual.Free;
  FPedidoAtual := TPedido.Create;
  edtCliente.Clear;
  AtualizarItensPedido;
  AtualizarListaPedidos;
  PageControl1.ActivePage := tsPedidos;
end;

{ ===================== Aba 3: Pedidos Realizados ===================== }

procedure TfrmPrincipal.AtualizarListaPedidos;
var
  Pedido: TPedido;
  Linha: TListItem;
begin
  lvPedidos.Items.BeginUpdate;
  try
    lvPedidos.Items.Clear;
    for Pedido in FListaPedidos.Pedidos do
    begin
      Linha := lvPedidos.Items.Add;
      Linha.Caption := IntToStr(Pedido.Numero);
      Linha.SubItems.Add(FormatDateTime('dd/mm/yyyy hh:nn', Pedido.Data));
      Linha.SubItems.Add(Pedido.Cliente);
      Linha.SubItems.Add(IntToStr(Pedido.Itens.Count));
      Linha.SubItems.Add(FormatCurr('#,##0.00', Pedido.Total));
    end;
  finally
    lvPedidos.Items.EndUpdate;
  end;
end;

procedure TfrmPrincipal.lvPedidosDblClick(Sender: TObject);
begin
  if lvPedidos.ItemIndex >= 0 then
    ShowMessage(FListaPedidos.Pedidos[lvPedidos.ItemIndex].Resumo);
end;

end.
