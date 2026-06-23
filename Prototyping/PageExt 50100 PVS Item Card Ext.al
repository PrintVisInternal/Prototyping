pageextension 50100 "PVS Item Card Ext" extends "Item Card"
{
    layout
    {
        addafter("PVS ECO Label Code")
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
