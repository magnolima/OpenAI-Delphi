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
   System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
   FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.IOUtils,
   FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
   FMX.TMSFNCCustomControl, FMX.TMSFNCHTMLText, FMX.TMSFNCLabelEdit,
   FMX.StdCtrls, FMX.Controls.Presentation, FireDAC.Stan.Intf,
   FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
   FireDAC.Phys.Intf, FireDAC.DApt.Intf, System.Rtti, FMX.Grid.Style,
   Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs,
   FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
   Data.DB, FMX.Grid, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ScrollBox,
   FMX.Memo, FMX.Edit, Data.Bind.ObjectScope, REST.Client, REST.Response.Adapter,
   FMX.Objects;

const
   API_KEY = '.\openai.key';
   OpenAI_PATH = 'https://api.openai.com/v1';

type
   TfrmDemoOpenAI = class(TForm)
      ToolBar1: TToolBar;
      SpeedButton1: TSpeedButton;
      Edit1: TEdit;
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
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure SpeedButton1Click(Sender: TObject);
      procedure SpeedButton2Click(Sender: TObject);
      procedure Button1Click(Sender: TObject);
   private
      procedure InitCompletions;
      { Private declarations }
   public
      { Public declarations }
      procedure OnOpenAIResponse(Sender: TObject);
   end;

var
   frmDemoOpenAI: TfrmDemoOpenAI;
   OpenAIKey: String;

implementation

uses
   MLOpenAI.Core, MLOpenAI.Completions;

var
   OpenAI: TOpenAI;

{$R *.fmx}

procedure TfrmDemoOpenAI.FormCreate(Sender: TObject);
begin
   if FileExists(API_KEY) then
   begin
      // Store your key safely. Never share or expose it!
      OpenAIKey := TFile.ReadAllText(API_KEY);

      OpenAI := TOpenAI.Create(FDMemTable1);
      OpenAI.APIKey := OpenAIKey;
      OpenAI.Endpoint := OpenAI_PATH;
      OpenAI.Engine := TOAIEngine.engDavinci;

      OpenAI.OnResponse := OnOpenAIResponse;
   end
   else
      ShowMessage('Api key file not found');
end;

procedure TfrmDemoOpenAI.FormDestroy(Sender: TObject);
begin
   OpenAI.DisposeOf;
end;

procedure TfrmDemoOpenAI.OnOpenAIResponse(Sender: TObject);
var
   Engine: String;
begin
   OpenAI.AvailableEngines.Count.ToString;

   case OpenAI.RequestType of
      rEngines:
         begin
            for Engine in OpenAI.AvailableEngines.Keys do
            begin
               if Engine = 'davinci' then
                  Memo1.Lines.Add(Engine + ' is ready = ' + OpenAI.AvailableEngines[Engine]);
            end;
         end;
   end;

end;

procedure TfrmDemoOpenAI.SpeedButton1Click(Sender: TObject);
begin
   OpenAI.GetEngines;
end;

// Ref: https://beta.openai.com/docs/api-reference/completions/create
procedure TfrmDemoOpenAI.SpeedButton2Click(Sender: TObject);
begin

   OpenAI.RequestType := rCompletions;
end;

procedure TfrmDemoOpenAI.InitCompletions;
var
   ACompletions: TCompletions;
   i:integer;
begin
   if Edit1.Text.IsEmpty then
   begin
      ShowMessage('A prompt text must be supplied');
      Exit;
   end;

   ACompletions := TCompletions.Create;
   ACompletions.MaxTokens := 5;
   ACompletions.SamplingTemperature := 1; // Default 1
   ACompletions.TopP := 1;
   ACompletions.Stop := ['\n'];
   ACompletions.Prompt := Edit1.Text;
   ACompletions.LogProbabilities := -1; // -1 will set as null default

   OpenAI.RequestType := rCompletions;
   OpenAI.Completions := ACompletions;
   OpenAI.Execute;

end;

procedure TfrmDemoOpenAI.Button1Click(Sender: TObject);
begin
   case OpenAI.RequestType of
      rCompletions:
         InitCompletions();
   end;
end;

end.
