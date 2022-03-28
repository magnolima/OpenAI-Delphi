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
*)

unit MLOpenAi.Types;

interface

const
  OAI_GET_ENGINES = '/engines';
  OAI_GET_COMPLETION = '/completions';
  OAI_SEARCH = '/search';
  OAI_CLASSIFICATIONS = '/classifications';
  OAI_ANSWER = '/answers';
  OAI_FILES = '/files';
  OAI_FINETUNES = '/fine-tunes';
  TOAIEngineName: TArray<String> = ['text-davinci-002', 'text-davinci-001', 'text-curie-001', 'text-babbage-001', 'text-ada-001', 'davinci',
    'curie', 'babbage', 'ada'];


type
  TOAIEngine = (egTextDavinci002, egTextDavinci001, egTextCurie001, egTextBabbage001, egTextAda001, egDavinci, egCurie, egBabbage, egAda);
  TOAIRequests = (orNone, rAuth, orEngines, orCompletions, orSearch, rClassifications, orAnswers, orFiles, orFinetunes);
  TFilePurpose = (fpAnswer, fpSearch, fpClassification, fpFineTune);

implementation

end.
