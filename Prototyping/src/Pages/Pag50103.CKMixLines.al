page 50103 "CK Mix Lines"
{
    Caption = 'Base Components';
    PageType = ListPart;
    SourceTable = "CK Mix Line";
    UsageCategory = None;
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Base Component Item No."; Rec."Base Component Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number of the base component ink.';
                    Editable = IsEditable;
                }
                field("Base Component Description"; Rec."Base Component Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the base component ink.';
                    Editable = false;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the percentage this component contributes to the mixed ink.';
                }
                field("Quantity Required"; Rec."Quantity Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated quantity of this component needed for the mix.';
                }
                field("Quantity Used"; Rec."Quantity Used")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual quantity consumed. Can be adjusted by the operator.';
                    Editable = IsEditable;
                }
                field("LOT No."; Rec."LOT No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the LOT number scanned or entered for this base component. This LOT is stored on the mixed ink for traceability.';
                    Editable = IsEditable;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shelf or bin location of this base component to help the operator locate it.';
                    Editable = IsEditable;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this component has been consumed.';
                    Editable = false;
                    StyleExpr = LineStatusStyle;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LineStatusStyle := GetLineStatusStyle();
        IsEditable := Rec.Status = "CK Mix Line Status"::Pending;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        HeaderNo: Integer;
    begin
        HeaderNo := GetSingleIntFilter();
        if HeaderNo <> 0 then begin
            Rec."Mix Header Entry No." := HeaderNo;
            Rec."Line No." := Rec.GetNextLineNo(HeaderNo);
        end;
        IsEditable := true;
    end;

    local procedure GetSingleIntFilter(): Integer
    var
        FilterTxt: Text;
        HeaderNo: Integer;
    begin
        FilterTxt := Rec.GetFilter("Mix Header Entry No.");
        // Only parse when the filter is a plain single integer (no ranges, wildcards, or OR)
        if (FilterTxt <> '') and (FilterTxt.IndexOf('|') = 0) and (FilterTxt.IndexOf('.') = 0) and (FilterTxt.IndexOf('*') = 0) then
            if Evaluate(HeaderNo, FilterTxt) then
                exit(HeaderNo);
        exit(0);
    end;

    var
        LineStatusStyle: Text;
        IsEditable: Boolean;

    local procedure GetLineStatusStyle(): Text
    begin
        case Rec.Status of
            "CK Mix Line Status"::Consumed:
                exit('Favorable');
            else
                exit('None');
        end;
    end;
}
