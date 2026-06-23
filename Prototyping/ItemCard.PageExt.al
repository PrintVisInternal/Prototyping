pageextension 50100 "PV Item Card Ext" extends "Item Card"
{
    layout
    {
        addlast("PrintVis General")
        {
            field("FSC License No."; Rec."FSC License No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the FSC license number for the item.';
            }
        }
    }
}
