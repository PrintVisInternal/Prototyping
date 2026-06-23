/// <summary>
/// AI classification engine for PrintVis support tickets.
/// Calls Azure OpenAI via the BC Copilot toolkit to categorize a raw ticket description
/// and return a confidence score, rationale, and suggested next action.
/// </summary>
codeunit 50110 "PVS Ticket Classifier AI"
{
    Access = Public;

    /// <summary>
    /// Classifies the supplied ticket text using Azure OpenAI.
    /// Returns FALSE (and surfaces the error via GetLastErrorText) if the call fails.
    /// </summary>
    [TryFunction]
    procedure Classify(TicketText: Text; var Category: Enum "PVS Ticket Category"; var Confidence: Integer; var Rationale: Text; var SuggestedAction: Text)
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"PVS Ticket Classifier") then
            Error('The PVS Ticket Classifier Copilot capability is not enabled. Please enable it in Copilot & AI capabilities.');

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"PVS Ticket Classifier");

        AOAIChatCompletionParams.SetMaxTokens(500);
        AOAIChatCompletionParams.SetTemperature(0.2);

        AOAIChatMessages.AddSystemMessage(GetSystemPrompt());
        AOAIChatMessages.AddUserMessage(TicketText);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then
            Error('AI classification failed: %1', AOAIOperationResponse.GetError());

        ParseResponse(AOAIChatMessages.GetLastMessage(), Category, Confidence, Rationale, SuggestedAction);
    end;

    local procedure GetSystemPrompt(): Text
    var
        NL: Text[2];
        TypeHelper: Codeunit "Type Helper";
    begin
        NL := TypeHelper.NewLine();
        exit(
            'You are a PrintVis support classification assistant.' + NL +
            'Given a raw support ticket description, classify it into exactly one of the following categories:' + NL +
            '  "Issue"             - Something that used to work or should work but does not.' + NL +
            '  "How To"            - Customer needs guidance on how to use an existing feature.' + NL +
            '  "Event Request"     - Request for a new BC event/publisher to be added to PrintVis.' + NL +
            '  "Idea"              - New functionality that does not exist yet.' + NL +
            '  "License"           - License activation, seat counts, expiry, or entitlement questions.' + NL +
            '  "BC-Related"        - Problem is in standard Business Central, not PrintVis-specific.' + NL +
            '  "Technical Question"- Developer/partner asking about internals, API, or architecture.' + NL +
            '  "Resource Request"  - Request for documentation, training material, or sample code.' + NL +
            '  "Other"             - Does not fit the above; needs manual review.' + NL +
            NL +
            'Respond ONLY with valid JSON in this exact format (no markdown, no extra text):' + NL +
            '{' + NL +
            '  "category": "<one of the category names above>",  ' + NL +
            '  "confidence": <integer 0-100>,' + NL +
            '  "rationale": "<one or two sentences explaining the classification>",' + NL +
            '  "suggested_action": "<one sentence describing the recommended next step>"' + NL +
            '}'
        );
    end;

    local procedure ParseResponse(ResponseText: Text; var Category: Enum "PVS Ticket Category"; var Confidence: Integer; var Rationale: Text; var SuggestedAction: Text)
    var
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        CleanedResponse: Text;
        StartPos: Integer;
        EndPos: Integer;
    begin
        StartPos := ResponseText.IndexOf('{');
        EndPos := ResponseText.LastIndexOf('}');
        if (StartPos > 0) and (EndPos > StartPos) then
            CleanedResponse := ResponseText.Substring(StartPos, EndPos - StartPos + 1)
        else
            CleanedResponse := ResponseText;

        if not JsonObj.ReadFrom(CleanedResponse) then
            Error('Could not parse AI response as JSON. Response: %1', ResponseText);

        if JsonObj.Get('category', JsonTok) then
            Category := ParseCategory(JsonTok.AsValue().AsText());

        if JsonObj.Get('confidence', JsonTok) then begin
            Confidence := JsonTok.AsValue().AsInteger();
            if Confidence < 0 then
                Confidence := 0;
            if Confidence > 100 then
                Confidence := 100;
        end;

        if JsonObj.Get('rationale', JsonTok) then
            Rationale := JsonTok.AsValue().AsText();

        if JsonObj.Get('suggested_action', JsonTok) then
            SuggestedAction := JsonTok.AsValue().AsText();
    end;

    /// <summary>
    /// Returns the StyleExpr value for a given ticket category, used for consistent
    /// color-coding across pages without duplicating the mapping logic.
    /// </summary>
    procedure GetCategoryStyle(Category: Enum "PVS Ticket Category"): Text
    begin
        case Category of
            Enum::"PVS Ticket Category"::Issue:
                exit('Unfavorable');
            Enum::"PVS Ticket Category"::EventRequest,
            Enum::"PVS Ticket Category"::Idea:
                exit('Favorable');
            else
                exit('Ambiguous');
        end;
    end;

    local procedure ParseCategory(CategoryText: Text): Enum "PVS Ticket Category"
    begin
        // Compare lower-cased to handle any AI response capitalization variations
        case LowerCase(CategoryText) of
            'issue':
                exit(Enum::"PVS Ticket Category"::Issue);
            'how to':
                exit(Enum::"PVS Ticket Category"::HowTo);
            'event request':
                exit(Enum::"PVS Ticket Category"::EventRequest);
            'idea':
                exit(Enum::"PVS Ticket Category"::Idea);
            'license':
                exit(Enum::"PVS Ticket Category"::License);
            'bc-related':
                exit(Enum::"PVS Ticket Category"::BCRelated);
            'technical question':
                exit(Enum::"PVS Ticket Category"::TechnicalQuestion);
            'resource request':
                exit(Enum::"PVS Ticket Category"::ResourceRequest);
            else
                exit(Enum::"PVS Ticket Category"::Other);
        end;
    end;
}
