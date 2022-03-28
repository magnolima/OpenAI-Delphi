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

  https://beta.openai.com/docs/api-reference/fine-tunes/create

  *************************************************
  TODO: We can't go on until Files are ready (WIP)
  *************************************************
*)
unit MLOpenAI.Finetunes;

interface

uses
  System.SysUtils, REST.Client, REST.Types, System.JSON, MLOpenAI.Files, MLOpenAI.Types;

type
  TArrayOfSingle = Array of Single;

type
  TFinetunes = class

  private
    FTrainingFile: String;
    FValidationFile: String;
    FModel: String;
    FEpochs: Integer;
    FBatchSize: Integer;
    FNEpochs: Integer;
    FLearningRateMultiplier: Single;
    FPromptLossWeight: Single;
    FComputeClassificationMetrics: Single;
    FClassificationNClasses: Integer;
    FClassificationBetas: TArrayOfSingle;
    FClassificationPositiveClass: String;
    FSuffix: String;
    property TrainingFile: String read FTrainingFile write FTrainingFile;
    property ValidationFile: String read FValidationFile write FValidationFile;
    property Model: String read FModel write FModel;
    property NEpochs: Integer read FNEpochs write FNEpochs;
    property BatchSize: Integer read FBatchSize write FBatchSize;
    property LearningRateMultiplier: Single read FLearningRateMultiplier write FLearningRateMultiplier;
    property PromptLossWeight: Single read FPromptLossWeight write FPromptLossWeight;
    property ComputeClassificationMetrics: Single read FComputeClassificationMetrics write FComputeClassificationMetrics;
    property ClassificationNClasses: Integer read FClassificationNClasses write FClassificationNClasses;
    property ClassificationPositiveClass: String read FClassificationPositiveClass write FClassificationPositiveClass;
    property ClassificationBetas: TArrayOfSingle read FClassificationBetas write FClassificationBetas;
    property Suffix: String read FSuffix write FSuffix;
  end;

implementation

end.
