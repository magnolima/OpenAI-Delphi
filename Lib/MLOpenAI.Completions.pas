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

  https://beta.openai.com/docs/api-reference/completions/create
*)

unit MLOpenAI.Completions;

interface

uses
   System.StrUtils;

type
   TCompletions = class

   private
      FPrompt: String;
      FMaxTokens: Integer;
      FSamplingTemperature: Single;
      FNucleusSampling: Single;
      FNumberOfCompletions: Integer;
      FLogProbabilities: Integer;
      FEcho: Boolean;
      FStop: TArray<String>;
      FPresencePenalty: Integer;
      FBestOf: Integer;
      procedure SetMaxTokens(const Value: Integer);
      procedure SetPrompt(const Value: String);
      procedure SetSamplingTemperature(const Value: Single);
      procedure SetNucleusSampling(const Value: Single);
      procedure SetNumberOfCompletions(const Value: Integer);
      procedure SetLogProbabilities(const Value: Integer);
      procedure SetEcho(const Value: Boolean);
      procedure SetStop(const Value: TArray<String>);
      procedure SetPresencePenalty(const Value: Integer);
      procedure SetBestOf(const Value: Integer);
   public
      property Prompt: String write SetPrompt;
      property MaxTokens: Integer write SetMaxTokens;
      property SamplingTemperature: Single write SetSamplingTemperature;
      property NucleusSampling: Single write SetNucleusSampling;
      property NumberOfCompletions: Integer write SetNumberOfCompletions;
      property LogProbabilities: Integer write SetLogProbabilities;
      property Echo: Boolean write SetEcho;
      property Stop: TArray<String> write SetStop;
      property PresencePenalty: Integer write SetPresencePenalty;
      property BestOf: Integer write SetBestOf;
   end;

implementation

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
   FNucleusSampling := Value;
end;

// n integer Optional Defaults to 1
procedure TCompletions.SetNumberOfCompletions(const Value: Integer);
begin
   FNumberOfCompletions := Value;
end;

// stream boolean Optional Defaults to <|endoftext|>
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

// presence_penalty number Optional Defaults to 0
procedure TCompletions.SetPresencePenalty(const Value: Integer);
begin
   FPresencePenalty := Value;
end;

// best_of integer Optional Defaults to 1
procedure TCompletions.SetBestOf(const Value: Integer);
begin
   FBestOf := Value;
end;

end.
