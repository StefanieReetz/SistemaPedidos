program CursoDelphi;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {Form1},
  Somas in 'Somas.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
