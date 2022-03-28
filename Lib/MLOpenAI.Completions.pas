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

  https://beta.openai.com/docs/api-reference/completions/create
*)

unit MLOpenAI.Completions;

interface

uses
  System.SysUtils, REST.Client, REST.Types, System.JSON;

type
  TCompletions = class
  private
    FEngine, FPrompt: String;
    FMaxTokens: Integer;
    FSamplingTemperature: Single;
    FTopP: Single;
    FNumberOfCompletions: Integer;
    FLogProbabilities: Integer;
    FEcho: Boolean;
    FStop: TArray<String>;
    FFrequencyPenalty: Single;
    FPresencePenalty: Single;
    FBestOf: Integer;
    procedure SetMaxTokens(const Value: Integer);
    procedure SetEngine(const Value: String);
    procedure SetPrompt(const Value: String);
    procedure SetSamplingTemperature(const Value: Single);
    procedure SetNucleusSampling(const Value: Single);
    procedure SetNumberOfCompletions(const Value: Integer);
    procedure SetLogProbabilities(const Value: Integer);
    procedure SetEcho(const Value: Boolean);
    procedure SetStop(const Value: TArray<String>);
    procedure SetPresencePenalty(const Value: Single);
    procedure SetFrequencyPenalty(const Value: Single);
    procedure SetBestOf(const Value: Integer);
  public
    constructor Create(EngineIndex: Integer);
    property Engine: String write SetEngine;
    property Prompt: String write SetPrompt;
    property MaxTokens: Integer write SetMaxTokens;
    property SamplingTemperature: Single write SetSamplingTemperature;
    property TopP: Single write SetNucleusSampling;
    property NumberOfCompletions: Integer write SetNumberOfCompletions;
    property LogProbabilities: Integer write SetLogProbabilities;
    property Echo: Boolean write SetEcho;
    property Stop: TArray<String> write SetStop;
    property FrequencyPenalty: Single write SetFrequencyPenalty;
    property PresencePenalty: Single write SetPresencePenalty;
    property BestOf: Integer write SetBestOf;
    procedure CreateCompletion(var ABody: String);
  end;

implementation

uses
  MLOpenAI.Core, MLOpenAI.Types;
{ TCompletion }

(* logit_bias and stream are not yet implemented *)

// max_tokens integer Optional Defaults to 16
procedure TCompletions.SetMaxTokens(const Value: Integer);
begin
  FMaxTokens := Value;
end;

// top_p number Optional Defaults to 1
procedure TCompletions.SetNucleusSampling(const Value: Single);
begin
  FTopP := Value;
end;

// n integer Optional Defaults to 1
procedure TCompletions.SetNumberOfCompletions(const Value: Integer);
begin
  FNumberOfCompletions := Value;
end;

// stream boolean Optional Defaults to <|endoftext|>
procedure TCompletions.SetPresencePenalty(const Value: Single);
begin
  FPresencePenalty := Value;
end;

procedure TCompletions.SetPrompt(const Value: String);
begin
  FPrompt := Value;
end;

// temperature number Optional Defaults to 1
procedure TCompletions.SetSamplingTemperature(const Value: Single);
begin
  FSamplingTemperature := Value;
end;

// stop string or array Optional Defaults to null
procedure TCompletions.SetStop(const Value: TArray<String>);
begin
  FStop := Value;
end;

// logprobs integer Optional Defaults to null
// setting -1 will render as null default
procedure TCompletions.SetLogProbabilities(const Value: Integer);
begin
  FLogProbabilities := Value;
end;

// echo boolean Optional Defaults to false
procedure TCompletions.SetEcho(const Value: Boolean);
begin
  FEcho := Value;
end;

procedure TCompletions.SetEngine(const Value: String);
begin
  FEngine := Value;
end;

procedure TCompletions.SetFrequencyPenalty(const Value: Single);
begin
  FPresencePenalty := Value;
end;

// best_of integer Optional Defaults to 1
procedure TCompletions.SetBestOf(const Value: Integer);
begin
  FBestOf := Value;
end;

constructor TCompletions.Create(EngineIndex: Integer);
begin
  // Set defaults
  FEngine := TOAIEngineName[EngineIndex];
  FPrompt := '';
  FMaxTokens := 16;
  FSamplingTemperature := 1;
  TopP := 1;
  FNumberOfCompletions := 1;
  // FStream := False;
  FLogProbabilities := -1;
  FEcho := false;
  FStop := nil;
  FPresencePenalty := 0;
  FFrequencyPenalty := 0;
  FBestOf := 1;
  // logit_bias = nil
end;

procedure TCompletions.CreateCompletion(var ABody: String);
// (var ABody: TCustomRESTRequest.TBody);
var
  AJSONObject: TJSONObject;
  AJSONPair: TJSONPair;
  Value, Stop: String;
begin
  AJSONObject := TJSONObject.Create;
  AJSONObject.AddPair(TJSONPair.Create('prompt', FPrompt));
  AJSONObject.AddPair(TJSONPair.Create('temperature', TJSONNumber.Create(FSamplingTemperature)));
  AJSONObject.AddPair(TJSONPair.Create('max_tokens', TJSONNumber.Create(FMaxTokens)));
  AJSONObject.AddPair(TJSONPair.Create('top_p', TJSONNumber.Create(FTopP)));
  AJSONObject.AddPair(TJSONPair.Create('frequency_penalty', TJSONNumber.Create(FFrequencyPenalty)));
  AJSONObject.AddPair(TJSONPair.Create('presence_penalty', TJSONNumber.Create(FPresencePenalty)));

  for Stop in FStop do
    AJSONObject.AddPair(TJSONPair.Create('stop', Stop));

  if FNumberOfCompletions <> 1 then
    AJSONObject.AddPair(TJSONPair.Create('n', TJSONNumber.Create(FNumberOfCompletions)));

{$REGION "TODO: soon"}
//  if FLogProbabilities = -1 then
//    AJSONObject.AddPair(TJSONPair.Create('logprobs', 'null'))
//  else
//    AJSONObject.AddPair(TJSONPair.Create('logprobs', TJSONNumber.Create(FLogProbabilities)));
{$ENDREGION}

  ABody := AJSONObject.ToJSON;
  AJSONObject.Free;

end;

end.
