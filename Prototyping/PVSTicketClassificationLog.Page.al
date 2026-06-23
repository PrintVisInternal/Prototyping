/// <summary>
/// Displays the log of all AI-classified support tickets.
/// </summary>
page 50111 "PVS Ticket Classification Log"
{
    PageType = List;
    Caption = 'Ticket Classification Log';
    ApplicationArea = All;
    SourceTable = "PVS Ticket Classification";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(LogLines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The sequential log entry number.';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    StyleExpr = CategoryStyle;
                    ToolTip = 'The ticket category assigned by the AI classifier.';
                }
                field(Confidence; Rec.Confidence)
                {
                    ApplicationArea = All;
                    Caption = 'Confidence (%)';
                    ToolTip = 'How confident the AI was in the classification (0–100).';
                }
                field(Rationale; Rec.Rationale)
                {
                    ApplicationArea = All;
                    ToolTip = 'Brief explanation of why the AI chose this category.';
                }
                field("Suggested Action"; Rec."Suggested Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Recommended next step for this ticket.';
                }
                field("Classified At"; Rec."Classified At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date and time when the ticket was classified.';
                }
                field("Classified By"; Rec."Classified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'The user who classified the ticket.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenClassifier)
            {
                ApplicationArea = All;
                Caption = 'Open Classifier';
                Image = Sparkle;
                ToolTip = 'Open the ticket classifier to classify a new support ticket.';

                trigger OnAction()
                begin
                    Page.RunModal(Page::"PVS Ticket Classifier");
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenClassifier_Promoted; OpenClassifier) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateCategoryStyle();
    end;

    local procedure UpdateCategoryStyle()
    var
        TicketClassifierAI: Codeunit "PVS Ticket Classifier AI";
    begin
        CategoryStyle := TicketClassifierAI.GetCategoryStyle(Rec.Category);
    end;

    var
        CategoryStyle: Text;
}
