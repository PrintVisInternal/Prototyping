/// <summary>
/// Extends the PrintVis Case Card with a Copilot action that opens the AI case generation dialog.
/// NOTE: If the base page name differs from "PVS Case Card" in your environment, update the
///       extends clause accordingly.
/// </summary>
pageextension 50100 "PVS Case Card Ext" extends "PVS Case Card"
{
    actions
    {
        addlast(Processing)
        {
            action(NewCaseWithCopilot)
            {
                ApplicationArea = All;
                Caption = 'New Case with Copilot';
                ToolTip = 'Use AI to draft a new case based on historical patterns and your description.';
                Image = Sparkle;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CopilotDialog: Page "PVS Copilot Case Dialog";
                    CopilotCaseGen: Codeunit "PVS Copilot Case Gen";
                    JobTypeCode: Code[20];
                    CustomerNo: Code[20];
                    Description: Text[200];
                    MaterialCode: Code[20];
                    Quantity: Decimal;
                    TurnaroundDays: Integer;
                begin
                    if CopilotDialog.RunModal() = Action::OK then begin
                        CopilotDialog.GetSuggestedValues(
                            JobTypeCode, CustomerNo, Description, MaterialCode, Quantity, TurnaroundDays);
                        CopilotCaseGen.CreateCaseFromSuggestion(
                            JobTypeCode, CustomerNo, Description, MaterialCode, Quantity, TurnaroundDays);
                    end;
                end;
            }
        }
    }
}
