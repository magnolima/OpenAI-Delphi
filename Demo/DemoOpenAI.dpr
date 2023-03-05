program DemoOpenAI;

uses
	System.StartUpCopy,
	FMX.Forms,
	//Skia.FMX,
	uDemoOpenAI in 'uDemoOpenAI.pas' {frmDemoOpenAI} ,
	MLOpenAI.Completions in '..\Lib\MLOpenAI.Completions.pas',
	MLOpenAI.Core in '..\Lib\MLOpenAI.Core.pas',
	MLOpenAI.Types in '..\Lib\MLOpenAI.Types.pas',
	MLOpenAI.Files in '..\Lib\MLOpenAI.Files.pas',
	MLOpenAI.Finetunes in '..\Lib\MLOpenAI.Finetunes.pas',
	MLOpenAI.Images in '..\Lib\MLOpenAI.Images.pas';

{$R *.res}

begin
	//GlobalUseSkia := True;
	Application.Initialize;
	Application.CreateForm(TfrmDemoOpenAI, frmDemoOpenAI);
	Application.Run;

end.
