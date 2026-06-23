// Extends the PrintVis Shop Floor Electronic Ticket page (6010731).
// Adds the Color Kitchen button to the header so the mixing station operator
// can open the Color Kitchen directly from their active job ticket.
//
// NOTE: The field names "Case No." and "Job No." used below reflect the typical
// PrintVis Job Sheet structure. Verify these field names match your PrintVis version
// and adjust if required before compiling.
pageextension 50101 "CK SF Electronic Ticket Ext" extends "PVS SF Electronic Ticket"
{
    actions
    {
        addlast(Processing)
        {
            action(ColorKitchen)
            {
                Caption = 'Color Kitchen';
                ApplicationArea = All;
                Image = ResourcePlanning;
                ToolTip = 'Opens the Color Kitchen for this job. Mix inks, scan LOT numbers and put mixed ink into stock.';

                trigger OnAction()
                var
                    MixHeader: Record "CK Mix Header";
                    CaseNo: Integer;
                    JobNo: Integer;
                begin
                    // Retrieve the PrintVis Case and Job numbers from the current record.
                    // Adjust the field names below if they differ in your PrintVis installation.
                    CaseNo := Rec."Case No.";
                    JobNo := Rec."Job No.";

                    MixHeader.SetRange("PVS Case No.", CaseNo);
                    MixHeader.SetRange("PVS Job No.", JobNo);
                    Page.Run(Page::"CK Page", MixHeader);
                end;
            }
        }
    }
}
