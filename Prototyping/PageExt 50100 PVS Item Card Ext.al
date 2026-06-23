pageextension 50100 "PVS Item Card Ext" extends "Item Card"
{
    layout
    {
        addafter(6010118)
        {
            field("PVS FSC License No."; Rec."PVS FSC License No.")
            {
                ApplicationArea = All;
                Caption = 'FSC License No.';
                ToolTip = 'Specifies the FSC license number assigned to this item.';
                LookupPageId = "PVS FSC License List";
            }
        }
    }
}
