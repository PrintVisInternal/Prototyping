page 50102 "CK Mixing Card"
{
    Caption = 'Color Kitchen – Mixing';
    PageType = Card;
    SourceTable = "CK Mix Header";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the unique identifier of this mixing job.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the mixed ink item to be produced.';
                    Editable = IsNotCompleted;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the description of the mixed ink.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the mixed ink.';
                    Editable = IsNotCompleted;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    StyleExpr = HeaderStatusStyle;
                    ToolTip = 'Specifies the current status of this mixing job.';
                }
            }
            group(Quantities)
            {
                Caption = 'Quantities';

                field("Quantity to Mix"; Rec."Quantity to Mix")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the planned quantity of mixed ink to produce.';
                    Editable = IsNotCompleted;
                }
                field("Quantity Mixed"; Rec."Quantity Mixed")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the actual quantity of mixed ink that was produced. Can differ from the planned quantity.';
                    Editable = IsNotCompleted;
                }
                field("Quantity in Stock"; Rec."Quantity in Stock")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Shows the current inventory quantity of this mixed ink item.';
                }
            }
            group(Traceability)
            {
                Caption = 'Traceability & Labels';

                field("LOT No."; Rec."LOT No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the LOT number assigned to the newly produced mixed ink batch.';
                    Editable = IsNotCompleted;
                }
                field("Eco Label Codes"; Rec."Eco Label Codes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the eco/food-safe label certifications that apply to this mixed ink (e.g. FSC, food-safe).';
                    Editable = IsNotCompleted;
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any additional notes for this mixing job.';
                    Editable = IsNotCompleted;
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies when this mixing job was created.';
                }
            }
            part(BaseComponentLines; "CK Mix Lines")
            {
                ApplicationArea = All;
                Caption = 'Base Components';
                SubPageLink = "Mix Header Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadFromRecipe)
            {
                Caption = 'Load from Recipe';
                ApplicationArea = All;
                Image = BOMVersions;
                Enabled = IsNotCompleted;
                ToolTip = 'Populates the base component lines from the Color Kitchen Recipe defined for this mixed ink item. Existing lines are replaced.';

                trigger OnAction()
                var
                    CKMgt: Codeunit "CK Management";
                begin
                    if not Confirm('Load recipe lines for %1? Existing lines will be replaced.', true, Rec."Item No.") then
                        exit;
                    CKMgt.LoadRecipeLines(Rec."Entry No.");
                    CurrPage.BaseComponentLines.Page.Update(false);
                end;
            }
            action(ConsumeComponents)
            {
                Caption = 'Consume Base Components';
                ApplicationArea = All;
                Image = PostingEntries;
                Enabled = IsInProgress;
                ToolTip = 'Posts negative inventory adjustments for all pending base component lines, recording their LOT numbers.';

                trigger OnAction()
                var
                    CKMgt: Codeunit "CK Management";
                begin
                    if not Confirm('Consume all pending base components now? This will post inventory adjustments.', true) then
                        exit;
                    CKMgt.PostConsumption(Rec."Entry No.");
                    Rec.Get(Rec."Entry No.");
                    CurrPage.Update(false);
                end;
            }
            action(CompleteMixing)
            {
                Caption = 'Complete Mixing';
                ApplicationArea = All;
                Image = Approve;
                Enabled = IsNotCompleted;
                ToolTip = 'Posts the finished mixed ink quantity to inventory and marks this mixing job as completed.';

                trigger OnAction()
                var
                    CKMgt: Codeunit "CK Management";
                begin
                    if not Confirm('Complete mixing and put %1 %2 of %3 into stock?', true,
                        Rec."Quantity Mixed", Rec."Unit of Measure Code", Rec."Item No.")
                    then
                        exit;
                    CKMgt.PostMixedInkToStock(Rec."Entry No.");
                    Rec.Get(Rec."Entry No.");
                    CurrPage.Update(false);
                end;
            }
            action(StartMixing)
            {
                Caption = 'Start Mixing';
                ApplicationArea = All;
                Image = Start;
                Enabled = IsNotStarted;
                ToolTip = 'Marks this mixing job as In Progress and loads the recipe lines if they have not already been loaded.';

                trigger OnAction()
                var
                    CKMgt: Codeunit "CK Management";
                    MixLine: Record "CK Mix Line";
                begin
                    MixLine.SetRange("Mix Header Entry No.", Rec."Entry No.");
                    if MixLine.IsEmpty() then
                        CKMgt.LoadRecipeLines(Rec."Entry No.");
                    Rec.Validate(Status, "CK Mix Status"::"In Progress");
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Reporting)
        {
            action(PrintComponentList)
            {
                Caption = 'Print Component List';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Prints the list of base components needed for this mixing job, including LOT numbers and shelf locations.';

                trigger OnAction()
                var
                    MixHeader: Record "CK Mix Header";
                begin
                    MixHeader.SetRange("Entry No.", Rec."Entry No.");
                    Report.RunModal(Report::"CK Component List", true, false, MixHeader);
                end;
            }
            action(PrintLOTLabel)
            {
                Caption = 'Print LOT Label';
                ApplicationArea = All;
                Image = BarCode;
                Enabled = HasLOTNo;
                ToolTip = 'Prints the LOT label for the newly produced mixed ink, including all base component LOT numbers for traceability.';

                trigger OnAction()
                var
                    MixHeader: Record "CK Mix Header";
                begin
                    MixHeader.SetRange("Entry No.", Rec."Entry No.");
                    Report.RunModal(Report::"CK LOT Label", true, false, MixHeader);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetPageVariables();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetPageVariables();
    end;

    var
        HeaderStatusStyle: Text;
        IsNotStarted: Boolean;
        IsInProgress: Boolean;
        IsNotCompleted: Boolean;
        HasLOTNo: Boolean;

    local procedure SetPageVariables()
    begin
        IsNotStarted := Rec.Status = "CK Mix Status"::"Not Started";
        IsInProgress := Rec.Status = "CK Mix Status"::"In Progress";
        IsNotCompleted := Rec.Status <> "CK Mix Status"::Completed;
        HasLOTNo := Rec."LOT No." <> '';
        HeaderStatusStyle := GetHeaderStatusStyle();
    end;

    local procedure GetHeaderStatusStyle(): Text
    begin
        case Rec.Status of
            "CK Mix Status"::Completed:
                exit('Favorable');
            "CK Mix Status"::"In Progress":
                exit('Ambiguous');
            else
                exit('None');
        end;
    end;
}
