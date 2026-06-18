pageextension 50101 "PVS Case List Ext. Pricing" extends "PVS Case List"
{
    layout
    {
        addlast(Control1)
        {
            field("Quoted Price"; Rec."Quoted Price")
            {
                ApplicationArea = All;
                Caption = 'Quoted Price';
                ToolTip = 'Specifies the sum of active PVS Job prices for this case where the status is Quote.';
            }
            field("Ordered Price"; Rec."Ordered Price")
            {
                ApplicationArea = All;
                Caption = 'Ordered Price';
                ToolTip = 'Specifies the sum of active PVS Job prices for this case where the status is Order.';
            }
        }
    }
}
