pageextension 50101 "PVS Case List Ext. Pricing" extends "PVS Case List"
{
    layout
    {
        addlast(Content)
        {
            field("Quoted Price Total"; Rec."Quoted Price Total")
            {
                ApplicationArea = All;
                Caption = 'Quoted Price Total';
                ToolTip = 'Specifies the sum of PVS Job quoted prices for this case where the status is Quote.';
            }
            field("Ordered Price Total"; Rec."Ordered Price Total")
            {
                ApplicationArea = All;
                Caption = 'Ordered Price Total';
                ToolTip = 'Specifies the sum of PVS Job quoted prices for this case where the status is Order.';
            }
        }
    }
}
