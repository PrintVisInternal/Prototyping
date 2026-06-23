page 50101 "PVS Case Patterns"
{
    PageType = List;
    Caption = 'PVS Case Patterns';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PVS Case Pattern";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Patterns)
            {
                field("Job Type Code"; Rec."Job Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'The job type common to this pattern.';
                }
                field("Job Type Description"; Rec."Job Type Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of the job type.';
                }
                field("Material Code"; Rec."Material Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'The primary material associated with this pattern.';
                }
                field("Customer Segment"; Rec."Customer Segment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer posting group representing the customer segment.';
                }
                field("Case Count"; Rec."Case Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of historical cases matching this pattern.';
                }
                field("Avg Quantity"; Rec."Avg Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Average order quantity for this pattern.';
                }
                field("Avg Total Amount"; Rec."Avg Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Average total sales amount for this pattern.';
                }
                field("Min Total Amount"; Rec."Min Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Minimum total sales amount observed for this pattern.';
                }
                field("Max Total Amount"; Rec."Max Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum total sales amount observed for this pattern.';
                }
                field("Avg Turnaround Days"; Rec."Avg Turnaround Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Average number of days from order date to due date.';
                }
                field("Confidence Score"; Rec."Confidence Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Confidence score (0-100) based on the number of matching cases.';
                    StyleExpr = ConfidenceStyle;
                }
                field("Last Updated"; Rec."Last Updated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date and time this pattern was last calculated.';
                }
            }
        }
        area(FactBoxes)
        {
            part(CaseHistorySubform; "PVS Case History Subform")
            {
                ApplicationArea = All;
                Caption = 'Matching Cases';
                SubPageLink = "Job Type Code" = field("Job Type Code"),
                              "Material Code" = field("Material Code");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReanalyzePatterns)
            {
                ApplicationArea = All;
                Caption = 'Re-analyse Patterns';
                ToolTip = 'Rebuild all patterns from current case history.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    PatternAnalysis: Codeunit "PVS Pattern Analysis";
                begin
                    PatternAnalysis.AnalyzePatterns();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetConfidenceStyle();
    end;

    local procedure SetConfidenceStyle()
    begin
        if Rec."Confidence Score" >= 70 then
            ConfidenceStyle := 'Favorable'
        else if Rec."Confidence Score" >= 40 then
            ConfidenceStyle := 'Ambiguous'
        else
            ConfidenceStyle := 'Unfavorable';
    end;

    var
        ConfidenceStyle: Text;
}
