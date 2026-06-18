pageextension 50101 "PVS Case List Ext" extends "PVS Case List"
{
    layout
    {
        addlast(content)
        {
            field("Quoted Price"; Rec."Quoted Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total quoted price of all active job lines with status Quote.';
            }
            field("Ordered Price"; Rec."Ordered Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total quoted price of all active job lines with status Order.';
            }
        }
    }
}
