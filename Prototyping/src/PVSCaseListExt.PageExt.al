pageextension 50100 "PVS Case List Ext" extends "PVS Case List"
{
    layout
    {
        addlast(Control1)
        {
            field(QuotedPriceTotal; QuotedPriceTotal)
            {
                ApplicationArea = All;
                Caption = 'Quoted Price';
                ToolTip = 'Specifies the total quoted price, calculated as the sum of all active job entries linked to this case with status Quote.';
                Editable = false;
                BlankZero = true;
            }
            field(OrderedPriceTotal; OrderedPriceTotal)
            {
                ApplicationArea = All;
                Caption = 'Ordered Price';
                ToolTip = 'Specifies the total ordered price, calculated as the sum of all active job entries linked to this case with status Order.';
                Editable = false;
                BlankZero = true;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcQuotedPrice();
        CalcOrderedPrice();
    end;

    var
        QuotedPriceTotal: Decimal;
        OrderedPriceTotal: Decimal;

    local procedure CalcQuotedPrice()
    var
        PVSJob: Record "PVS Job";
    begin
        QuotedPriceTotal := 0;
        PVSJob.SetRange(ID, Rec.ID);
        PVSJob.SetRange(Status, PVSJob.Status::Quote);
        PVSJob.SetRange(Active, true);
        PVSJob.CalcSums("Quoted Price");
        QuotedPriceTotal := PVSJob."Quoted Price";
    end;

    local procedure CalcOrderedPrice()
    var
        PVSJob: Record "PVS Job";
    begin
        OrderedPriceTotal := 0;
        PVSJob.SetRange(ID, Rec.ID);
        PVSJob.SetRange(Status, PVSJob.Status::Order);
        PVSJob.SetRange(Active, true);
        PVSJob.CalcSums("Quoted Price");
        OrderedPriceTotal := PVSJob."Quoted Price";
    end;
}
