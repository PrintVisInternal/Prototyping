tableextension 50100 "PVS Item Ext" extends Item
{
    fields
    {
        field(50100; "PVS FSC License No."; Code[20])
        {
            Caption = 'FSC License No.';
            DataClassification = CustomerContent;
            TableRelation = "PVS FSC License";
        }
    }
}
