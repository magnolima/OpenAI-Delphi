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
	System.SysUtils, System.Generics.Collections, REST.Client, REST.Types,
	System.JSON, MLOpenAI.Types;

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
		FUser: String;
		FUserParameters: TDictionary<String, String>;
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
		procedure SetUser(const Value: String);
	public
		constructor Create(AEngine: TOAIEngine);
		destructor Destroy; override;
		property Engine: String write SetEngine;
		property Prompt: String read FPrompt write SetPrompt;
		property MaxTokens: Integer read FMaxTokens write SetMaxTokens;
		property SamplingTemperature: Single read FSamplingTemperature write SetSamplingTemperature;
		property TopP: Single read FTopP write SetNucleusSampling;
		property NumberOfCompletions: Integer read FNumberOfCompletions write SetNumberOfCompletions;
		property LogProbabilities: Integer read FLogProbabilities write SetLogProbabilities;
		property Echo: Boolean read FEcho write SetEcho;
		property Stop: TArray<String> read FStop write SetStop;
		property FrequencyPenalty: Single read FFrequencyPenalty write SetFrequencyPenalty;
		property PresencePenalty: Single read FPresencePenalty write SetPresencePenalty;
		property BestOf: Integer read FBestOf write SetBestOf;
		property User: String read FUser write SetUser;
		procedure CreateCompletion(var ABody: String);
		procedure AddStringParameter(const Name: String; Value: String);
	end;

implementation

uses
	MLOpenAI.Core;

{ TCompletion }

(* logit_bias and stream are not yet implemented *)

procedure TCompletions.SetMaxTokens(const Value: Integer);
begin
	FMaxTokens := Value;
end;

procedure TCompletions.SetNucleusSampling(const Value: Single);
begin
	FTopP := Value;
end;

procedure TCompletions.SetNumberOfCompletions(const Value: Integer);
begin
	FNumberOfCompletions := Value;
end;

procedure TCompletions.SetPresencePenalty(const Value: Single);
begin
	FPresencePenalty := Value;
end;

procedure TCompletions.SetPrompt(const Value: String);
begin
	FPrompt := Value;
end;

procedure TCompletions.SetSamplingTemperature(const Value: Single);
begin
	FSamplingTemperature := Value;
end;

procedure TCompletions.SetStop(const Value: TArray<String>);
begin
	FStop := Value;
end;

procedure TCompletions.SetUser(const Value: String);
begin
	FUser := Value;
end;

procedure TCompletions.SetLogProbabilities(const Value: Integer);
begin
	FLogProbabilities := Value;
end;

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
	FFrequencyPenalty := Value;
end;

procedure TCompletions.SetBestOf(const Value: Integer);
begin
	FBestOf := Value;
end;

procedure TCompletions.AddStringParameter(const Name: String; Value: String);
begin
	FUserParameters.TryAdd(Name, Value);
end;

constructor TCompletions.Create(AEngine: TOAIEngine);
begin
	FMaxTokens := 16;
	FSamplingTemperature := 0.5;
	FNumberOfCompletions := 1;
	FLogProbabilities := -1;
	FBestOf := 1;
	FUserParameters := TDictionary<string, String>.Create;
end;

procedure TCompletions.CreateCompletion(var ABody: String);
var
	AJSONObject: TJSONObject;
	JSONArray: TJSONArray;
	Value, Stop: String;
begin
	AJSONObject := TJSONObject.Create;
	JSONArray := nil;
	try
		AJSONObject.AddPair(TJSONPair.Create('prompt', FPrompt));
		AJSONObject.AddPair(TJSONPair.Create('temperature', TJSONNumber.Create(Trunc(FSamplingTemperature * 100) / 100)));
		AJSONObject.AddPair(TJSONPair.Create('max_tokens', TJSONNumber.Create(FMaxTokens)));
		AJSONObject.AddPair(TJSONPair.Create('top_p', TJSONNumber.Create(FTopP)));
		AJSONObject.AddPair(TJSONPair.Create('frequency_penalty', TJSONNumber.Create(Trunc(FFrequencyPenalty * 100) / 100)));
		AJSONObject.AddPair(TJSONPair.Create('presence_penalty', TJSONNumber.Create(Trunc(FPresencePenalty * 100) / 100)));

		for Value in FUserParameters.Keys do
			AJSONObject.AddPair(TJSONPair.Create(Value, FUserParameters[Value]));

		if not FUser.IsEmpty then
			AJSONObject.AddPair(TJSONPair.Create('user', FUser));

		if Length(FStop) > 0 then
		begin
			JSONArray := TJSONArray.Create;
			for Stop in FStop do
				JSONArray.Add(Stop);
			AJSONObject.AddPair(TJSONPair.Create('stop', JSONArray));
		end;

		if FNumberOfCompletions <> 1 then
			AJSONObject.AddPair(TJSONPair.Create('n', TJSONNumber.Create(FNumberOfCompletions)));

{$REGION "TODO: soon"}
		// if FLogProbabilities = -1 then
		// AJSONObject.AddPair(TJSONPair.Create('logprobs', 'null'))
		// else
		// AJSONObject.AddPair(TJSONPair.Create('logprobs', TJSONNumber.Create(FLogProbabilities)));
{$ENDREGION}
		ABody := UTF8ToString(AJSONObject.ToJSON);

	finally
		if Assigned(JSONArray) then
			JSONArray.Free;
		AJSONObject.Free;
		AJSONObject := nil;
		JSONArray := nil;
	end;

end;

destructor TCompletions.Destroy;
begin
	FStop := nil;
	FUserParameters.Free;
	inherited;
end;

end.
