(*
  (C)2023 Magno Lima - www.MagnumLabs.com.br - Version 1.0

  Delphi libraries for using OpenAI's GPT-3 api

  This library is licensed under Creative Commons CC-0 (aka CC Zero),
  which means that this a public dedication tool, which allows creators to
  give up their copyright and put their works into the worldwide public domain.
  You're allowed to distribute, remix, adapt, and build upon the material
  in any medium or format, with no conditions.

  Feel free if there's anything you want to contribute.

  https://platform.openai.com/docs/api-reference/images

*)
unit MLOpenAI.Images;

{$DEFINE FMX}

interface

uses
	System.SysUtils, REST.Client, REST.Types, System.JSON, System.Classes,
	System.NetEncoding,
{$IFDEF FMX}
	FMX.Objects,
{$ELSE}
	Vcl.ExtCtrls,
{$IFEND}
	FMX.Surfaces, FMX.Graphics,
	MLOpenAI.Types;

type
	TDecodedImage = record
		FileName: String;
		B64Json: String;
	end;

type
	TImageSize = (is256x256, is512x512, is1024x1024);

type
	TResponseFormat = (rfUrl, rfB64Json);

type
	TImageFileName = record
		FileName: String;
		SanitizedUrl: String;
	end;

type
	TImages = class
	private
		FFileName: String;
		FPurpose: TFilePurpose;
		FFileId: String;
		FUser: String;
		FPrompt: String;
		FResponseFormat: TResponseFormat;
		FSize: TImageSize;
		FNumberOfImages: Integer;
		FImageB64Json: String;
		procedure SetFileId(const Value: String);
		procedure SetUser(const Value: String);
		procedure SetPrompt(const Value: String);
		procedure SetResponseFormat(const Value: TResponseFormat);
		procedure SetImageSize(const Value: TImageSize);
		procedure SetNumberOfImages(const Value: Integer);
		procedure SetImageB64Json(const Value: String);
		function ExtractImageMeta: TArray<TDecodedImage>;
		class procedure DecodeToFile(const ASource, AFileName: string); static;
	public
		destructor Destroy; override;
		constructor Create(AUser: String);
		property Prompt: String read FPrompt write SetPrompt;
		property NumberOfImages: Integer read FNumberOfImages write SetNumberOfImages;
		property Size: TImageSize read FSize write SetImageSize;
		property ResponseFormat: TResponseFormat read FResponseFormat write SetResponseFormat;
		property User: String read FUser write SetUser;
		property ImageB64Json: String read FImageB64Json write SetImageB64Json;
		procedure GenerateImages(var ABody: String);
		class function ExtractImageFileName(url: String): TImageFileName; static;
		function DecodeJsonToFile(const Path: String): TArray<String>;
	end;

implementation

{ TImages }

function TImages.ExtractImageMeta: TArray<TDecodedImage>;
var
	jso: TJSONObject;
	jsa: TJSONArray;
	s, Data: string;
	I: Integer;
begin
	jso := TJSONObject.ParseJSONValue(FImageB64Json) as TJSONObject;
	if jso <> nil then
		try
			s := jso.GetValue<string>('created');
			jsa := jso.GetValue('data') as TJSONArray;
			if jsa <> nil then
			begin
				if jsa.Count > 0 then
				begin
					SetLength(Result, jsa.Count);
					for I := 0 to jsa.Count - 1 do
					begin
						Result[I].FileName := Format('%s_%d.png', [s, I + 1]);
						Result[I].B64Json := jso.GetValue<string>('data[' + I.ToString + '].b64_json');
					end;

				end;
			end;
		finally
			jso.Free;
		end;
end;

class function TImages.ExtractImageFileName(url: String): TImageFileName;
var
	tmp, Value: String;
	I: Integer;
	values: TArray<string>;
begin
	tmp := StringReplace(url, '\/', '/', [rfReplaceAll]);
	Result.SanitizedUrl := tmp;

	values := tmp.Split(['?']);
	for Value in values do
	begin
		if Value.Contains('.png') then
			tmp := Value;
	end;
	I := LastDelimiter('/', tmp);

	Result.FileName := tmp.Substring(I);
end;

class procedure TImages.DecodeToFile(const ASource, AFileName: string);
var
	LStream: TMemoryStream;
	LBytes: TBytes;
begin
	LStream := TMemoryStream.Create;
	try
		LBytes := TNetEncoding.Base64.DecodeStringToBytes(ASource);
		LStream.Write(LBytes, Length(LBytes));
		LStream.SaveToFile(AFileName);
	finally
		LStream.Free;
	end;
end;

function TImages.DecodeJsonToFile(const Path: String): TArray<String>;
var
	i: integer;
	DecodedImage: TDecodedImage;
	ListDecodedImage: TArray<TDecodedImage>;
begin
	ListDecodedImage := ExtractImageMeta();
	SetLength(Result, Length(ListDecodedImage));
	i := 0;
	for DecodedImage in ListDecodedImage do
	begin
		Result[i] := Path + DecodedImage.FileName;
		DecodeToFile(DecodedImage.B64Json, Path + DecodedImage.FileName);
      inc(i);
	end;
end;

procedure TImages.SetFileId(const Value: String);
begin
	FFileId := Value;
end;

procedure TImages.SetImageB64Json(const Value: String);
begin
	FImageB64Json := Value;
end;

procedure TImages.SetImageSize(const Value: TImageSize);
begin
	FSize := Value;
end;

procedure TImages.SetNumberOfImages(const Value: Integer);
var
	lValue: Integer;
begin
	lValue := Value;
	if (Value < 0) or (Value > 10) then
		lValue := 1;
	FNumberOfImages := lValue;
end;

procedure TImages.SetPrompt(const Value: String);
begin
	if Value.Length > 1000 then
		raise Exception.Create('Prompt is limited to 1000 characters');
	FPrompt := Value;
end;

procedure TImages.SetResponseFormat(const Value: TResponseFormat);
begin
	FResponseFormat := Value;
end;

procedure TImages.SetUser(const Value: String);
begin
	FUser := Value;
end;

procedure TImages.GenerateImages(var ABody: String);
var
	AJSONObject: TJSONObject;
	JSONArray: TJSONArray;
	Value, Stop: String;

	function getSize: String;
	begin
		case FSize of
			is256x256:
				Result := '512x512';
			is512x512:
				Result := '512x512';
			is1024x1024:
				Result := '1024x1024';
		end;
	end;

begin
	AJSONObject := TJSONObject.Create;
	JSONArray := nil;
	try
		AJSONObject.AddPair(TJSONPair.Create('prompt', FPrompt));
		AJSONObject.AddPair(TJSONPair.Create('n', TJSONNumber.Create(FNumberOfImages)));
		AJSONObject.AddPair(TJSONPair.Create('size', getSize()));

		case ResponseFormat of
			rfUrl:
				AJSONObject.AddPair(TJSONPair.Create('response_format', 'url'));
			rfB64Json:
				AJSONObject.AddPair(TJSONPair.Create('response_format', 'b64_json'));
		end;

		AJSONObject.AddPair(TJSONPair.Create('user', FUser));

		ABody := UTF8ToString(AJSONObject.ToJSON);

	finally
		AJSONObject.Free;
		AJSONObject := nil;
		JSONArray := nil;
	end;

end;

constructor TImages.Create(AUser: String);
begin
	FPrompt := '';
	FNumberOfImages := 1;
	FSize := is256x256;
	FResponseFormat := TResponseFormat.rfB64Json;
	FUser := AUser;
end;

destructor TImages.Destroy;
begin
	inherited;
end;

end.
