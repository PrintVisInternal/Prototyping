page 50100 "PVS FSC License List"
{
    Caption = 'FSC License List';
    PageType = List;
    SourceTable = "PVS FSC License";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the FSC license code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the FSC license.';
                }
            }
        }
    }
}
