(*
  (C)2021-2022 Magno Lima - www.MagnumLabs.com.br - Version 1.0

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

unit MLOpenAI.Core;

interface

uses
  System.Diagnostics, System.Classes, System.SysUtils, Data.Bind.Components,
  Data.Bind.ObjectScope, REST.Client, REST.Types,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  REST.Response.Adapter,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, System.StrUtils,
  System.Generics.Collections,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Types,
  System.IOUtils, System.TypInfo, System.JSON,
  MLOpenAI.Completions;

const
  OAI_GET_ENGINES = '/engines';
  OAI_GET_COMPLETION = '/completions';
  OAI_SEARCH = '/search';
  OAI_CLASSIFICATIONS = '/classifications';
  OAI_ANSWER = '/answers';
  OAI_FILES = '/files';
  TOAIEngineName: TArray<String> = ['text-davinci-002', 'text-davinci-001', 'text-curie-001', 'text-babbage-001', 'text-ada-001', 'davinci',
    'curie', 'babbage', 'ada'];

type
  TOAIEngine = (egTextDavinci002, egTextDavinci001, egTextCurie001, egTextBabbage001, egTextAda001, egDavinci, egCurie, egBabbage, egAda);
  TOAIRequests = (orNone, rAuth, orEngines, orCompletions, orSearch, rClassifications, orAnswers, orFiles);
  TFilePurpose = (fpAnswer, fpSearch, fpClassification, fpFineTune);

type
  TRESTRequestOAI = class(TRESTRequest)
  private
    FRequestType: TOAIRequests;
    property RequestType: TOAIRequests read FRequestType write FRequestType;
  end;

  // Maybe now, we could use advanced class-like record here instead of class
type
  TOpenAI = class(TObject)
  private
    //
    FAcceptType: String;
    FContentType: String;
    FEndpoint: String;
    FResource: String;
    FErrorMessage: String;
    FBodyContent: String;
    FEngine: TOAIEngine;
    FRequestType: TOAIRequests;
    FEnginesList: TDictionary<String, String>;
    FOnResponse: TNotifyEvent;
    FOnError: TNotifyEvent;
    FAPIKey: String;
    FOrganization: String;
    FFilePurpose: TFilePurpose;
    FRESTRequest: TRESTRequestOAI;
    FRESTClient: TRESTClient;
    FRESTResponse: TRESTResponse;
    FMemtable: TFDMemTable;
    FRESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
    FCompletions: TCompletions;
    FStatusCode: Integer;
    procedure readEngines;
    procedure SetEndPoint(const Value: String);
    procedure SetApiKey(const Value: string);
    procedure SetOrganization(const Value: String);
    procedure SetEngine(const Value: TOAIEngine);
    procedure SetCompletions(const Value: TCompletions);
    procedure CreateRESTRespose;
    procedure CreateRESTClient;
    procedure CreateRESTRequest;
    procedure ExecuteCompletions;
    procedure HttpRequestError(Sender: TCustomRESTRequest);
    procedure HttpClientError(Sender: TCustomRESTClient);
  public
    constructor Create(var MemTable: TFDMemTable; const APIFileName: String = '');
    destructor Destroy; Override;
    // procedure HttpError(Sender: TCustomRESTClient);
    property ErrorMessage: String read FErrorMessage;
  published
    procedure Execute;
    procedure Stop;
    procedure GetEngines;
    function GetChoicesResult: String;
    procedure AfterExecute(Sender: TCustomRESTRequest);
    property OnResponse: TNotifyEvent read FOnResponse write FOnResponse;
    property OnError: TNotifyEvent read FOnError write FOnError;
    property StatusCode: Integer read FStatusCode;
    property Engine: TOAIEngine read FEngine write SetEngine;
    property Endpoint: String read FEndpoint write SetEndPoint;
    property Organization: String read FOrganization write SetOrganization;
    property APIKey: String read FAPIKey write SetApiKey;
    property AvailableEngines: TDictionary<String, String> read FEnginesList;
    property RequestType: TOAIRequests read FRequestType write FRequestType;
    property Completions: TCompletions write SetCompletions;
    property BodyContent: String read FBodyContent;
    property FilePurpose: TFilePurpose read FFilePurpose write FFilePurpose;

  end;

implementation

{ TOpenAI }

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

  while (I < Length(AString)) do
  begin
    while (PLine^ <> #0) and (PLine^ <> ADelimiter) do
    begin
      inc(PLine);
      inc(I);
    end;

    SetString(s, PStart, PLine - PStart);
    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := s;
    inc(PLine);
    inc(I);
    PStart := PLine;
  end;

end;

procedure TOpenAI.CreateRESTRespose;
begin
  FAcceptType := 'application/json';
  FContentType := 'application/json';
  //
  FRESTResponse := TRESTResponse.Create(nil);
  FRESTResponse.Name := '_restresponse';
  FRESTResponse.ContentType := FContentType;
  //
  FRESTResponseDataSetAdapter := TRESTResponseDataSetAdapter.Create(nil);
  FRESTResponseDataSetAdapter.DataSet := FMemtable;
  FRESTResponseDataSetAdapter.Response := FRESTResponse;
end;

procedure TOpenAI.CreateRESTClient;
begin
  FRESTClient := TRESTClient.Create(nil);
  FRESTClient.AcceptCharset := 'UTF-8';
  FRESTClient.UserAgent := 'MagnumLabsOAIClient';
  FRESTClient.Accept := FAcceptType;
  FRESTClient.ContentType := FContentType;
  FRESTClient.OnHTTPProtocolError := HttpClientError;
end;

procedure TOpenAI.CreateRESTRequest;
begin
  FRESTRequest := TRESTRequestOAI.Create(nil);
  FRESTRequest.AcceptCharset := 'UTF-8';
  FRESTRequest.Accept := FAcceptType;
  FRESTRequest.Method := TRESTRequestMethod.rmPOST;
  FRESTRequest.Params.Clear;
  FRESTRequest.Body.ClearBody;
  FRESTRequest.Response := FRESTResponse;
  FRESTRequest.Client := FRESTClient;
  FRESTRequest.OnAfterExecute := AfterExecute;
  FRESTRequest.FRequestType := TOAIRequests.orNone;
  FRESTRequest.OnHTTPProtocolError := HttpRequestError;
end;

constructor TOpenAI.Create(var MemTable: TFDMemTable; const APIFileName: String = '');
var
  fileName: String;
begin
  FErrorMessage := '';
  FOnResponse := nil;
  FMemtable := MemTable;
  //
  CreateRESTRespose();
  //
  CreateRESTClient();
  //
  CreateRESTRequest();

{$IF Defined(ANDROID)}
  fileName := TPath.Combine(TPath.GetDocumentsPath, APIFileName);
{$ELSE}
  fileName := APIFileName;
{$ENDIF}
  if not APIFileName.IsEmpty and FileExists(fileName) then
  begin
    FAPIKey := TFile.ReadAllText(fileName);
    SetApiKey(FAPIKey);
  end;

end;

destructor TOpenAI.Destroy;
begin
  FRESTResponse.Free;
  FRESTRequest.Free;
  FRESTClient.Free;
  FRESTResponseDataSetAdapter.Free;
  inherited Destroy;
end;

procedure TOpenAI.HttpRequestError(Sender: TCustomRESTRequest);
begin
  FRESTRequest.FRequestType := orNone;
  FStatusCode := FRESTRequest.Response.StatusCode;
  FErrorMessage := 'Request error: ' + FRESTRequest.Response.StatusCode.ToString;
  FOnError(Self);
end;

procedure TOpenAI.HttpClientError(Sender: TCustomRESTClient);
begin
  FRESTRequest.FRequestType := orNone;
  FErrorMessage := FRESTRequest.Response.ErrorMessage;
  FOnError(Self);
end;

procedure TOpenAI.SetEndPoint(const Value: String);
begin
  FEndpoint := Value;
  FRESTClient.BaseURL := Value;
end;

procedure TOpenAI.SetEngine(const Value: TOAIEngine);
begin
  FEngine := Value;
end;

procedure TOpenAI.SetOrganization(const Value: String);
begin
  FOrganization := Value;
end;

procedure TOpenAI.Stop;
begin
  FRESTRequest.FRequestType := orNone;
end;

function TOpenAI.GetChoicesResult: String;
var
  JSonValue: TJSonValue;
  JsonArray: TJSONArray;
  ArrayElement: TJSonValue;
  FoundValue: TJSonValue;
begin
  Result := '';

  JSonValue := TJSonObject.ParseJSONValue(FBodyContent);
  JsonArray := JSonValue.GetValue<TJSONArray>('choices');
  for ArrayElement in JsonArray do
    Result := Result + ArrayElement.GetValue<String>('text');

end;

procedure TOpenAI.readEngines();
begin
  if not Assigned(FEnginesList) then
    FEnginesList := TDictionary<String, String>.Create;

  FEnginesList.Clear;
  while not FMemtable.Eof do
  begin
    FEnginesList.Add(FMemtable.FieldByName('id').AsString, FMemtable.FieldByName('ready').AsString);
    FMemtable.Next;
  end;

end;

procedure TOpenAI.AfterExecute(Sender: TCustomRESTRequest);
var
  LStatusCode: Integer;
begin

  LStatusCode := FRESTResponse.StatusCode;

  if FStatusCode = 0 then
    FStatusCode := LStatusCode;

  if not (FStatusCode in [200,201]) then
    Exit;

  FBodyContent := FRESTResponse.Content;

  case FRequestType of
    orEngines:
      FRESTResponse.RootElement := 'data';
    orCompletions:
      FRESTResponse.RootElement := 'choices';
    orSearch:
      ;
    rClassifications:
      ;
    orAnswers:
      ;
    orFiles:
      ;
  end;

  FRESTResponseDataSetAdapter.ResponseJSON := FRESTResponse;
  FMemtable.First;

  case FRequestType of
    orNone:
      ;
    rAuth:
      ;
    orEngines:
      readEngines();
    orCompletions:
      ;
    orSearch:
      ;
    rClassifications:
      ;
    orAnswers:
      ;
    orFiles:
      ;
  end;

  FRESTRequest.FRequestType := orNone;
  if Assigned(FOnResponse) then
    FOnResponse(Self);
end;

{ * https://beta.openai.com/docs/api-reference/authentication * }
procedure TOpenAI.SetApiKey(const Value: string);
begin
  FAPIKey := Value;
  FRESTRequest.Params.AddHeader('Authorization', 'Bearer ' + FAPIKey);
  FRESTRequest.Params.ParameterByName('Authorization').Options := [poDoNotEncode];
end;

procedure TOpenAI.SetCompletions(const Value: TCompletions);
begin
  FCompletions := Value;
end;

procedure TOpenAI.Execute;
begin
  // FRESTRequest.ClearBody;
  // FRESTRequest.Body.Add(FPayload, TRESTContentType.ctAPPLICATION_JSON);
  // FRESTRequest.Execute;
  // FMemtable.Open;

  if not FMemtable.IsEmpty then
    FMemtable.EmptyDataSet;
  // FMemtable.Close;
  case FRequestType of
    orCompletions:
      ExecuteCompletions();
  end;
end;

procedure TOpenAI.GetEngines;
begin
  Self.RequestType := orEngines;
  FRESTRequest.FRequestType := orEngines;
  FRESTRequest.Method := TRESTRequestMethod.rmGET;
  FRESTRequest.Resource := OAI_GET_ENGINES;
  FRESTRequest.Execute;
end;

procedure TOpenAI.ExecuteCompletions;
var
  ABody: String;
begin
  FRESTRequest.ClearBody;
  FCompletions.CreateCompletion(ABody);
  FRESTRequest.Body.Add(ABody, TRESTContentType.ctAPPLICATION_JSON);
  FRESTRequest.Method := TRESTRequestMethod.rmPOST;
  FRESTRequest.Execute;
end;

end.
