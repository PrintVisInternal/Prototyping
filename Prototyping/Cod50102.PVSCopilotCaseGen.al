/// <summary>
/// Handles AI-powered case generation using Azure OpenAI.
/// Uses historical patterns from PVS Case Pattern to enrich the prompt with context,
/// then calls the AOAI chat completions API and maps the response back to case fields.
/// </summary>
codeunit 50102 "PVS Copilot Case Gen"
{
    Access = Public;

    /// <summary>
    /// Generates a suggested case record based on the user's natural-language prompt
    /// and historical patterns. The result is stored in a temporary PVS Case History record.
    /// </summary>
    procedure GenerateCaseSuggestion(UserPrompt: Text; var SuggestedCase: Record "PVS Case History")
    var
        Setup: Record "PVS AI Case Setup";
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        SystemPrompt: Text;
        ResponseText: Text;
        ApiKey: Text;
    begin
        if not Setup.Get('DEFAULT') then
            Error('PVS AI Case Setup not found. Please configure the AI settings first.');
        if not Setup."Enable Copilot" then
            Error('Copilot is not enabled. Please enable it in PVS AI Case Setup.');
        if Setup."AOAI Endpoint" = '' then
            Error('Azure OpenAI Endpoint is not configured in PVS AI Case Setup.');
        if Setup."AOAI Deployment Name" = '' then
            Error('Azure OpenAI Deployment Name is not configured in PVS AI Case Setup.');

        GetApiKey(ApiKey);
        if ApiKey = '' then
            Error('Azure OpenAI API Key is not stored. Please enter it in PVS AI Case Setup.');

        SystemPrompt := BuildSystemPrompt(UserPrompt);

        AzureOpenAI.SetAuthorization(
            Enum::"AOAI Model Type"::"Chat Completions",
            Setup."AOAI Endpoint",
            Setup."AOAI Deployment Name",
            ApiKey);
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"PVS Case Assistant");

        AOAIChatCompletionParams.SetMaxTokens(800);
        AOAIChatCompletionParams.SetTemperature(0.3);

        AOAIChatMessages.AddSystemMessage(SystemPrompt);
        AOAIChatMessages.AddUserMessage(UserPrompt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then
            Error('Copilot generation failed: %1', AOAIOperationResponse.GetError());

        ResponseText := AOAIChatMessages.GetLastMessage();
        ParseAOAIResponse(ResponseText, SuggestedCase);
    end;

    /// <summary>
    /// Creates a new PVS Case from a Copilot suggestion and opens it for review.
    /// </summary>
    procedure CreateCaseFromSuggestion(
        JobTypeCode: Code[20];
        CustomerNo: Code[20];
        Description: Text[200];
        MaterialCode: Code[20];
        Quantity: Decimal;
        DueDays: Integer)
    var
        PVSCaseHeader: Record "PVS Case";
    begin
        PVSCaseHeader.Init();
        PVSCaseHeader."Customer No." := CustomerNo;
        PVSCaseHeader."Job Type Code" := JobTypeCode;
        PVSCaseHeader."Quantity 1" := Quantity;
        PVSCaseHeader."Order Date" := Today();
        if DueDays > 0 then
            PVSCaseHeader."Due Date" := Today() + DueDays;

        PVSCaseHeader."Copilot Assisted" := true;
        PVSCaseHeader."Copilot Assisted At" := CurrentDateTime();

        PVSCaseHeader.Insert(true);

        Page.Run(Page::"PVS Case Card", PVSCaseHeader);
    end;

    local procedure BuildSystemPrompt(UserPrompt: Text): Text
    var
        PatternContext: Text;
        SystemPromptBuilder: TextBuilder;
    begin
        PatternContext := BuildPatternContext(UserPrompt);

        SystemPromptBuilder.Append(
            'You are a PrintVis case management assistant. ' +
            'Based on the historical patterns provided and the user''s request, ' +
            'generate a new case specification.' +
            'Respond ONLY with valid JSON using this exact structure:' + NewLine() +
            '{' + NewLine() +
            '  "job_type_code": "<job type code>",  ' + NewLine() +
            '  "customer_no": "<customer number or empty string>",  ' + NewLine() +
            '  "description": "<case description>",  ' + NewLine() +
            '  "quantity": <number>,  ' + NewLine() +
            '  "material_code": "<material code or empty string>",  ' + NewLine() +
            '  "turnaround_days": <number>,  ' + NewLine() +
            '  "estimated_amount": <number>  ' + NewLine() +
            '}' + NewLine());

        if PatternContext <> '' then begin
            SystemPromptBuilder.Append(NewLine() + 'Historical patterns relevant to this request:' + NewLine());
            SystemPromptBuilder.Append(PatternContext);
        end;

        exit(SystemPromptBuilder.ToText());
    end;

    local procedure BuildPatternContext(UserPrompt: Text): Text
    var
        CasePattern: Record "PVS Case Pattern";
        ContextBuilder: TextBuilder;
        LineCount: Integer;
    begin
        // Return the top 5 patterns by confidence score as context for the AI
        CasePattern.SetCurrentKey(CasePattern."Confidence Score");
        CasePattern.Ascending(false);
        if not CasePattern.FindSet() then
            exit('');

        repeat
            ContextBuilder.Append(
                StrSubstNo(
                    '- Job Type: %1, Material: %2, Segment: %3, Avg Qty: %4, ' +
                    'Avg Amount: %5, Avg Days: %6, Cases: %7' + NewLine(),
                    CasePattern."Job Type Code",
                    CasePattern."Material Code",
                    CasePattern."Customer Segment",
                    Format(CasePattern."Avg Quantity", 0, '<Integer>'),
                    Format(CasePattern."Avg Total Amount", 0, '<Precision,2:2><Standard Format,0>'),
                    Format(CasePattern."Avg Turnaround Days", 0, '<Precision,1:1><Standard Format,0>'),
                    Format(CasePattern."Case Count")));
            LineCount += 1;
        until (CasePattern.Next() = 0) or (LineCount >= 5);

        exit(ContextBuilder.ToText());
    end;

    local procedure ParseAOAIResponse(ResponseText: Text; var SuggestedCase: Record "PVS Case History")
    var
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        CleanedResponse: Text;
        StartPos: Integer;
        EndPos: Integer;
    begin
        // Extract JSON block if the response contains surrounding text
        StartPos := ResponseText.IndexOf('{');
        EndPos := ResponseText.LastIndexOf('}');
        if (StartPos > 0) and (EndPos > StartPos) then
            CleanedResponse := ResponseText.Substring(StartPos, EndPos - StartPos + 1)
        else
            CleanedResponse := ResponseText;

        if not JsonObj.ReadFrom(CleanedResponse) then
            exit;

        SuggestedCase.Init();

        if JsonObj.Get('job_type_code', JsonTok) then
            SuggestedCase."Job Type Code" :=
                CopyStr(JsonTok.AsValue().AsText(), 1, MaxStrLen(SuggestedCase."Job Type Code"));

        if JsonObj.Get('customer_no', JsonTok) then
            SuggestedCase."Customer No." :=
                CopyStr(JsonTok.AsValue().AsText(), 1, MaxStrLen(SuggestedCase."Customer No."));

        if JsonObj.Get('description', JsonTok) then
            SuggestedCase.Description :=
                CopyStr(JsonTok.AsValue().AsText(), 1, MaxStrLen(SuggestedCase.Description));

        if JsonObj.Get('quantity', JsonTok) then
            SuggestedCase.Quantity := JsonTok.AsValue().AsDecimal();

        if JsonObj.Get('material_code', JsonTok) then
            SuggestedCase."Material Code" :=
                CopyStr(JsonTok.AsValue().AsText(), 1, MaxStrLen(SuggestedCase."Material Code"));

        if JsonObj.Get('turnaround_days', JsonTok) then
            SuggestedCase."Turnaround Days" := JsonTok.AsValue().AsInteger();

        if JsonObj.Get('estimated_amount', JsonTok) then
            SuggestedCase."Total Amount" := JsonTok.AsValue().AsDecimal();
    end;

    local procedure GetApiKey(var ApiKey: Text)
    begin
        if not IsolatedStorage.Get('PVSAOAIApiKey', DataScope::Module, ApiKey) then
            ApiKey := '';
    end;

    local procedure NewLine(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.NewLine());
    end;
}
