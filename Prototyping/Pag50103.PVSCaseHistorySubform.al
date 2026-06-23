page 50103 "PVS Case History Subform"
{
    PageType = ListPart;
    Caption = 'Case History';
    ApplicationArea = All;
    SourceTable = "PVS Case History";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(History)
            {
                field("Case No."; Rec."Case No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The PrintVis case number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer name.';
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Case description.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order date.';
                }
                field("Quantity"; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Order quantity.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total sales amount.';
                }
                field("Turnaround Days"; Rec."Turnaround Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Days from order to due date.';
                }
                field("Copilot Assisted"; Rec."Copilot Assisted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates the case was originally created with Copilot assistance.';
                }
            }
        }
    }
}
