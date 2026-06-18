tableextension 50100 "PVS Case Ext. Pricing" extends "PVS Case"
{
    fields
    {
        field(50100; "Quoted Price"; Decimal)
        {
            Caption = 'Quoted Price';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("PVS Job"."Quoted Price" where("Case ID" = field("Case ID"),
                                                              Active = const(true),
                                                              Status = const(Quote)));
        }
        field(50101; "Ordered Price"; Decimal)
        {
            Caption = 'Ordered Price';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("PVS Job"."Quoted Price" where("Case ID" = field("Case ID"),
                                                              Active = const(true),
                                                              Status = const(Order)));
        }
    }
}
