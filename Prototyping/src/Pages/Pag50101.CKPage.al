page 50101 "CK Page"
{
    Caption = 'Color Kitchen';
    PageType = List;
    SourceTable = "CK Mix Header";
    UsageCategory = None;
    CardPageId = "CK Mixing Card";

    layout
    {
        area(Content)
        {
            repeater(MixJobs)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mixed ink item to be produced.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the mixed ink.';
                }
                field("Quantity to Mix"; Rec."Quantity to Mix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the planned quantity of mixed ink needed.';
                }
                field("Quantity Mixed"; Rec."Quantity Mixed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual quantity of mixed ink that has been produced.';
                }
                field("Quantity in Stock"; Rec."Quantity in Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the current inventory level of this mixed ink item.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure.';
                }
                field("Eco Label Codes"; Rec."Eco Label Codes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the eco/food-safe certifications required for this ink (e.g. FSC, food-safe).';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the current mixing status.';
                }
                field("LOT No."; Rec."LOT No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the LOT number assigned to the produced mixed ink.';
                }
                field("PVS Case No."; Rec."PVS Case No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the PrintVis Case number this mixing job belongs to.';
                    Visible = false;
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies when this mixing job was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenMixingCard)
            {
                Caption = 'Open Mixing Card';
                ApplicationArea = All;
                Image = Navigate;
                ShortCutKey = 'Return';
                ToolTip = 'Opens the mixing card for the selected ink to scan LOT numbers, adjust quantities and post consumption.';

                trigger OnAction()
                begin
                    Page.Run(Page::"CK Mixing Card", Rec);
                end;
            }
            action(StartAllMixing)
            {
                Caption = 'Start Mixing (Selected)';
                ApplicationArea = All;
                Image = Start;
                ToolTip = 'Sets the selected mixing jobs to In Progress and loads recipe lines if not yet done.';

                trigger OnAction()
                var
                    SelectedHeader: Record "CK Mix Header";
                    CKMgt: Codeunit "CK Management";
                    MixLine: Record "CK Mix Line";
                    Counter: Integer;
                begin
                    CurrPage.SetSelectionFilter(SelectedHeader);
                    if not SelectedHeader.FindSet(true) then
                        exit;
                    repeat
                        if SelectedHeader.Status = "CK Mix Status"::"Not Started" then begin
                            MixLine.SetRange("Mix Header Entry No.", SelectedHeader."Entry No.");
                            if MixLine.IsEmpty() then
                                CKMgt.LoadRecipeLines(SelectedHeader."Entry No.");
                            SelectedHeader.Validate(Status, "CK Mix Status"::"In Progress");
                            SelectedHeader.Modify(true);
                            Counter += 1;
                        end;
                    until SelectedHeader.Next() = 0;
                    if Counter > 0 then
                        Message('%1 mixing job(s) started.', Counter);
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
                ToolTip = 'Prints the full list of base components required for the selected mixed inks, including LOT numbers and shelf locations.';

                trigger OnAction()
                var
                    SelectedHeader: Record "CK Mix Header";
                begin
                    CurrPage.SetSelectionFilter(SelectedHeader);
                    Report.RunModal(Report::"CK Component List", true, false, SelectedHeader);
                end;
            }
            action(PrintLOTLabels)
            {
                Caption = 'Print LOT Labels';
                ApplicationArea = All;
                Image = BarCode;
                ToolTip = 'Prints LOT labels for the selected completed mixed inks.';

                trigger OnAction()
                var
                    SelectedHeader: Record "CK Mix Header";
                begin
                    CurrPage.SetSelectionFilter(SelectedHeader);
                    Report.RunModal(Report::"CK LOT Label", true, false, SelectedHeader);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyle := GetStatusStyle();
    end;

    var
        StatusStyle: Text;

    local procedure GetStatusStyle(): Text
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
