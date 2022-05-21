program DemoOpenAI;

uses
  System.StartUpCopy,
  FMX.Forms,
  uDemoOpenAI in 'uDemoOpenAI.pas' {frmDemoOpenAI},
  MLOpenAI.Completions in '..\Lib\MLOpenAI.Completions.pas',
  MLOpenAI.Core in '..\Lib\MLOpenAI.Core.pas',
  MLOpenAI.Types in '..\Lib\MLOpenAI.Types.pas',
  MLOpenAI.Files in '..\Lib\MLOpenAI.Files.pas',
  MLOpenAI.Finetunes in '..\Lib\MLOpenAI.Finetunes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDemoOpenAI, frmDemoOpenAI);
  Application.Run;
end.
