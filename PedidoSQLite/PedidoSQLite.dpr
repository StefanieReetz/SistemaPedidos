program PedidoSQLite;

uses
  Vcl.Forms,
  uBancoDados in 'uBancoDados.pas',
  uItem in 'uItem.pas',
  uCatalogo in 'uCatalogo.pas',
  uPedido in 'uPedido.pas',
  uPrincipal in 'uPrincipal.pas' {frmPrincipal};

begin
  // Ao fechar o programa, avisa se algum objeto ficou sem Free (ótimo para aprender)
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Sistema de Pedidos';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
