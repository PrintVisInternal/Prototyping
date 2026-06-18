pageextension 50100 "PVS Case List" extends "PVS Case List"
{
    layout
    {
        addlast(Control1)
        {
            field("Quoted Price"; QuotedPrice)
            {
                ApplicationArea = All;
                Caption = 'Quoted Price';
                Editable = false;
                ToolTip = 'Shows the total amount for active PrintVis job lines with status Quote for the current case.';
            }
            field("Ordered Price"; OrderedPrice)
            {
                ApplicationArea = All;
                Caption = 'Ordered Price';
                Editable = false;
                ToolTip = 'Shows the total amount for active PrintVis job lines with status Order for the current case.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        QuotedPrice := GetPriceForStatus(false);
        OrderedPrice := GetPriceForStatus(true);
    end;

    local procedure GetPriceForStatus(IsOrder: Boolean): Decimal
    var
        PVSJobLine: Record "PVS Job Line";
    begin
        PVSJobLine.SetRange(ID, Rec.ID);
        PVSJobLine.SetRange(Active, true);
        if IsOrder then
            PVSJobLine.SetRange(Status, PVSJobLine.Status::Order)
        else
            PVSJobLine.SetRange(Status, PVSJobLine.Status::Quote);

        PVSJobLine.CalcSums(Amount);

        exit(PVSJobLine.Amount);
    end;

    var
        QuotedPrice: Decimal;
        OrderedPrice: Decimal;
}
