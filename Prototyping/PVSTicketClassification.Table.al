/// <summary>
/// Stores the log of AI-classified support tickets.
/// </summary>
table 50110 "PVS Ticket Classification"
{
    Caption = 'PVS Ticket Classification';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Ticket Text"; Blob)
        {
            Caption = 'Ticket Text';
            DataClassification = CustomerContent;
        }
        field(3; Category; Enum "PVS Ticket Category")
        {
            Caption = 'Category';
        }
        field(4; Confidence; Integer)
        {
            Caption = 'Confidence';
            MinValue = 0;
            MaxValue = 100;
        }
        field(5; Rationale; Text[2048])
        {
            Caption = 'Rationale';
        }
        field(6; "Suggested Action"; Text[1024])
        {
            Caption = 'Suggested Action';
        }
        field(7; "Classified At"; DateTime)
        {
            Caption = 'Classified At';
        }
        field(8; "Classified By"; Code[50])
        {
            Caption = 'Classified By';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
