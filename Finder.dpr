program Finder;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

{$R manifest.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
