(*
  (C)2021-2023 Magno Lima - www.MagnumLabs.com.br - Version 1.0

  Delphi libraries for using OpenAI's GPT-3 api

  This library is licensed under Creative Commons CC-0 (aka CC Zero),
  which means that this a public dedication tool, which allows creators to
  give up their copyright and put their works into the worldwide public domain.
  You're allowed to distribute, remix, adapt, and build upon the material
  in any medium or format, with no conditions.

  Feel free if there's anything you want to contribute.
*)
{$DEFINE USE_ALL_ENGINES}
unit MLOpenAi.Types;

interface

const
   OAI_ENDPOINT = 'https://api.openai.com/v1';
   OAI_GET_ENGINES = '/engines';
   OAI_GET_COMPLETION = '/completions';
   OAI_GET_CHAT = '/chat/completions';
   OAI_SEARCH = '/search';
   OAI_CLASSIFICATIONS = '/classifications';
   OAI_ANSWER = '/answers';
   OAI_FILES = '/files';
   OAI_FINETUNES = '/fine-tunes';
   OAI_IMAGES = '/images/generations';
   TFilePurposeName: TArray<String> = ['answer', 'search', 'classification', 'finetune'];
   TOAI_CHAT_MODEL: TArray<String> = ['gpt-3.5-turbo', 'gpt-3.5-turbo-0301'];
{$IFDEF USE_ALL_ENGINES}
   TOAIEngineName: TArray<String> = ['gpt-3.5-turbo', 'text-davinci-003', 'text-davinci-002', 'code-davinci-002', 'text-davinci-001',
     'text-curie-001', 'text-babbage-001', 'text-ada-001'];
{$ELSE}
   TOAIEngineName: TArray<String> = ['gpt-3.5-turbo', 'text-davinci-003', 'text-davinci-002', 'code-davinci-002'];
{$ENDIF}

type
{$IFDEF USE_ALL_ENGINES}
   TOAIEngine = (egGPT3_5Turbo = 0, egTextDavinci003 = 1, egTextDavinci002 = 2, egCodeDavinci002 = 3, egTextDavinci001 = 4,
     egTextCurie001 = 5, egTextBabbage001 = 6, egTextAda001 = 7);
{$ELSE}
   TOAIEngine = (egGPT3_5Turbo = 0, egTextDavinci003 = 1, egTextDavinci002 = 2, egCodeDavinci002 = 3);
{$ENDIF}
   TOAChatModel = (cmGPT3_5Turbo = 0, cmGPT3_5Turbo_0301 = 1);

   TOAIEngineHelper = record Helper for TOAIEngine
      function ToString: string;
   end;

   TOAIRequests = (orNone, rAuth, orEngines, orCompletions, orSearch, rClassifications, orAnswers, orFiles, orFinetunes, orImages, orChat);
   TFilePurpose = (fpAnswer = 0, fpSearch = 1, fpClassification = 2, fpFineTune = 3);

   TFileDescription = record
      Id: Integer;
      Filename: String;
      Purpose: TFilePurpose;
   end;

implementation

{ TOAIEngineHelper }

function TOAIEngineHelper.ToString: string;
begin
   Result := TOAIEngineName[ord(Self)];
end;

end.
