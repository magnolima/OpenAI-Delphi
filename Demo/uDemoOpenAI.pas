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
  REST.Types, System.Generics.Collections,
  MLOpenAI.Types;

const
  APIKey_Filename = '.\openai.key';
  OpenAI_PATH = 'https://api.openai.com/v1';
  
type
  TfrmDemoOpenAI = class(TForm)
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
    Memo1: TMemo;
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
    nbMaxTokens: TNumberBox;
    Label4: TLabel;
    nbTemperature: TNumberBox;
    Label5: TLabel;
    nbTopP: TNumberBox;
    Label6: TLabel;
    nbLogProb: TNumberBox;
    Label7: TLabel;
    rbDavinci: TRadioButton;
    rbCurie: TRadioButton;
    rbBabbage: TRadioButton;
    rbTextAda001: TRadioButton;
    Edit1: TEdit;
    Label8: TLabel;
    Memo2: TMemo;
    rbTextDavinci001: TRadioButton;
    rbTextCurie001: TRadioButton;
    rbTextBabbage001: TRadioButton;
    rbAda: TRadioButton;
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
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure rbDavinciClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
    procedure RadioButton3Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RadioButton4Change(Sender: TObject);
  private
    procedure InitCompletions;
    procedure InitFile;
    { Private declarations }
  public
    { Public declarations }
    procedure OnOpenAIResponse(Sender: TObject);
  end;

var
  frmDemoOpenAI: TfrmDemoOpenAI;
  OpenAIKey: String;
  EngineIndex: Integer;
  NameOfEngines: TArray<String>; // TOAIEngineName;
  //Array of String = ['text-davinci-001', 'text-curie-001', 'text-babbage-001', 'text-ada-001', 'davinci', 'curie',   'babbage', 'ada'];

implementation

uses
  System.JSON,
  MLOpenAI.Core, MLOpenAI.Completions;

var
  OpenAI: TOpenAI;

{$R *.fmx}

function SliceString(const AString: string; const ADelimiter: string): TArray<String>;
var
  I: Integer;
  p: ^Integer;
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

procedure TfrmDemoOpenAI.FormCreate(Sender: TObject);
begin
  EngineIndex := 0;
  NameOfEngines := TOAIEngineName;
  // Store your key safely. Never share or expose it!
  OpenAI := TOpenAI.Create(FDMemTable1, APIKey_Filename);
  OpenAI.Endpoint := OpenAI_PATH;
  OpenAI.Engine := TOAIEngine.egTextCurie001;
  OpenAI.OnResponse := OnOpenAIResponse;

end;

procedure TfrmDemoOpenAI.FormDestroy(Sender: TObject);
begin
  OpenAI.DisposeOf;
end;

procedure TfrmDemoOpenAI.Button2Click(Sender: TObject);
begin
  Memo2.Lines.Clear;
end;

procedure TfrmDemoOpenAI.Button3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    Label9.Text := OpenDialog1.FileName;
end;

procedure TfrmDemoOpenAI.FormShow(Sender: TObject);
begin
  OpenAI.RequestType := orEngines;
end;

procedure TfrmDemoOpenAI.OnOpenAIResponse(Sender: TObject);
var
  field: TField;
  Engine: TPair<string, string>;
begin
  Button1.Enabled := True;
  AniIndicator1.Enabled := False;

  // We can get it directly
  if OpenAI.RequestType = TOAIRequests.orCompletions then
    Memo2.Lines.Add('AI: ' + Trim(OpenAI.GetChoicesResult));

  if OpenAI.RequestType = TOAIRequests.orEngines then
  begin
    for Engine in OpenAI.AvailableEngines do
      Memo2.Lines.Add(Engine.Key + ' = ' + Engine.Value)
  end
  else
    // or, we can read from the memtable
    while not FDMemTable1.Eof do
    begin
      for field in FDMemTable1.Fields do
        Memo2.Lines.Add(field.FieldName + ' = ' + field.AsString);

      FDMemTable1.Next;
    end;

end;

procedure TfrmDemoOpenAI.RadioButton1Click(Sender: TObject);
begin
  OpenAI.FilePurpose := TFilePurpose.fpAnswer;
end;

procedure TfrmDemoOpenAI.RadioButton2Change(Sender: TObject);
begin
  OpenAI.FilePurpose := TFilePurpose.fpSearch;
end;

procedure TfrmDemoOpenAI.RadioButton3Change(Sender: TObject);
begin
  OpenAI.FilePurpose := TFilePurpose.fpClassification;
end;

procedure TfrmDemoOpenAI.RadioButton4Change(Sender: TObject);
begin
  OpenAI.FilePurpose := TFilePurpose.fpFineTune;
