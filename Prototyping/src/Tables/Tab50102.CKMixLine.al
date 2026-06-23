table 50102 "CK Mix Line"
{
    Caption = 'Color Kitchen Mix Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Mix Header Entry No."; Integer)
        {
            Caption = 'Mix Header Entry No.';
            TableRelation = "CK Mix Header"."Entry No.";
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
        field(5; "LOT No."; Code[50])
        {
            Caption = 'LOT No.';
        }
        field(6; "Quantity Required"; Decimal)
        {
            Caption = 'Quantity Required';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(7; "Quantity Used"; Decimal)
        {
            Caption = 'Quantity Used';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(8; Status; Enum "CK Mix Line Status")
        {
            Caption = 'Status';
        }
        field(9; Percentage; Decimal)
        {
            Caption = 'Percentage (%)';
            DecimalPlaces = 2 : 5;
        }
        field(10; "Shelf No."; Code[20])
        {
            Caption = 'Shelf No.';
        }
    }

    keys
    {
        key(PK; "Mix Header Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure GetNextLineNo(MixHeaderEntryNo: Integer): Integer
    var
        MixLine: Record "CK Mix Line";
    begin
        MixLine.SetRange("Mix Header Entry No.", MixHeaderEntryNo);
        if MixLine.FindLast() then
            exit(MixLine."Line No." + 10000);
        exit(10000);
    end;
}
