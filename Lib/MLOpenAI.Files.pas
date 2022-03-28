(*
  (C)2022 Magno Lima - www.MagnumLabs.com.br - Version 1.0

  Delphi libraries for using OpenAI's GPT-3 api

  This library is licensed under Creative Commons CC-0 (aka CC Zero),
  which means that this a public dedication tool, which allows creators to
  give up their copyright and put their works into the worldwide public domain.
  You're allowed to distribute, remix, adapt, and build upon the material
  in any medium or format, with no conditions.

  Feel free to open a push request if there's anything you want
  to contribute.

  https://beta.openai.com/docs/api-reference/files
  //
  Ref to JSON Lines
  *******************
  WIP WIP WIP WIP WIP
  *******************
*)
unit MLOpenAI.Files;

interface

uses
  System.SysUtils, REST.Client, REST.Types, System.JSON, MLOpenAI.Types;

type
  TFiles = class
  private
    FFileName: String;
    FPurpose: TFilePurpose;
    FFileId: String;
    procedure SetFileId(const Value: String);
  public
    property FileId: String read FFileId write FFileId;
    property FileName: String read FFileName write FFilename;
    property Purpose: TFilePurpose read FPurpose write FPurpose;
    procedure UploadFile(Const FileName: String);
    procedure DeleteFile(Const FileId: String);
    function ListFiles: TJSONArray;
    function RetrieveInformation(Const FileId: String): TArray<String>;
    function RetrieveFileContent(Const FileId: String): TArray<String>;
  end;

implementation

{ TFiles }

procedure TFiles.DeleteFile(const FileId: String);
begin

end;

function TFiles.ListFiles: TJSONArray;
begin

end;

function TFiles.RetrieveFileContent(const FileId: String): TArray<String>;
begin

end;

function TFiles.RetrieveInformation(const FileId: String): TArray<String>;
begin

end;

procedure TFiles.SetFileId(const Value: String);
begin
  FFileId := Value;
end;

procedure TFiles.UploadFile(const FileName: String);
var
  AId: String;
begin
   SetFileId(AId);
end;

end.
