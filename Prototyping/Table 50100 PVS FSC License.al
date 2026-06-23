table 50100 "PVS FSC License"
{
    Caption = 'FSC License';
    DataClassification = CustomerContent;
    LookupPageId = "PVS FSC License List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
