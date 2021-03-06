(*
  (C)2021-2022 Magno Lima - www.MagnumLabs.com.br

  THIS IS A TEST FILE TO USE WITH OPENAI GPT-3 API
  ** YOU WILL NEED YOUR OWN KEY TO BE ABLE TO USE THIS SOFTWARE **

  Delphi libraries for using OpenAI's GPT-3 api

  This library is licensed under Creative Commons CC-0 (aka CC Zero),
  which means that this a public dedication tool, which allows creators to
  give up their copyright and put their works into the worldwide public domain.
  You're allowed to distribute, remix, adapt, and build upon the material
  in any medium or format, with no conditions.

  Feel free to open a push request if there's anything you want
  to contribute.

  https://beta.openai.com/docs/api-reference/engines/retrieve
*)
unit uDemoOpenAI;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes,
	System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.IOUtils,
	FMX.StdCtrls, FMX.Controls.Presentation, FireDAC.Stan.Intf,
	FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
	FireDAC.Phys.Intf, FireDAC.DApt.Intf, System.Rtti, FMX.Grid.Style,
	Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs,
	FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
	Data.DB, FMX.Grid, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ScrollBox,
	FMX.Memo, FMX.Edit, Data.Bind.ObjectScope, REST.Client, REST.Response.Adapter,
	FMX.Objects, FMX.TabControl, FMX.EditBox, FMX.NumberBox, FMX.Memo.Types,
	REST.Types, System.Generics.Collections, MLOpenAI.Core,
	MLOpenAI.Types, MLOpenAI.Completions;

const
	APIKey_Filename = '.\openai.key';
	OpenAI_PATH = 'https://api.openai.com/v1';

