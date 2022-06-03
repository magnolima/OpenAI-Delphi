# OpenAI-Delphi
**A simple wrapper for the GPT-3 OpenAI API using Delphi.**

2020-06-03 - Small fix

This library should wrapper all the API requests. All the returning data will be translated into a memory table/dataset for easly of handling.

We are going to cover the following requests:

1. Engines ✓
2. Completions ✓
3. Search
4. Classifications
5. Answers
6. Files

**IMPORTANT**: to use GPT-3 you'll need to have your own API key. Please go to https://beta.openai.com/ and request yours.

Understand that I am not an AI (even GPT-3) expert. This work was done so I could learn about. Please follow the OpenAI documentation for doubts. Eventually Not all the features/attributes could be available througout the requests.

Simple example of use:

Initialize the wrapper:
```delphi
// Store your key safely. Never share or expose it!
procedure TfrmDemoOpenAI.InitOpenAI;
begin
  OpenAIKey := TFile.ReadAllText(API_KEY);
  OpenAI := TOpenAI.Create(FDMemTable1);
  OpenAI.APIKey := OpenAIKey;
  OpenAI.Endpoint := OpenAI_PATH;
  OpenAI.Engine := TOAIEngine.egTextDavinci002;
  OpenAI.OnResponse := OnOpenAIResponse;
end;
```

Example on how to create an completion:
```pascal
procedure TfrmDemoOpenAI.CreateCompletions;
var
   Completions: TCompletions;
begin
   Completions := TCompletions.Create;
   Completions.Prompt := 'Once upon a time';
   Completions.MaxTokens := 64;
   Completions.SamplingTemperature := 1; // Default 1
   Completions.NucleusSampling := 1; // top_p
   
   // Do the job!
   OpenAI.RequestType := rCompletions;
   OpenAI.Execute;
end;
````

Quite easy, right? Well, feel free to open a push request if there's anything you want to contribute.

-----------  
This library is licensed under Creative Commons CC-0 (aka CC Zero), which means that this a public dedication tool, which allows creators to give up their copyright and put their works into the worldwide public domain. You're allowed to distribute, remix, adapt, and build upon the material in any medium or format, with no conditions.
