pageextension 50101 "PVS Case List Ext" extends "PVS Case List"
{
    layout
    {
        addlast(content)
        {
            field("Quoted Price"; Rec."Quoted Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total quoted price for all active Quote job lines on the case.';
            }
            field("Ordered Price"; Rec."Ordered Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total price for all active Order job lines on the case.';
            }
        }
    }
}
