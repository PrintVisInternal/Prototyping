table 50101 "CK Mix Header"
{
    Caption = 'Color Kitchen Mix Header';
    DataClassification = CustomerContent;
    LookupPageId = "CK Page";
    DrillDownPageId = "CK Page";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "PVS Case No."; Integer)
        {
            Caption = 'Case No.';
        }
        field(3; "PVS Job No."; Integer)
        {
            Caption = 'Job No.';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Mixed Ink Item No.';
            TableRelation = Item;
            NotBlank = true;

            trigger OnValidate()
            var
                MixedInkItem: Record Item;
            begin
                if MixedInkItem.Get(Rec."Item No.") then begin
                    Rec."Item Description" := MixedInkItem.Description;
                    Rec."Unit of Measure Code" := MixedInkItem."Base Unit of Measure";
                end else begin
                    Rec."Item Description" := '';
                    Rec."Unit of Measure Code" := '';
                end;
            end;
        }
        field(5; "Item Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Quantity to Mix"; Decimal)
        {
            Caption = 'Quantity to Mix';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(7; "Quantity Mixed"; Decimal)
        {
            Caption = 'Quantity Mixed';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(8; Status; Enum "CK Mix Status")
        {
            Caption = 'Status';
        }
        field(9; "LOT No."; Code[50])
        {
            Caption = 'LOT No.';
        }
        field(10; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(12; "Eco Label Codes"; Text[250])
        {
            Caption = 'Eco Labels';
        }
        field(13; Notes; Text[250])
        {
            Caption = 'Notes';
        }
        field(14; "Quantity in Stock"; Decimal)
        {
            Caption = 'Quantity in Stock';
            FieldClass = FlowField;
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("Item No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K2; "PVS Case No.", "PVS Job No.", "Item No.")
        {
        }
    }

    trigger OnInsert()
    begin
        Rec."Created At" := CurrentDateTime();
    end;
}
