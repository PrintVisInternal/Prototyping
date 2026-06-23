page 50100 "CK Recipe Page"
{
    Caption = 'Color Kitchen Recipe';
    PageType = List;
    SourceTable = "CK Recipe Line";
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
                }
                field("Base Component Description"; Rec."Base Component Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the base component ink.';
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight percentage of this component in the mixed ink recipe. All percentages should sum to 100.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateTotal)
            {
                Caption = 'Check Total %';
                ApplicationArea = All;
                Image = CheckRecs;
                ToolTip = 'Validates that all recipe percentages add up to 100.';

                trigger OnAction()
                var
                    RecipeLine: Record "CK Recipe Line";
                    Total: Decimal;
                    ItemFilter: Code[20];
                begin
                    ItemFilter := CopyStr(Rec.GetFilter("Item No."), 1, 20);
                    RecipeLine.SetRange("Item No.", ItemFilter);
                    if RecipeLine.FindSet() then
                        repeat
                            Total += RecipeLine.Percentage;
                        until RecipeLine.Next() = 0;

                    if Abs(Total - 100) < 0.01 then
                        Message('Recipe total is 100%%. OK.')
                    else
                        Message('Recipe total is %1%%. Components should add up to 100%%.', Total);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        ItemFilter: Code[20];
    begin
        ItemFilter := GetSingleCodeFilter();
        if ItemFilter <> '' then begin
            Rec."Item No." := ItemFilter;
            Rec."Line No." := Rec.GetNextLineNo(ItemFilter);
        end;
    end;

    local procedure GetSingleCodeFilter(): Code[20]
    var
        FilterTxt: Text;
    begin
        FilterTxt := Rec.GetFilter("Item No.");
        // Only use the filter when it represents exactly one value (no wildcards or OR)
        if (FilterTxt <> '') and (FilterTxt.IndexOf('|') = 0) and (FilterTxt.IndexOf('*') = 0) and (FilterTxt.IndexOf('&') = 0) then
            exit(CopyStr(FilterTxt, 1, 20));
        exit('');
    end;
}
