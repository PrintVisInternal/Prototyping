/// <summary>
/// PromptDialog page that lets a support agent paste a raw ticket description
/// and have AI classify it into a standard PrintVis ticket category.
/// </summary>
page 50110 "PVS Ticket Classifier"
{
    PageType = PromptDialog;
    Caption = 'Classify Support Ticket';
    ApplicationArea = All;
    Extensible = false;
    IsPreview = true;
    PromptMode = Prompt;

    layout
    {
        area(Prompt)
        {
            field(TicketTextField; TicketText)
            {
                ApplicationArea = All;
                Caption = 'Ticket Description';
                MultiLine = true;
                NotBlank = true;
                ToolTip = 'Paste the raw support ticket description here. The AI will classify it into a category and suggest a next action.';
            }
        }
        area(Content)
        {
            group(ResultGroup)
            {
                Caption = 'Classification Result';
                InstructionalText = 'Review the AI-generated classification below. Save to Log to record it, or Reclassify to adjust the input.';

                field(CategoryFld; Category)
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                    Editable = false;
                    StyleExpr = CategoryStyle;
                    ToolTip = 'The ticket category assigned by the AI classifier.';
                }
                field(ConfidenceFld; Confidence)
                {
                    ApplicationArea = All;
                    Caption = 'Confidence (%)';
                    Editable = false;
                    ToolTip = 'How confident the AI is in the classification (0–100).';
                }
                field(RationaleFld; Rationale)
                {
                    ApplicationArea = All;
                    Caption = 'Rationale';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'Brief explanation of why the AI chose this category.';
                }
                field(SuggestedActionFld; SuggestedAction)
                {
                    ApplicationArea = All;
                    Caption = 'Suggested Action';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'Recommended next step for this ticket.';
                }
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Classify';
                ToolTip = 'Use AI to classify the ticket description.';

                trigger OnAction()
                begin
                    RunClassify();
                end;
            }
            systemaction(Regenerate)
            {
                Caption = 'Reclassify';
                ToolTip = 'Return to input mode to edit the ticket description and classify again.';

                trigger OnAction()
                begin
                    HasClassified := false;
                    Category := Enum::"PVS Ticket Category"::Other;
                    Confidence := 0;
                    Rationale := '';
                    SuggestedAction := '';
                    CategoryStyle := '';
                    CurrPage.PromptMode := PromptMode::Prompt;
                    CurrPage.Update(false);
                end;
            }
            systemaction(OK)
            {
                Caption = 'Save to Log';
                ToolTip = 'Save this classification result to the ticket classification log.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Close without saving.';
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then begin
            if not HasClassified then
                Error('Please classify the ticket before saving to the log.');
            SaveToLog();
        end;
        exit(true);
    end;

    local procedure RunClassify()
    var
        TicketClassifierAI: Codeunit "PVS Ticket Classifier AI";
    begin
        if TicketText = '' then
            Error('Please enter a ticket description before classifying.');

        if not TicketClassifierAI.Classify(TicketText, Category, Confidence, Rationale, SuggestedAction) then
            Error('Classification failed: %1', GetLastErrorText());

        UpdateCategoryStyle();
        HasClassified := true;
        CurrPage.PromptMode := PromptMode::Content;
        CurrPage.Update(false);
    end;

    local procedure SaveToLog()
    var
        TicketClassification: Record "PVS Ticket Classification";
        OutStr: OutStream;
    begin
        TicketClassification.Init();
        TicketClassification."Ticket Text".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(TicketText);
        TicketClassification.Category := Category;
        TicketClassification.Confidence := Confidence;
        TicketClassification.Rationale := CopyStr(Rationale, 1, MaxStrLen(TicketClassification.Rationale));
        TicketClassification."Suggested Action" := CopyStr(SuggestedAction, 1, MaxStrLen(TicketClassification."Suggested Action"));
        TicketClassification."Classified At" := CurrentDateTime();
        TicketClassification."Classified By" := CopyStr(UserId(), 1, MaxStrLen(TicketClassification."Classified By"));
        TicketClassification.Insert(true);
    end;

    local procedure UpdateCategoryStyle()
    begin
        case Category of
            Enum::"PVS Ticket Category"::Issue:
                CategoryStyle := 'Unfavorable';
            Enum::"PVS Ticket Category"::EventRequest,
            Enum::"PVS Ticket Category"::Idea:
                CategoryStyle := 'Favorable';
            else
                CategoryStyle := 'Ambiguous';
        end;
    end;

    var
        TicketText: Text;
        Category: Enum "PVS Ticket Category";
        Confidence: Integer;
        Rationale: Text;
        SuggestedAction: Text;
        CategoryStyle: Text;
        HasClassified: Boolean;
}
