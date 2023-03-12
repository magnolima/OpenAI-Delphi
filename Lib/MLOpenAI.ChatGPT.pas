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
   System.SysUtils, System.Generics.Collections, System.Classes, REST.Client, REST.Types,
   System.JSON, MLOpenAI.Types;

type
   TMessageRole = (mrSystem, mrUser, mrAssistant);

type
   TChatGPT = class
   private
      FModel: TOAChatModel;
      FMaxTokens: Integer;
      FSamplingTemperature: Single;
      FTopP: Single;
      FNumberOfCompletions: Integer;
      FStream: Boolean;
      FStop: TArray<String>;
      FFrequencyPenalty: Single;
      FPresencePenalty: Single;
      FMessages: TStringList;
      FUser: String;
      procedure SetMaxTokens(const Value: Integer);
      procedure SetModel(const Value: TOAChatModel);
      procedure SetSamplingTemperature(const Value: Single);
      procedure SetNucleusSampling(const Value: Single);
      procedure SetNumberOfCompletions(const Value: Integer);
      procedure SetStop(const Value: TArray<String>);
      procedure SetPresencePenalty(const Value: Single);
      procedure SetFrequencyPenalty(const Value: Single);
      procedure SetUser(const Value: String);
   public
      constructor Create(AEngine: TOAIEngine);
      destructor Destroy; override;
      procedure AddMessage(const Text: String; const Role: TMessageRole);
      procedure ClearMessages;
      procedure CreateChat(var ABody: String);
      property Model: TOAChatModel write SetModel;
      property MaxTokens: Integer read FMaxTokens write SetMaxTokens;
      property Temperature: Single read FSamplingTemperature write SetSamplingTemperature;
      property TopP: Single read FTopP write SetNucleusSampling;
      property NumberOfCompletions: Integer read FNumberOfCompletions write SetNumberOfCompletions;
      property Stream: Boolean read FStream write FStream;
      property Stop: TArray<String> read FStop write SetStop;
      property FrequencyPenalty: Single read FFrequencyPenalty write SetFrequencyPenalty;
      property PresencePenalty: Single read FPresencePenalty write SetPresencePenalty;
      property User: String read FUser write SetUser;
      property Messages: TStringList read FMessages;
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

procedure TChatGPT.SetModel(const Value: TOAChatModel);
begin
   FModel := Value;
end;

procedure TChatGPT.SetFrequencyPenalty(const Value: Single);
begin
   FFrequencyPenalty := Value;
end;

procedure TChatGPT.AddMessage(const Text: string; const Role: TMessageRole);
var
   lRole: string;
   i: Integer;
begin
   case Role of
      mrSystem:
         lRole := 'system';
      mrUser:
         lRole := 'user';
      mrAssistant:
         lRole := 'assistant';
   end;
   FMessages.AddPair(lRole, Text);
end;

procedure TChatGPT.ClearMessages;
begin
   FMessages.Clear;
end;

constructor TChatGPT.Create(AEngine: TOAIEngine);
begin
   // Using OpenAI Playground's default
   Self.MaxTokens := 1024;
   Self.TopP := 1;
   Self.Temperature := 0.7;
   Self.FrequencyPenalty := 0.0;
   Self.PresencePenalty := 0.0;
   FMessages := TStringList.Create;
end;

procedure TChatGPT.CreateChat(var ABody: String);
var
   AJSONObject, AMSGObject: TJSONObject;
   JSONArray: TJSONArray;
   Stop, lMessageRole: String;
   i: Integer;
begin
   AJSONObject := TJSONObject.Create;
   AMSGObject := TJSONObject.Create;
   JSONArray := TJSONArray.Create;
   try
      AJSONObject.AddPair(TJSONPair.Create('max_tokens', TJSONNumber.Create(FMaxTokens)));

      AJSONObject.AddPair(TJSONPair.Create('temperature', TJSONNumber.Create(Trunc(FSamplingTemperature * 100) / 100)));
      AJSONObject.AddPair(TJSONPair.Create('top_p', TJSONNumber.Create(FTopP)));
      AJSONObject.AddPair(TJSONPair.Create('frequency_penalty', TJSONNumber.Create(Trunc(FFrequencyPenalty * 100) / 100)));
      AJSONObject.AddPair(TJSONPair.Create('presence_penalty', TJSONNumber.Create(Trunc(FPresencePenalty * 100) / 100)));

      AJSONObject.AddPair('model', TOAI_CHAT_MODEL[Ord(Self.FModel)]);

      for i := 0 to FMessages.Count - 1 do
      begin
         AMSGObject.AddPair('role', FMessages.KeyNames[i]);
         AMSGObject.AddPair('content', FMessages.Values[FMessages.KeyNames[i]]);
         JSONArray.Add(AMSGObject);
      end;
      AJSONObject.AddPair('messages', JSONArray);

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
   FMessages.Free;
   inherited;
end;

end.
