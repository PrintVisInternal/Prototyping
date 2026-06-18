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
        QuotedPrice := GetQuotedPrice();
        OrderedPrice := GetOrderedPrice();
    end;

    local procedure GetQuotedPrice(): Decimal
    var
        PVSJobLine: Record "PVS Job Line";
        TotalQuotedPrice: Decimal;
    begin
        PVSJobLine.SetRange(ID, Rec.ID);
        PVSJobLine.SetRange(Active, true);
        PVSJobLine.SetRange(Status, PVSJobLine.Status::Quote);

        if PVSJobLine.FindSet() then
            repeat
                TotalQuotedPrice += PVSJobLine.Amount;
            until PVSJobLine.Next() = 0;

        exit(TotalQuotedPrice);
    end;

    local procedure GetOrderedPrice(): Decimal
    var
        PVSJobLine: Record "PVS Job Line";
        TotalOrderedPrice: Decimal;
    begin
        PVSJobLine.SetRange(ID, Rec.ID);
        PVSJobLine.SetRange(Active, true);
        PVSJobLine.SetRange(Status, PVSJobLine.Status::Order);

        if PVSJobLine.FindSet() then
            repeat
                TotalOrderedPrice += PVSJobLine.Amount;
            until PVSJobLine.Next() = 0;

        exit(TotalOrderedPrice);
    end;

    var
        QuotedPrice: Decimal;
        OrderedPrice: Decimal;
}
