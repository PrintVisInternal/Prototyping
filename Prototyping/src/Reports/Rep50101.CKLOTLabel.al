report 50101 "CK LOT Label"
{
    Caption = 'Color Kitchen – LOT Label';
    UsageCategory = None;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Reports/Rep50101.CKLOTLabel.rdlc';

    dataset
    {
        dataitem(MixHeader; "CK Mix Header")
        {
            RequestFilterFields = "Entry No.", "LOT No.";
            DataItemTableView = where(Status = const(Completed));

            column(MixedInkItemNo; MixHeader."Item No.") { }
            column(MixedInkDescription; MixHeader."Item Description") { }
            column(MixedInkLOTNo; MixHeader."LOT No.") { }
            column(QuantityMixed; MixHeader."Quantity Mixed") { }
            column(UnitOfMeasure; MixHeader."Unit of Measure Code") { }
            column(EcoLabels; MixHeader."Eco Label Codes") { }
            column(CaseNo; MixHeader."PVS Case No.") { }
            column(JobNo; MixHeader."PVS Job No.") { }
            column(CreatedAt; Format(MixHeader."Created At")) { }
            column(PrintDate; Format(Today())) { }
            column(BaseComponentLOTs; BaseComponentLOTsText) { }

            trigger OnAfterGetRecord()
            begin
                BaseComponentLOTsText := GetBaseComponentLOTs();
            end;
        }
    }

    var
        BaseComponentLOTsText: Text;

    local procedure GetBaseComponentLOTs(): Text
    var
        CKMgt: Codeunit "CK Management";
    begin
        exit(CKMgt.GetBaseComponentLOTsText(MixHeader."Entry No."));
    end;
}
