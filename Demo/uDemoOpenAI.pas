(*
  (C)2021-2023 Magno Lima - www.MagnumLabs.com.br

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

  https://platform.openai.com/docs/introduction/overview

*)
unit uDemoOpenAI;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants, System.StrUtils,
   FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.IOUtils,
   FMX.StdCtrls, FMX.Controls.Presentation, FireDAC.Stan.Intf,
   FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
   FireDAC.Phys.Intf, FireDAC.DApt.Intf, System.Rtti, FMX.Grid.Style,
   Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs,
   FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
   Data.DB, FMX.Grid, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ScrollBox,
   FMX.Memo, FMX.Edit, Data.Bind.ObjectScope, REST.Client, REST.Response.Adapter,
   FMX.Objects, FMX.TabControl, FMX.EditBox, FMX.NumberBox, FMX.Memo.Types,
   REST.Types, System.Generics.Collections, FMX.ListBox, Skia, Skia.FMX,
   System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
   MLOpenAI.Types, MLOpenAI.Completions, MLOpenAI.Core, MLOpenAI.Images, MLOpenAI.Files;

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
      Memo3: TMemo;
      Label16: TLabel;
      cbImageSize: TComboBox;
      Label17: TLabel;
      tbNumberOfImages: TTrackBar;
      NetHTTPClient1: TNetHTTPClient;
      Label18: TLabel;
      Panel2: TPanel;
      Memo2: TMemo;
      ImageDallE: TImage;
      Panel3: TPanel;
      Panel4: TPanel;
      sbNextImage: TSpeedButton;
      sbPrevImage: TSpeedButton;
      Splitter1: TSplitter;
    RadioButton5: TRadioButton;
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
      procedure NetHTTPClient1ReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
      procedure NetHTTPClient1RequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
      procedure sbPrevImageClick(Sender: TObject);
      procedure sbNextImageClick(Sender: TObject);
      procedure tbNumberOfImagesChange(Sender: TObject);
   private
      FEngine: TOAIEngine;
      FOpenAI: TOpenAI;
      procedure InitCompletions;
      procedure InitFile;
      procedure OnOpenAIError(Sender: TObject);
      procedure Submit;
      procedure InitImages;
      procedure LoadImage(const filename: string);
      procedure DownloadImage(const uri: string);
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
   FileStream: TFileStream;
   FContentLength: Boolean;
   FImageFileName: String;
   FRootDir: String;
   FImageIndex: Integer;
   ListOfImages: TArray<String>;

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
   if (FOpenAI.StatusCode = 400) and (FOpenAI.RequestType = TOAIRequests.orImages) then
   begin
      Memo2.Lines.Add('Bad request. Your prompt contains non acceptable worlds, please your prompt.');
      exit;
   end;

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
   FRootDir := ExtractFilePath(ParamStr(0));
   TDirectory.CreateDirectory(FRootDir + 'images');

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
      Label9.Text := OpenDialog1.filename;
      AFileDescription.filename := OpenDialog1.filename;
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
   tmp, SanitizedResponse: String;
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
      // FOpenAI.SaveToFile('.\response.txt');
      Memo2.Lines.Add(SanitizedResponse);
      Memo2.Lines.Add(StringOfChar('-', 40));
   end;

   if FOpenAI.RequestType = TOAIRequests.orImages then
   begin

      if FOpenAI.Images.ResponseFormat = TResponseFormat.rfUrl then
         Memo2.Lines.Clear;

      for field in FDMemTable1.Fields do
      begin
         if FOpenAI.Images.ResponseFormat = TResponseFormat.rfUrl then
         begin
            if field.AsString.Contains('url') then
            begin
               tmp := field.AsString;
               tmp := Copy(tmp, Pos('"url":"', tmp) + 7);
               Memo2.Lines.Add('Downloading image, wait');
               DownloadImage(tmp);
            end;
         end
      end;

      if FOpenAI.Images.ResponseFormat = TResponseFormat.rfB64Json then
         ListOfImages := FOpenAI.Images.DecodeJsonToFile(FRootDir + 'images\');

      if length(ListOfImages) > 0 then
      begin
         FImageIndex := 0;
         LoadImage(ListOfImages[FImageIndex]);
      end;
      exit;
   end;

   if FOpenAI.RequestType = TOAIRequests.orEngines then
   begin
      for Engine in FOpenAI.AvailableEngines do
         Memo2.Lines.Add(Engine.Key + ' = ' + Trim(Engine.value))
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

   FOpenAI.Engine := TOAIEngine(Ord(EngineIndex));

   lbEngine.Text := 'Engine: ' + NameOfEngines[Ord(EngineIndex)];
end;

procedure TfrmDemoOpenAI.SpeedButton1Click(Sender: TObject);
begin
   Label2.Text := 'Engines';
   FOpenAI.RequestType := orEngines;
   TabControl1.TabIndex := 0;
end;

// Ref: https://platform.openai.com/docs/api-reference/completions
procedure TfrmDemoOpenAI.SpeedButton2Click(Sender: TObject);
begin
   Label2.Text := 'Completions';
   FOpenAI.RequestType := orCompletions;
   TabControl1.TabIndex := 1;
end;

procedure TfrmDemoOpenAI.SpeedButton3Click(Sender: TObject);
begin
   Label2.Text := 'Images';
   TabControl1.TabIndex := 2;
   FOpenAI.RequestType := orImages;
   lbEngine.Text := 'Engine: DALL-E';
end;

procedure TfrmDemoOpenAI.SpeedButton4Click(Sender: TObject);
begin
   Label2.Text := 'Files';
   TabControl1.TabIndex := 3;
   FOpenAI.RequestType := orFiles;
end;

procedure TfrmDemoOpenAI.sbNextImageClick(Sender: TObject);
begin
   if FImageIndex = length(ListOfImages) - 1 then
      exit;
   inc(FImageIndex);
   LoadImage(ListOfImages[FImageIndex]);
end;

procedure TfrmDemoOpenAI.sbPrevImageClick(Sender: TObject);
begin
   if FImageIndex = 0 then
      exit;
   Dec(FImageIndex);
   LoadImage(ListOfImages[FImageIndex]);
end;

procedure TfrmDemoOpenAI.InitImages;
var
   sPrompt: String;
begin

   sPrompt := Memo3.Text.Trim;

   FOpenAI.Images.ResponseFormat := TResponseFormat.rfB64Json;
   FOpenAI.RequestType := orImages;
   FOpenAI.Endpoint := OpenAI_PATH;
   FOpenAI.Images.Prompt := sPrompt;
   FOpenAI.Images.User := 'OpenAIDemo';
   FOpenAI.Images.NumberOfImages := Round(tbNumberOfImages.value);
   case cbImageSize.ItemIndex of
      0:
         FOpenAI.Images.Size := TImageSize.is256x256;
      1:
         FOpenAI.Images.Size := TImageSize.is512x512;
      2:
         FOpenAI.Images.Size := TImageSize.is1024x1024;
   end;
end;

procedure TfrmDemoOpenAI.InitCompletions;
var
   sPrompt: String;
begin

   sPrompt := Memo1.Text.Trim;

   if sPrompt.IsEmpty then
   begin
      ShowMessage('A prompt text must be supplied');
      exit;
   end;
   FOpenAI.Engine := FEngine;
   FOpenAI.RequestType := orCompletions;
   FOpenAI.Endpoint := OpenAI_PATH + '/engines/' + FEngine.ToString;
   FOpenAI.Completions.MaxTokens := Round(nbMaxTokens.value);
   FOpenAI.Completions.SamplingTemperature := nbTemperature.value;
   FOpenAI.Completions.TopP := nbTopP.value;
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
   Label15.Text := Round(nbLogProb.value).ToString;
end;

procedure TfrmDemoOpenAI.nbMaxTokensChange(Sender: TObject);
begin
   Label12.Text := Round(nbMaxTokens.value).ToString;
end;

procedure TfrmDemoOpenAI.nbTemperatureChange(Sender: TObject);
begin
   Label13.Text := Format('%0.2f', [nbTemperature.value]);
end;

procedure TfrmDemoOpenAI.nbTopPChange(Sender: TObject);
begin
   Label14.Text := Format('%0.2f', [nbTopP.value]);
end;

procedure TfrmDemoOpenAI.NetHTTPClient1ReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
   if AContentLength > 0 then
   begin
      AniIndicator1.visible := true;
      AniIndicator1.Enabled := true;
      FContentLength := true;
   end;
end;

procedure TfrmDemoOpenAI.DownloadImage(const uri: string);
var
   lImageFileName: TImageFileName;
begin

   TThread.CreateAnonymousThread(
      procedure
      begin
         AniIndicator1.Enabled := true;
         AniIndicator1.visible := true;
         lImageFileName := TImages.ExtractImageFileName(uri);
         FImageFileName := FRootDir + 'images\' + lImageFileName.filename;
         DeleteFile(FImageFileName);
         FileStream := TFileStream.Create(FImageFileName, fmCreate);
         try
            FContentLength := False;
            NetHTTPClient1.Get(lImageFileName.SanitizedUrl, FileStream);
         except
            // ASyncService.ShowMessageAsync(DM.TranslateDialog('sDownloadFailed'));
            FileStream.Free;
         end;
      end).Start;
end;

procedure TfrmDemoOpenAI.LoadImage(const filename: string);
begin

   ImageDallE.Bitmap := nil;
   try
      ImageDallE.Bitmap.LoadFromFile(filename);
   Except
      on E: Exception do
         ShowMessage(E.Message);
   end;

end;

procedure TfrmDemoOpenAI.NetHTTPClient1RequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin
   if Assigned(FileStream) then
      FileStream.Free;

   Memo2.Lines.Add('Image is ready: ' + FImageFileName);

   FContentLength := False;

   AniIndicator1.visible := False;
   AniIndicator1.Enabled := False;

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
      exit;
   end;

   if (FOpenAI.Engine = egGPT3_5Turbo) then
   begin
      Memo2.Text := 'ChatGPT demo isn''t implemented yet, however the Chat lib is ready!';
      exit;
   end;

   if (FOpenAI.RequestType = orFiles) and (OpenDialog1.filename = '') then
   begin
      Memo2.Lines.Add('Choose a file to upload');
      exit;
   end;

   if (FOpenAI.RequestType = orCompletions) and (Memo1.Text.IsEmpty) then
   begin
      Memo2.Lines.Add('Nothing to do here...');
      exit;
   end;

   if FOpenAI.RequestType = orNone then
   begin
      Memo2.Lines.Add('Choose a request type.');
      exit;
   end;

   if (FOpenAI.RequestType = orImages) and (Memo3.Text.IsEmpty) then
      exit;

   Button1.Enabled := False;
   AniIndicator1.Enabled := true;
   AniIndicator1.visible := true;

   TThread.CreateAnonymousThread(
      procedure
      begin

         try
            case FOpenAI.RequestType of
               orEngines:
                  begin
                     FOpenAI.Endpoint := OpenAI_PATH;
                     FOpenAI.GetEngines();
                     exit;
                  end;
               orCompletions:
                  InitCompletions();
               orFiles:
                  InitFile();
               orImages:
                  begin
                     InitImages();
                     Memo2.Text := 'Generating the image, please wait...';
                  end;
            end;

            try
               FOpenAI.Execute;
            except
               on E: Exception do
                  Memo2.Lines.Add(E.Message)
            end;

         finally
            Button1.Enabled := true;
            AniIndicator1.Enabled := False;
            AniIndicator1.visible := False;
         end;

      end).Start;
end;

procedure TfrmDemoOpenAI.tbNumberOfImagesChange(Sender: TObject);
begin
   Label17.Text := 'Images to generate: ' + IntToStr(Round(tbNumberOfImages.value))
end;

end.
