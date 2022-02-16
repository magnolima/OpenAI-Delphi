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

unit MLOpenAI.Classifications;

interface

uses
  System.SysUtils, REST.Client, REST.Types, System.JSON;

type
  TClassifications = class
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
  public
    constructor Create(EngineIndex: Integer);
    procedure CreateClassification(var ABody: String);
  end;

implementation

uses
  MLOpenAI.Core;

{ TClassifications }


constructor TClassifications.Create(EngineIndex: Integer);
begin
  { TODO :  }
  // Set defaults
  FEngine := TOAIEngineName[EngineIndex];
  FPrompt := '';
  FMaxTokens := 16;
  FSamplingTemperature := 1;
  FNumberOfCompletions := 1;
  FLogProbabilities := 1;
  FEcho := false;
  FStop := nil;
  FPresencePenalty := 0;
  FFrequencyPenalty := 0;
  FBestOf := 1;
end;

procedure TClassifications.CreateClassification(var ABody: String);
var
  AJSONObject: TJSONObject;
  AJSONPair: TJSONPair;
  Value, Stop: String;
begin
  { TODO :  }
  AJSONObject := TJSONObject.Create;

  AJSONObject.AddPair(TJSONPair.Create('', ''));

  ABody := AJSONObject.ToJSON;
  AJSONObject.Free;

end;

end.
