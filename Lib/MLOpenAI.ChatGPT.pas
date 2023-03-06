(*
  (C)2021-2023 Magno Lima - www.MagnumLabs.com.br - Version 1.0

  Delphi libraries for using OpenAI's GPT-3 api

  This library is licensed under Creative Commons CC-0 (aka CC Zero),
  which means that this a public dedication tool, which allows creators to
  give up their copyright and put their works into the worldwide public domain.
  You're allowed to distribute, remix, adapt, and build upon the material
  in any medium or format, with no conditions.

  Feel free if there's anything you want to contribute.

  https://platform.openai.com/docs/api-reference/chat
*)

unit MLOpenAI.ChatGPT;

interface

uses
   System.SysUtils, System.Generics.Collections, REST.Client, REST.Types,
   System.JSON, MLOpenAI.Types;

type
   TChatGPT = class
   private
      FModel: TOAChatModel;
      FUserRole, FMessages: String;
      FMaxTokens: Integer;
      FSamplingTemperature: Single;
      FTopP: Single;
      FNumberOfCompletions: Integer;
      FStream: Boolean;
      FStop: TArray<String>;
      FFrequencyPenalty: Single;
      FPresencePenalty: Single;
      FUser: String;
      FUserParameters: TDictionary<String, String>;
      procedure SetMaxTokens(const Value: Integer);
      procedure SetModel(const Value: TOAChatModel);
      procedure SetMessages(const Value: String);
      procedure SetSamplingTemperature(const Value: Single);
      procedure SetNucleusSampling(const Value: Single);
      procedure SetNumberOfCompletions(const Value: Integer);
      procedure SetStop(const Value: TArray<String>);
      procedure SetPresencePenalty(const Value: Single);
      procedure SetFrequencyPenalty(const Value: Single);
      procedure SetUser(const Value: String);
      procedure SetUserRole(const Value: String);
   public
      constructor Create(AEngine: TOAIEngine);
      destructor Destroy; override;
      property Model: TOAChatModel write SetModel;
      property Messages: String read FMessages write SetMessages;
      property MaxTokens: Integer read FMaxTokens write SetMaxTokens;
      property Temperature: Single read FSamplingTemperature write SetSamplingTemperature;
      property TopP: Single read FTopP write SetNucleusSampling;
      property NumberOfCompletions: Integer read FNumberOfCompletions write SetNumberOfCompletions;
      property Stream: Boolean read FStream write FStream;
      property Stop: TArray<String> read FStop write SetStop;
      property FrequencyPenalty: Single read FFrequencyPenalty write SetFrequencyPenalty;
      property PresencePenalty: Single read FPresencePenalty write SetPresencePenalty;
      property User: String read FUser write SetUser;
      property UserRole: String read FUserRole write SetUserRole;
      procedure AddStringParameter(const Name: String; Value: String);
      procedure CreateChat(var ABody: String);
   end;

implementation

uses
   MLOpenAI.Core;

{ TChatGPT }

(* logit_bias and stream are not yet implemented *)

procedure TChatGPT.SetMaxTokens(const Value: Integer);
begin
   FMaxTokens := Value;
end;

procedure TChatGPT.SetNucleusSampling(const Value: Single);
begin
   FTopP := Value;
end;

procedure TChatGPT.SetNumberOfCompletions(const Value: Integer);
begin
   FNumberOfCompletions := Value;
end;

procedure TChatGPT.SetPresencePenalty(const Value: Single);
begin
   FPresencePenalty := Value;
end;

procedure TChatGPT.SetMessages(const Value: String);
begin
   FMessages := Value;
end;

procedure TChatGPT.SetSamplingTemperature(const Value: Single);
begin
   FSamplingTemperature := Value;
end;

procedure TChatGPT.SetStop(const Value: TArray<String>);
begin
   FStop := Value;
end;

procedure TChatGPT.SetUser(const Value: String);
begin
   FUser := Value;
end;

procedure TChatGPT.SetUserRole(const Value: String);
begin
   FUserRole := Value;
end;

procedure TChatGPT.SetModel(const Value: TOAChatModel);
begin
   FModel := Value;
end;

procedure TChatGPT.SetFrequencyPenalty(const Value: Single);
begin
   FFrequencyPenalty := Value;
end;

procedure TChatGPT.AddStringParameter(const Name: String; Value: String);
begin
   FUserParameters.TryAdd(Name, Value);
end;

constructor TChatGPT.Create(AEngine: TOAIEngine);
begin
   FMaxTokens := 16;
   FSamplingTemperature := 0.5;
   FNumberOfCompletions := 1;
   FUserParameters := TDictionary<string, String>.Create;
end;

procedure TChatGPT.CreateChat(var ABody: String);
var
   AJSONObject: TJSONObject;
   JSONArray: TJSONArray;
   Value, Stop: String;
begin
   AJSONObject := TJSONObject.Create;
   JSONArray := nil;
   try
      // "model": "gpt-3.5-turbo",
      // "messages": [{"role": "user", "content": "Hello!"}]

      Value := Format('[{"role": "%s", "content": "%s"}]', [FUserRole, FMessages]);

      AJSONObject.AddPair(TJSONPair.Create('model', TOAI_CHAT_MODEL[Ord(FModel)]));
      AJSONObject.AddPair(TJSONPair.Create('messages', Value));
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
            if not Stop.IsEmpty then
               JSONArray.Add(Stop);
         AJSONObject.AddPair(TJSONPair.Create('stop', JSONArray));
      end;

      if FNumberOfCompletions <> 1 then
         AJSONObject.AddPair(TJSONPair.Create('n', TJSONNumber.Create(FNumberOfCompletions)));

      ABody := UTF8ToString(AJSONObject.ToJSON);

   finally
      AJSONObject.Free;
      AJSONObject := nil;
      JSONArray := nil;
   end;

end;

destructor TChatGPT.Destroy;
begin
   FStop := nil;
   FUserParameters.Free;
   inherited;
end;

end.