type
	TfrmDemoOpenAI = class(TForm)
		ToolBar1: TToolBar;
		SpeedButton1: TSpeedButton;
		FDMemTable1: TFDMemTable;
		DataSource1: TDataSource;
		BindingsList1: TBindingsList;
		Image1: TImage;
		SpeedButton2: TSpeedButton;
		Label1: TLabel;
		SpeedButton3: TSpeedButton;
		Button1: TButton;
		Label2: TLabel;
		Panel1: TPanel;
		AniIndicator1: TAniIndicator;
		TabControl1: TTabControl;
		TabItem1: TTabItem;
		TabItem2: TTabItem;
		TabItem3: TTabItem;
		Label3: TLabel;
		TabItem4: TTabItem;
		Label7: TLabel;
		rbTextAda001: TRadioButton;
		Edit1: TEdit;
		Label8: TLabel;
		Memo2: TMemo;
		rbTextDavinci001: TRadioButton;
		rbTextCurie001: TRadioButton;
		rbTextBabbage001: TRadioButton;
		RESTClient1: TRESTClient;
		RESTRequest1: TRESTRequest;
		RESTResponse1: TRESTResponse;
		Button2: TButton;
		SpeedButton4: TSpeedButton;
		Label9: TLabel;
		Button3: TButton;
		OpenDialog1: TOpenDialog;
		RadioButton1: TRadioButton;
		RadioButton2: TRadioButton;
		RadioButton3: TRadioButton;
		Label10: TLabel;
		Label11: TLabel;
		RadioButton4: TRadioButton;
		ToolBar2: TToolBar;
		lbEngine: TLabel;
		rbTextDavinci002: TRadioButton;
		nbMaxTokens: TTrackBar;
		Label12: TLabel;
		nbTemperature: TTrackBar;
		Label13: TLabel;
		nbTopP: TTrackBar;
		Label14: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		nbLogProb: TTrackBar;
		Label15: TLabel;
		Memo1: TMemo;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure SpeedButton1Click(Sender: TObject);
		procedure SpeedButton2Click(Sender: TObject);
		procedure Button1Click(Sender: TObject);
		procedure SpeedButton3Click(Sender: TObject);
		procedure rbEngineSelect(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure Button2Click(Sender: TObject);
		procedure SpeedButton4Click(Sender: TObject);
		procedure RadioButton1Click(Sender: TObject);
		procedure RadioButton2Change(Sender: TObject);
		procedure RadioButton3Change(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure RadioButton4Change(Sender: TObject);
		procedure nbMaxTokensChange(Sender: TObject);
		procedure nbTemperatureChange(Sender: TObject);
		procedure nbTopPChange(Sender: TObject);
		procedure nbLogProbChange(Sender: TObject);
	private
		FEngine: TOAIEngine;
		FOpenAI: TOpenAI;
		procedure InitCompletions;
		procedure InitFile;
		procedure OnOpenAIError(Sender: TObject);
		procedure Submit;
		{ Private declarations }
	public
		{ Public declarations }
		procedure OnOpenAIResponse(Sender: TObject);
	end;

var
	frmDemoOpenAI: TfrmDemoOpenAI;
	OpenAIKey: String;
	EngineIndex: Integer;
	NameOfEngines: TArray<String>;
	FilePurpose: TFilePurpose;

implementation

uses
	System.JSON;

{$R *.fmx}

function SliceString(const AString: string; const ADelimiter: string): TArray<String>;
var
	I: Integer;
	PLine, PStart: PChar;
	s: String;
begin

	I := 1;
	PLine := PChar(AString);

	PStart := PLine;
	inc(PLine);

	while (I < length(AString)) do
	begin
		while (PLine^ <> #0) and (PLine^ <> ADelimiter) do
		begin
			inc(PLine);
			inc(I);
		end;

		SetString(s, PStart, PLine - PStart);
		SetLength(Result, length(Result) + 1);
		Result[length(Result) - 1] := s;
		inc(PLine);
		inc(I);
		PStart := PLine;
	end;

end;

function GetStops(Text: String): TArray<String>;
begin
	Result := SliceString(Text, ';');
end;

procedure TfrmDemoOpenAI.OnOpenAIError(Sender: TObject);
begin
	Memo2.Lines.Add('Error ' + FOpenAI.StatusCode.ToString + ' - ' + FOpenAI.ErrorMessage);
end;

procedure TfrmDemoOpenAI.FormCreate(Sender: TObject);
begin
	ReportMemoryLeaksOnShutdown := true;
	TabControl1.ActiveTab := TabItem1;
	NameOfEngines := TOAIEngineName;

	// Store your key safely. Never share or expose it!
	FOpenAI := TOpenAI.Create(FDMemTable1, APIKey_Filename);

	FOpenAI.Endpoint := OpenAI_PATH;
	FOpenAI.Engine := TOAIEngine.egTextCurie001;
	FOpenAI.OnResponse := OnOpenAIResponse;
	FOpenAI.OnError := OnOpenAIError;
	EngineIndex := Ord(FOpenAI.Engine);
	FEngine := FOpenAI.Engine;
	// ACompletions := TCompletions.Create(EngineIndex);
end;

procedure TfrmDemoOpenAI.FormDestroy(Sender: TObject);
begin
	// ACompletions.Free;
	FOpenAI.Free;
end;

procedure TfrmDemoOpenAI.Button2Click(Sender: TObject);
begin
	Memo2.Lines.Clear;
end;

procedure TfrmDemoOpenAI.Button3Click(Sender: TObject);
var
	AFileDescription: TFileDescription;
begin
	if OpenDialog1.Execute then
	begin
		Label9.Text := OpenDialog1.FileName;
		AFileDescription.FileName := OpenDialog1.FileName;
		AFileDescription.Purpose := FilePurpose;
		FOpenAI.FileDescription := AFileDescription;
		FOpenAI.Upload;
	end;
end;

procedure TfrmDemoOpenAI.FormShow(Sender: TObject);
begin
	FOpenAI.RequestType := orEngines;
	lbEngine.Text := 'Engine: ' + NameOfEngines[Ord(EngineIndex)];
end;

function IfThen(const Test: Boolean; IsTrue, IsFalse: String): String;
begin
	if Test then
		Result := IsTrue
	else
		Result := IsFalse;
end;

procedure TfrmDemoOpenAI.OnOpenAIResponse(Sender: TObject);
var
	field: TField;
	Engine: TPair<string, string>;
	SanitizedResponse: String;
begin
	Button1.Enabled := true;
	AniIndicator1.Enabled := False;

	// We can get the response directly using GetChoicesResult property as text
	// or, we can read from the memtable
	//
	if FOpenAI.RequestType = TOAIRequests.orCompletions then
	begin
		Memo2.Lines.Add(Trim(FOpenAI.GetChoicesResult));
		Memo2.Lines.Add(StringOfChar('-', 40));

		// Let's sanitize this result for better readability
		SanitizedResponse := TOpenAI.Sanitize(GetStops(Edit1.Text), FOpenAI.GetChoicesResult);
		FOpenAI.SaveToFile('c:\temp\resposta.txt');
		Memo2.Lines.Add(SanitizedResponse);
		Memo2.Lines.Add(StringOfChar('-', 40));
	end;

	if FOpenAI.RequestType = TOAIRequests.orEngines then
	begin
		for Engine in FOpenAI.AvailableEngines do
			Memo2.Lines.Add(Engine.Key + ' = ' + Trim(Engine.Value))
	end
	else
	begin
		Memo2.Lines.Add('Record count = ' + FDMemTable1.RecordCount.ToString);
		while not FDMemTable1.Eof do
		begin
			Memo2.Lines.Add('{');
			for field in FDMemTable1.Fields do
				Memo2.Lines.Add(field.FieldName + ': "' + Trim(field.AsString) + '"' + IfThen(field.Index = FDMemTable1.Fields.Count - 1,
				  '', ','));
			Memo2.Lines.Add('}');
			FDMemTable1.Next;
		end;
	end;

end;

procedure TfrmDemoOpenAI.RadioButton1Click(Sender: TObject);
begin
	FilePurpose := TFilePurpose.fpAnswer;
end;

procedure TfrmDemoOpenAI.RadioButton2Change(Sender: TObject);
begin
	FilePurpose := TFilePurpose.fpSearch;
end;

procedure TfrmDemoOpenAI.RadioButton3Change(Sender: TObject);
begin
	FilePurpose := TFilePurpose.fpClassification;
end;

procedure TfrmDemoOpenAI.RadioButton4Change(Sender: TObject);
begin
	FilePurpose := TFilePurpose.fpFineTune;
end;

procedure TfrmDemoOpenAI.rbEngineSelect(Sender: TObject);
begin
	EngineIndex := (Sender as TRadioButton).Tag;
	lbEngine.Text := 'Engine: ' + NameOfEngines[Ord(EngineIndex)];
end;

procedure TfrmDemoOpenAI.SpeedButton1Click(Sender: TObject);
begin
	Label2.Text := 'Engines';
	FOpenAI.RequestType := orEngines;
	TabControl1.TabIndex := 0;
end;

// Ref: https://beta.openai.com/docs/api-reference/completions/create
procedure TfrmDemoOpenAI.SpeedButton2Click(Sender: TObject);
begin
	Label2.Text := 'Completions';
	FOpenAI.RequestType := orCompletions;
	TabControl1.TabIndex := 1;
end;

procedure TfrmDemoOpenAI.SpeedButton3Click(Sender: TObject);
begin
	Label2.Text := 'Searches';
	TabControl1.TabIndex := 2;
	FOpenAI.RequestType := orSearch;
end;

procedure TfrmDemoOpenAI.SpeedButton4Click(Sender: TObject);
begin
	Label2.Text := 'Files';
	TabControl1.TabIndex := 3;
	FOpenAI.RequestType := orFiles;
end;

procedure TfrmDemoOpenAI.InitCompletions;
var
	sPrompt: String;
begin

	sPrompt := Memo1.Text.Trim;

	if sPrompt.IsEmpty then
	begin
		ShowMessage('A prompt text must be supplied');
		Exit;
	end;
	FOpenAI.Engine := FEngine;
	FOpenAI.RequestType := orCompletions;
	FOpenAI.Endpoint := OpenAI_PATH + '/engines/' + FEngine.ToString;
	FOpenAI.Completions.MaxTokens := Round(nbMaxTokens.Value);
	FOpenAI.Completions.SamplingTemperature := nbTemperature.Value;
	FOpenAI.Completions.TopP := nbTopP.Value;
	FOpenAI.Completions.Stop := GetStops(Edit1.Text);
	FOpenAI.Completions.Prompt := sPrompt;
	FOpenAI.Completions.LogProbabilities := -1; // -1 will set as null default
	FOpenAI.Completions.User := 'Delphi-OpenAIDemo';
end;

procedure TfrmDemoOpenAI.InitFile;
begin
	// WIP
end;

procedure TfrmDemoOpenAI.nbLogProbChange(Sender: TObject);
begin
	Label15.Text := Round(nbLogProb.Value).ToString;
end;

procedure TfrmDemoOpenAI.nbMaxTokensChange(Sender: TObject);
begin
	Label12.Text := Round(nbMaxTokens.Value).ToString;
end;

procedure TfrmDemoOpenAI.nbTemperatureChange(Sender: TObject);
begin
	Label13.Text := Format('%0.2f', [nbTemperature.Value]);
end;

procedure TfrmDemoOpenAI.nbTopPChange(Sender: TObject);
begin
	Label14.Text := Format('%0.2f', [nbTopP.Value]);
end;

procedure TfrmDemoOpenAI.Button1Click(Sender: TObject);
begin
	Submit;
end;

procedure TfrmDemoOpenAI.Submit;
begin
	if FOpenAI.APIKey.IsEmpty then
	begin
		Memo2.Lines.Add('API key is missing');
		Exit;
	end;

	if (FOpenAI.RequestType = orFiles) and (OpenDialog1.FileName = '') then
	begin
		Memo2.Lines.Add('Choose a file to upload');
		Exit;
	end;

	if (FOpenAI.RequestType = orCompletions) and (Memo1.Text.IsEmpty) then
	begin
		Memo2.Lines.Add('Nothing to do here...');
		Exit;
	end;

	if FOpenAI.RequestType = orNone then
	begin
		Memo2.Lines.Add('Choose a request type.');
		Exit;
	end;

	Button1.Enabled := False;
	AniIndicator1.Enabled := true;
	AniIndicator1.Visible := true;

	TThread.CreateAnonymousThread(
		procedure
		begin

			try
				case FOpenAI.RequestType of
					orEngines:
						begin
							FOpenAI.Endpoint := OpenAI_PATH;
							FOpenAI.GetEngines();
							Exit;
						end;
					orCompletions:
						InitCompletions();
					orFiles:
						InitFile();
				end;

				try
					Memo2.Lines.Add(FOpenAI.Endpoint);
					FOpenAI.Execute;
				except
					on E: Exception do
						Memo2.Lines.Add(E.Message)
				end;

			finally
				Button1.Enabled := true;
				AniIndicator1.Enabled := False;
				AniIndicator1.Visible := False;
			end;

		end).Start;
end;

end.
