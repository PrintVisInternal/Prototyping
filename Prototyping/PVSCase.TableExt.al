tableextension 50100 "PVS Case Ext. Pricing" extends "PVS Case"
{
    fields
    {
        field(50100; "Quoted Price Total"; Decimal)
        {
            Caption = 'Quoted Price Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("PVS Job"."Quoted Price" where("Case ID" = field("Case ID"),
                                                              Status = const(Quote)));
        }
        field(50101; "Ordered Price Total"; Decimal)
        {
            Caption = 'Ordered Price Total';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("PVS Job"."Quoted Price" where("Case ID" = field("Case ID"),
                                                              Status = const(Order)));
        }
    }
}
