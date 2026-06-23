tableextension 50100 "PV Item Ext" extends Item
{
    fields
    {
        field(50100; "FSC License No."; Code[20])
        {
            Caption = 'FSC License No.';
            DataClassification = CustomerContent;
            TableRelation = "FSC License".Code;
        }
    }
}
