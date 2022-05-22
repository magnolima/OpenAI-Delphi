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
	MLOpenAI.Types, MLOpenAI.Completions,
	MLOpenAI.Files, MLOpenAI.Finetunes;

type
	TRESTRequestOAI = class(TRESTRequest)
	private
		FRequestType: TOAIRequests;
		property RequestType: TOAIRequests read FRequestType write FRequestType;
	end;

type
	TOpenAI = class
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
		FFileDescription: TFileDescription;
		FRESTRequest: TRESTRequestOAI;
		FRESTClient: TRESTClient;
		FRESTResponse: TRESTResponse;
		FMemtable: TFDMemTable;
		FCompletions: TCompletions;
		FStatusCode: Integer;
    FFilePurpose: TFilePurpose;
		procedure readEngines;
		procedure SetEndPoint(const Value: String);
		procedure SetApiKey(const Value: string);
		procedure SetOrganization(const Value: String);
		procedure SetEngine(const Value: TOAIEngine);
		//procedure SetCompletions(const Value: TCompletions);
		procedure CreateRESTRespose;
		procedure CreateRESTClient;
		procedure CreateRESTRequest;
		procedure ExecuteCompletions;
		procedure HttpRequestError(Sender: TCustomRESTRequest);
		procedure HttpClientError(Sender: TCustomRESTClient);
		procedure SetFileDescription(const Value: TFileDescription);
		procedure SetAuthorization;
	public
		constructor Create(var MemTable: TFDMemTable; const APIFileName: String = '');
		destructor Destroy; Override;
		property ErrorMessage: String read FErrorMessage;
		class function Sanitize(const Stops: TArray<String>; Text: String): String; static;
	published
		procedure Execute;
		procedure ExecuteAsync(pProcEndExec: TProc; pProcError: TProc<string>);
		procedure Stop;
		procedure GetEngines;
		function GetChoicesResult: String;
      function GetPersonChoicesResult: string;
		procedure AfterExecute(Sender: TCustomRESTRequest);
		procedure Upload;
		property OnResponse: TNotifyEvent read FOnResponse write FOnResponse;
		property OnError: TNotifyEvent read FOnError write FOnError;
		property StatusCode: Integer read FStatusCode;
		property Engine: TOAIEngine read FEngine write SetEngine;
		property Endpoint: String read FEndpoint write SetEndPoint;
		property Organization: String read FOrganization write SetOrganization;
		property APIKey: String read FAPIKey write SetApiKey;
		property AvailableEngines: TDictionary<String, String> read FEnginesList;
		property RequestType: TOAIRequests read FRequestType write FRequestType;
		//property Completions: TCompletions write SetCompletions;
		property Completions: TCompletions read FCompletions;
		property BodyContent: String read FBodyContent;
		property FileDescription: TFileDescription read FFileDescription write SetFileDescription;
		property FilePurpose: TFilePurpose read FFilePurpose write FFilePurpose;
		procedure SaveToFile(const Filename: String);
	end;

implementation

{ TOpenAI }

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

class function TOpenAI.Sanitize(const Stops: TArray<String>; Text: String): String;
var
	Temp, Stop: String;
	Lines: TArray<String>;
