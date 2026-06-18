pageextension 50101 "PVS Case List Ext. Pricing" extends "PVS Case List"
{
    layout
    {
        addlast(Content)
        {
            field("Quoted Price"; Rec."Quoted Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sum of active PVS Job prices for this case where the status is Quote.';
            }
            field("Ordered Price"; Rec."Ordered Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sum of active PVS Job prices for this case where the status is Order.';
            }
        }
    }
}
