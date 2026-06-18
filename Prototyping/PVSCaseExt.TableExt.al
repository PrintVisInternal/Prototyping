tableextension 50100 "PVS Case Ext" extends "PVS Case"
{
    fields
    {
        field(50100; "Quoted Price"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PVS Job"."Quoted Price" where(ID = field(ID),
                                                             Status = const(Quote),
                                                             Active = const(true)));
            Editable = false;
        }
        field(50101; "Ordered Price"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PVS Job"."Quoted Price" where(ID = field(ID),
                                                             Status = const(Order),
                                                             Active = const(true)));
            Editable = false;
        }
    }
}