end;

procedure TfrmDemoOpenAI.rbDavinciClick(Sender: TObject);
begin
  EngineIndex := (Sender as TRadioButton).Tag;
end;

procedure TfrmDemoOpenAI.SpeedButton1Click(Sender: TObject);
begin
  OpenAI.RequestType := orEngines;
  TabControl1.TabIndex := 0;
  Label2.text := 'Engines';
end;

// Ref: https://beta.openai.com/docs/api-reference/completions/create
procedure TfrmDemoOpenAI.SpeedButton2Click(Sender: TObject);
begin
  OpenAI.RequestType := orCompletions;
  TabControl1.TabIndex := 1;
  Label2.text := 'Completions';
end;

procedure TfrmDemoOpenAI.SpeedButton3Click(Sender: TObject);
begin
  Label2.text := 'Searches';
  TabControl1.TabIndex := 2;
  OpenAI.RequestType := orSearch;
end;

procedure TfrmDemoOpenAI.SpeedButton4Click(Sender: TObject);
begin
  Label2.text := 'Files';
  TabControl1.TabIndex := 3;
  OpenAI.RequestType := orFiles;
end;

procedure TfrmDemoOpenAI.InitCompletions;
var
  ACompletions: TCompletions;
  I: Integer;
  sPrompt: String;

  function getStops(text: String): TArray<String>;
  begin
    Result := SliceString(text, ';');
  end;

begin

  sPrompt := Memo1.text.Trim;

  if sPrompt.IsEmpty then
  begin
    ShowMessage('A prompt text must be supplied');
    Exit;
  end;

  ACompletions := TCompletions.Create(EngineIndex);
  ACompletions.MaxTokens := Round(nbMaxTokens.Value);
  ACompletions.SamplingTemperature := 1;
  ACompletions.TopP := 1;
  ACompletions.Stop := getStops(Edit1.text);
  ACompletions.Prompt := sPrompt;
  ACompletions.LogProbabilities := -1; // -1 will set as null default
  //
  // post https://api.openai.com/v1/engines/{engine_id}/completions
  // https://api.openai.com/v1/engines/davinci/completions
  OpenAI.RequestType := orCompletions;
  OpenAI.Completions := ACompletions;
  OpenAI.Endpoint := OpenAI_PATH + '/engines/' + NameOfEngines[EngineIndex] + OAI_GET_COMPLETION;

  // DetailEngine();
end;

procedure TfrmDemoOpenAI.InitFile;
begin

end;

procedure TfrmDemoOpenAI.Button1Click(Sender: TObject);
begin
  if OpenAI.APIKey.IsEmpty then
  begin
    Memo2.Lines.Add('API key is missing');
    Exit;
  end;

  if (OpenAI.RequestType = orFiles) and (OpenDialog1.FileName = '') then
  begin
    Memo2.Lines.Add('Choose a file to upload');
    Exit;
  end;

  if (OpenAI.RequestType = orCompletions) and (Memo1.text.IsEmpty) then
  begin
    Memo2.Lines.Add('Nothing to do here...');
    Exit;
  end;

  if OpenAI.RequestType = orNone then
  begin
    Memo2.Lines.Add('Choose a request type.');
    Exit;
  end;

  Button1.Enabled := False;
  AniIndicator1.Enabled := True;
  AniIndicator1.Visible := True;

  TThread.CreateAnonymousThread(
    procedure
    begin

      try
        case OpenAI.RequestType of
          orEngines:
            begin
              OpenAI.GetEngines();
              Exit;
            end;
          orCompletions:
            InitCompletions();
          orFiles:
            InitFile();
        end;

        case EngineIndex of
          0:
            OpenAI.Engine := TOAIEngine.egTextDavinci001;
          1:
            OpenAI.Engine := TOAIEngine.egTextCurie001;
          2:
            OpenAI.Engine := TOAIEngine.egTextBabbage001;
          3:
            OpenAI.Engine := TOAIEngine.egTextAda001;
          4:
            OpenAI.Engine := TOAIEngine.egDavinci;
          5:
            OpenAI.Engine := TOAIEngine.egCurie;
          6:
            OpenAI.Engine := TOAIEngine.egBabbage;
          7:
            OpenAI.Engine := TOAIEngine.egAda;
        end;

        try
          // Memo2.Lines.Add(OpenAI.Endpoint);
          OpenAI.Execute;
        except
          on E: Exception do
            Memo2.Lines.Add(E.Message)
        end;

      finally
        Button1.Enabled := True;
        AniIndicator1.Enabled := False;
        AniIndicator1.Visible := False;
      end;

    end).Start;
end;

end.
