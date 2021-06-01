(*
  (C)2021 Magno Lima - www.MagnumLabs.com.br - Version 1.0

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
   Winapi.Windows, Data.Bind.ObjectScope, REST.Client, REST.Types, FireDAC.Stan.Intf,
   FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, REST.Response.Adapter,
   FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, System.StrUtils, System.Generics.Collections,
   Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Types,
   System.IOUtils, System.TypInfo, System.JSON;

const
   OAI_GET_ENGINES = '/engines';
   OAI_GET_COMPLETION = '/completions';
   OAI_SEARCH = '/search';
   OAI_CLASSIFICATIONS = '/classifications';
   OAI_ANSWER = '/answers';
   OAI_FILES = '/files';

type
   TOAIEngine = (engDavinci, engCurie, engBabbage, engAda);
   TOAIRequests = (rCustom, rAuth, rEngines, rCompletions, rSearch, rClassifications, rAnswers, rFiles);

type
   TRESTRequestOAI = class(TRESTRequest)
   private
      FRequestType: TOAIRequests;
      property RequestType: TOAIRequests read FRequestType write FRequestType;
   end;

type
   TOpenAI = class(TObject)
   private
      //
      FAcceptType: String;
      FContentType: String;
      FEndpoint: String;
      FResource: String;
      FPayload: String;
      FErrorMessage: String;
      FEngine: TOAIEngine;
      FRequestType: TOAIRequests;
      FEnginesList: TDictionary<String, String>;
      FOnResponse: TNotifyEvent;
      FOnError: TNotifyEvent;
      FAPIKey: String;
      FOrganization: String;
      FRESTRequest: TRESTRequestOAI;
      FRESTClient: TRESTClient;
      FRESTResponse: TRESTResponse;
      FMemtable: TFDMemTable;
      FRESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
      procedure readEngines;
      procedure SetEndPoint(const Value: String);
      procedure SetApiKey(const Value: string);
      procedure SetOrganization(const Value: String);
      procedure SetEngine(const Value: TOAIEngine);
   public
      constructor Create(var MemTable: TFDMemTable);
      destructor Destroy; Override;
      procedure HttpError(Sender: TCustomRESTClient);
      property ErrorMessage: String read FErrorMessage;
   published
      procedure AfterExecute(Sender: TCustomRESTRequest);
      procedure Execute;
      procedure Stop;
      procedure GetEngines;
      property OnResponse: TNotifyEvent read FOnResponse write FOnResponse;
      property OnError: TNotifyEvent read FOnError write FOnError;
      property Engine: TOAIEngine read FEngine write SetEngine;
      property Endpoint: String read FEndpoint write SetEndPoint;
      property Organization: String read FOrganization write SetOrganization;
      property APIKey: String write SetApiKey;
      property AvailableEngines: TDictionary<String, String> read FEnginesList;
      property RequestType: TOAIRequests read FRequestType write FRequestType;
   end;

implementation

uses
   MLOpenAI.Completions;

{ TOpenAI }

constructor TOpenAI.Create(var MemTable: TFDMemTable);
begin
   FErrorMessage := '';
   FOnResponse := nil;
   FMemtable := MemTable;
   //
   FAcceptType := 'application/json'; // 'application/json, text/plain; q=0.9, text/html;q=0.8,';
   FContentType := 'application/json';
   FRESTResponse := TRESTResponse.Create(nil);
   FRESTResponse.Name := '_restresponse';
   FRESTResponse.ContentType := FContentType;
   //
   //
   FRESTResponseDataSetAdapter := TRESTResponseDataSetAdapter.Create(nil);
   FRESTResponseDataSetAdapter.DataSet := MemTable;
   FRESTResponseDataSetAdapter.Response := FRESTResponse;
   // Client
   FRESTClient := TRESTClient.Create(nil);
   FRESTClient.AcceptCharset := 'UTF-8';
   FRESTClient.UserAgent := 'MLOAIClient';
   FRESTClient.Accept := FAcceptType;
   FRESTClient.ContentType := FContentType;
   FRESTClient.OnHTTPProtocolError := HttpError;
   // Request
   FRESTRequest := TRESTRequestOAI.Create(nil);
   FRESTRequest.AcceptCharset := 'UTF-8';
   FRESTRequest.Accept := FAcceptType;
   FRESTRequest.Method := TRESTRequestMethod.rmPOST;
   FRESTRequest.Params.Clear;
   FRESTRequest.Body.ClearBody;
   FRESTRequest.Response := FRESTResponse;
   FRESTRequest.Client := FRESTClient;
   FRESTRequest.OnAfterExecute := AfterExecute;
   FRESTRequest.FRequestType := TOAIRequests.rCustom;
end;

destructor TOpenAI.Destroy;
begin
   FRESTResponse.Free;
   FRESTRequest.Free;
   FRESTClient.Free;
   FRESTResponseDataSetAdapter.Free;
   inherited Destroy;
end;

procedure TOpenAI.Execute;
begin
   FRESTRequest.ClearBody;
   FRESTRequest.Body.Add(FPayload, TRESTContentType.ctAPPLICATION_JSON);
   FRESTRequest.Execute;
end;

procedure TOpenAI.HttpError(Sender: TCustomRESTClient);
begin
   FRESTRequest.FRequestType := rCustom;
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
   FRESTRequest.FRequestType := rCustom;
end;

procedure TOpenAI.readEngines();
begin
   if not Assigned(FEnginesList) then
   begin
      FEnginesList := TDictionary<String, String>.Create;
   end
   else
      FEnginesList.Clear;

   FMemtable.First;
   while not FMemtable.Eof do
   begin
      FEnginesList.Add(FMemtable.FieldByName('id').AsString, FMemtable.FieldByName('ready').AsString);
      FMemtable.Next;
   end;

end;

procedure TOpenAI.AfterExecute(Sender: TCustomRESTRequest);
begin
   FRESTResponse.RootElement := 'data';
   FRESTResponseDataSetAdapter.ResponseJSON := FRESTResponse;

   case FRESTRequest.FRequestType of
      rCustom:
         ;
      rAuth:
         ;
      rEngines:
         readEngines();
      rCompletions:
         ;
      rSearch:
         ;
      rClassifications:
         ;
      rAnswers:
         ;
      rFiles:
         ;
   end;

   //
   FRESTRequest.FRequestType := rCustom;
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

procedure TOpenAI.GetEngines;
begin
   Self.RequestType := rEngines;
   FRESTRequest.FRequestType := rEngines;
   FRESTRequest.Method := TRESTRequestMethod.rmGET;
   FRESTRequest.Resource := OAI_GET_ENGINES;
   FRESTRequest.Execute;
end;

end.
