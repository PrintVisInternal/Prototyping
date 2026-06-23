table 50100 "CK Recipe Line"
{
    Caption = 'Color Kitchen Recipe Line';
    DataClassification = CustomerContent;
    LookupPageId = "CK Recipe Page";
    DrillDownPageId = "CK Recipe Page";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Base Component Item No."; Code[20])
        {
            Caption = 'Base Component Item No.';
            TableRelation = Item;
            NotBlank = true;

            trigger OnValidate()
            var
                ComponentItem: Record Item;
            begin
                if ComponentItem.Get(Rec."Base Component Item No.") then
                    Rec."Base Component Description" := ComponentItem.Description
                else
                    Rec."Base Component Description" := '';
            end;
        }
        field(4; "Base Component Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(5; Percentage; Decimal)
        {
            Caption = 'Percentage (%)';
            DecimalPlaces = 2 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
    }

    keys
    {
        key(PK; "Item No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure GetNextLineNo(ItemNo: Code[20]): Integer
    var
        RecipeLine: Record "CK Recipe Line";
    begin
        RecipeLine.SetRange("Item No.", ItemNo);
        if RecipeLine.FindLast() then
            exit(RecipeLine."Line No." + 10000);
        exit(10000);
    end;
}
