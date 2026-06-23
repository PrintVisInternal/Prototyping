pageextension 50101 "PVS Job Items ListPart Ext" extends "PVS Job Items ListPart"
{
    layout
    {
        addafter("Imposition Type")
        {
            field("Minimum Reel Width"; Rec."Minimum Reel Width")
            {
                ApplicationArea = All;
                Caption = 'Minimum Reel Width';
                ToolTip = 'Minimum Reel Width in mm';
            }
        }
    }
}