begin

	Temp := StringReplace(Text, #10#10, #13, [rfReplaceAll]);
	for Stop in Stops do
		Temp := StringReplace(Temp, trim(Stop), '', [rfIgnoreCase]);
	Lines := Temp.Split([#10#10, #13]);

	Temp := '';
	Result := '';
	if Length(Lines) > 1 then
		for Temp in Lines do
		begin
			if trim(Temp).Length > 1 then
			begin
{$IF DEFINE(ANDROID)}
				if Temp[0] in [',', '.', ';'] then
{$ELSE}
				if Temp[1] in [',', '.', ';'] then
{$ENDIF}
					Result := trim(Temp.Substring(2))
				else
					Result := Result + trim(Temp) + #10;
			end;
		end
	else
		Result := Lines[0];

	Result := trim(Result);
end;

procedure TOpenAI.SaveToFile(const Filename: String);
var
	SanitizedResponse: String;
begin
	SanitizedResponse := TOpenAI.Sanitize([''], Self.GetChoicesResult);
	Tfile.WriteAllText(Filename, SanitizedResponse);
end;

procedure TOpenAI.CreateRESTRespose;
begin
	FAcceptType := 'application/json';
	FContentType := 'application/json';
	//
	FRESTResponse := TRESTResponse.Create(nil);
	FRESTResponse.Name := '_restresponse';
	FRESTResponse.ContentType := FContentType;
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
begin
	FErrorMessage := '';
	FOnResponse := nil;
	FMemtable := MemTable;
	FCompletions := TCompletions.Create(FEngine);
	CreateRESTRespose();
	CreateRESTClient();
	CreateRESTRequest();

	if not APIFileName.IsEmpty and FileExists(APIFileName) then
	begin
		FAPIKey := Tfile.ReadAllText(APIFileName);
		SetApiKey(FAPIKey);
	end;

end;

destructor TOpenAI.Destroy;
begin
   FCompletions.Free;
	FRESTResponse.Free;
	FRESTRequest.Free;
	FRESTClient.Free;
	FCompletions := nil;
	if Assigned(FEnginesList) then
		FEnginesList.Free;
	inherited Destroy;
end;

procedure TOpenAI.HttpRequestError(Sender: TCustomRESTRequest);
begin
	FRESTRequest.FRequestType := orNone;
	FStatusCode := FRESTRequest.Response.StatusCode;
	FErrorMessage := FRESTRequest.Response.ErrorMessage;
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

procedure TOpenAI.SetFileDescription(const Value: TFileDescription);
begin
	FFileDescription := Value;
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
begin
	Result := '';

	JSonValue := TJSonObject.ParseJSONValue(FBodyContent);
	JsonArray := JSonValue.GetValue<TJSONArray>('choices');
	for ArrayElement in JsonArray do
		Result := Result + ArrayElement.GetValue<String>('text');
	JSonValue.Free;
	JsonArray := nil;
end;

function TOpenAI.GetPersonChoicesResult: string;
var
  lJSonValue: TJSonValue;
  lJsonArray: TJSONArray;
  lArrayElement: TJSonValue;

  lText: TStringList;
  lNewTexto: string;
  lPos: integer;
  lFind: boolean;
begin
  Result := '';
  lFind := False;
  lJSonValue := TJSonObject.ParseJSONValue(FBodyContent);
  lJsonArray := lJSonValue.GetValue<TJSONArray>('choices');
  for lArrayElement in lJsonArray do
    Result := Result + lArrayElement.GetValue<string>('text');

  lText := TStringList.Create;
  lText.Text := Result;
  try
    lNewTexto := '';
    for var li := 0 to lText.Count - 1 do
    begin
      if (Pos(':',lText[li]) > 0) then
      begin
        if not lFind then
          lFind := True
        else
          Break;
      end;

      if lFind then
        lNewTexto := lNewTexto + sLineBreak + lText[li];
    end;

    lPos := Pos(':',lNewTexto);
    lNewTexto:= Copy(lNewTexto,lPos+1,lNewTexto.Length);

    if lNewTexto.Trim <> '' then
      Result := lNewTexto;
  finally
	 lText.Free;
	 lJSonValue.Free;
	 lJsonArray := nil;
  end;

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
	FRESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
begin

	LStatusCode := FRESTResponse.StatusCode;

	if FStatusCode = 0 then
		FStatusCode := LStatusCode;

	if not(FStatusCode in [200, 201]) then
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

	if not FMemtable.IsEmpty then
		FMemtable.EmptyDataSet;

	FRESTResponseDataSetAdapter := TRESTResponseDataSetAdapter.Create(nil);
	try
		FRESTResponseDataSetAdapter.DataSet := FMemtable;
		FRESTResponseDataSetAdapter.Response := FRESTResponse;
		FMemtable.First;
	finally
		FRESTResponseDataSetAdapter.Free;
	end;

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

procedure TOpenAI.SetAuthorization;
begin
	FRESTRequest.Params.Clear;
	FRESTRequest.Params.AddHeader('Authorization', 'Bearer ' + FAPIKey);
	FRESTRequest.Params.ParameterByName('Authorization').Options := [poDoNotEncode];
end;

procedure TOpenAI.SetApiKey(const Value: string);
begin
	FAPIKey := Value;
end;

{procedure TOpenAI.SetCompletions(const Value: TCompletions);
begin
	FCompletions := Value;
end;}

procedure TOpenAI.Execute;
begin
	case FRequestType of
		orCompletions:
			ExecuteCompletions();
	end;
end;

procedure TOpenAI.ExecuteAsync(pProcEndExec: TProc; pProcError: TProc<string>);
begin
	TThread.CreateAnonymousThread(
		procedure
		begin
			try
				try
					Execute;
				except
					on E: Exception do
					begin
						if Assigned(pProcError) then
							TThread.Synchronize(nil,
								procedure
								begin
									pProcError(E.Message);
								end);
					end;
				end;
			finally
				if Assigned(pProcEndExec) then
					TThread.Synchronize(nil,
						procedure
						begin
							pProcEndExec;
						end);
			end;
		end).Start;
end;

procedure TOpenAI.GetEngines;
begin
	Self.RequestType := orEngines;
	SetAuthorization();
	FRESTRequest.ClearBody;
	FRESTRequest.FRequestType := orEngines;
	FRESTRequest.Method := TRESTRequestMethod.rmGET;
	FRESTRequest.Resource := OAI_GET_ENGINES;
	FRESTRequest.Execute;
end;

procedure TOpenAI.ExecuteCompletions;
var
	ABody: String;
begin
	Self.RequestType := orCompletions;
	SetAuthorization();
	FRESTRequest.ClearBody;
	FRESTRequest.Resource := OAI_GET_COMPLETION;
	FRESTRequest.Method := TRESTRequestMethod.rmPOST;
	FCompletions.CreateCompletion(ABody);
	FRESTRequest.Body.Add(ABody, TRESTContentType.ctAPPLICATION_JSON);
	FRESTRequest.Execute;
end;

procedure TOpenAI.Upload;
begin
	// WIP
	SetAuthorization();
	FRESTRequest.AddFile(FileDescription.Filename);
	FRESTRequest.AddBody('', ctMULTIPART_FORM_DATA);
	FRESTRequest.AddParameter('purpose', TFilePurposeName[Ord(FileDescription.Purpose)]);
	// FRESTRequest.Execute;
end;

end.
