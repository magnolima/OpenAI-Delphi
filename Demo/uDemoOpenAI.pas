(*
  (C)2021 Magno Lima - www.MagnumLabs.com.br

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
  FMX.Objects, FMX.TabControl, FMX.EditBox, FMX.NumberBox, FMX.Memo.Types;

const
  API_KEY = '.\openai.key';
  OpenAI_PATH = 'https://api.openai.com/v1';

type
  TfrmDemoOpenAI = class(TForm)
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
    Memo1: TMemo;
    FDMemTable1: TFDMemTable;
    Grid1: TGrid;
    DataSource1: TDataSource;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure rbDavinciClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure InitCompletions;
    procedure DetailEngine;
    { Private declarations }
  public
    { Public declarations }
    procedure OnOpenAIResponse(Sender: TObject);
  end;

var
  frmDemoOpenAI: TfrmDemoOpenAI;
  OpenAIKey: String;
  EngineIndex: Integer;
  NameOfEngines: Array of String = ['text-davinci-001', 'text-curie-001',
    'text-babbage-001', 'text-ada-001', 'davinci', 'curie', 'babbage', 'ada'];

implementation

uses
  MLOpenAI.Core, MLOpenAI.Completions;

var
  OpenAI: TOpenAI;

{$R *.fmx}

function SliceString(const AString: string; const ADelimiter: string)
  : TArray<String>;
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
  if FileExists(API_KEY) then
  begin
    // Store your key safely. Never share or expose it!
    OpenAIKey := TFile.ReadAllText(API_KEY);

    OpenAI := TOpenAI.Create(FDMemTable1);
    OpenAI.Endpoint := OpenAI_PATH;
    OpenAI.Engine := TOAIEngine.egTextDavinci001;
    OpenAI.OnResponse := OnOpenAIResponse;

  end
  else
    ShowMessage('Api key file not found');
end;

procedure TfrmDemoOpenAI.FormDestroy(Sender: TObject);
begin
  OpenAI.DisposeOf;
end;

procedure TfrmDemoOpenAI.DetailEngine();
begin
  Memo2.Lines.Add('We are using the "' + OpenAI_PATH + '/engines/' +
    NameOfEngines[EngineIndex] + OAI_GET_COMPLETION + '" engine. Requests are: '
    + OpenAI.Endpoint)
end;

procedure TfrmDemoOpenAI.FormShow(Sender: TObject);
begin
  DetailEngine();
end;

procedure TfrmDemoOpenAI.OnOpenAIResponse(Sender: TObject);
begin
  Button1.Enabled := True;
  AniIndicator1.Enabled := False;

  // Debug
  Memo2.Lines.Text := OpenAI.BodyContent;

  TThread.Queue(nil,
    procedure
    var
      Engine: String;
    begin
      case OpenAI.RequestType of
        orEngines:
          begin
            for Engine in OpenAI.AvailableEngines.Keys do
            begin
              if Engine = NameOfEngines[EngineIndex] then
                Memo2.Lines.Add(Engine + ' is ready = ' +
                  OpenAI.AvailableEngines[Engine]);
            end;
          end;
      end;
    end);

end;

procedure TfrmDemoOpenAI.rbDavinciClick(Sender: TObject);
begin
  EngineIndex := (Sender as TRadioButton).Tag;
  DetailEngine();
end;

procedure TfrmDemoOpenAI.SpeedButton1Click(Sender: TObject);
begin
  OpenAI.RequestType := orEngines;
  TabControl1.TabIndex := 0;
  Label2.Text := 'Engines';
end;

// Ref: https://beta.openai.com/docs/api-reference/completions/create
procedure TfrmDemoOpenAI.SpeedButton2Click(Sender: TObject);
begin
  OpenAI.RequestType := orCompletions;
  TabControl1.TabIndex := 1;
  Label2.Text := 'Completions';
end;

procedure TfrmDemoOpenAI.SpeedButton3Click(Sender: TObject);
begin
  Label2.Text := 'Searches';
  TabControl1.TabIndex := 2;
  OpenAI.RequestType := orSearch;
end;

procedure TfrmDemoOpenAI.InitCompletions;
var
  ACompletions: TCompletions;
  I: Integer;
  sPrompt: String;

  function getStops(Text: String): TArray<String>;
  begin
    Result := SliceString(Text, ';');
  end;

begin

  sPrompt := Memo1.Text.Trim;

  if sPrompt.IsEmpty then
  begin
    ShowMessage('A prompt text must be supplied');
    Exit;
  end;

  ACompletions := TCompletions.Create(EngineIndex);
  ACompletions.MaxTokens := Round(nbMaxTokens.Value);
  ACompletions.SamplingTemperature := 1;
  ACompletions.TopP := 1;
  ACompletions.Stop := getStops(Edit1.Text);
  ACompletions.Prompt := sPrompt;
  ACompletions.LogProbabilities := -1; // -1 will set as null default
  //
  // post https://api.openai.com/v1/engines/{engine_id}/completions
  // https://api.openai.com/v1/engines/davinci/completions
  OpenAI.RequestType := orCompletions;
  OpenAI.Completions := ACompletions;
  OpenAI.Endpoint := OpenAI_PATH + '/engines/' + NameOfEngines[EngineIndex] +
    OAI_GET_COMPLETION;

  //DetailEngine();
end;

procedure TfrmDemoOpenAI.Button1Click(Sender: TObject);
begin

  if OpenAI.RequestType = orNone then
  begin
    ShowMessage('Chose a request type.');
    Exit;
  end;

  Button1.Enabled := False;
  AniIndicator1.Enabled := True;

  TThread.CreateAnonymousThread(
    procedure
    begin

      OpenAI.APIKey := OpenAIKey;

      try
        case OpenAI.RequestType of
          orEngines:
          begin
            OpenAI.GetEngines();
            Exit;
          end;
          orCompletions:
            InitCompletions();
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
          Memo2.Lines.Add(OpenAI.Endpoint);
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

// '{'#$A'  "error": {'#$A'    "code": null, '#$A' " message ": " '' null '' is not of
//
// type
// '' Integer '' - '' logprobs '' ", '#$A' " Param ": null, '#$A' " type ": " invalid_request_error " '#$A' } '#$A' } '#$A
