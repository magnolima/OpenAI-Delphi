program DemoOpenAI;

uses
  System.StartUpCopy,
  FMX.Forms,
  uDemoOpenAI in 'uDemoOpenAI.pas' {Form1},
  MLOpenAI.Completions in '..\Lib\MLOpenAI.Completions.pas',
  MLOpenAI.Core in '..\Lib\MLOpenAI.Core.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
