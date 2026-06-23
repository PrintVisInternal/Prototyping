report 50100 "CK Component List"
{
    Caption = 'Color Kitchen – Component List';
    UsageCategory = None;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Reports/Rep50100.CKComponentList.rdlc';

    dataset
    {
        dataitem(MixHeader; "CK Mix Header")
        {
            RequestFilterFields = "Entry No.", "PVS Case No.", "PVS Job No.";
            PrintOnlyIfDetail = true;

            column(CaseNo; MixHeader."PVS Case No.") { }
            column(JobNo; MixHeader."PVS Job No.") { }
            column(MixedInkItemNo; MixHeader."Item No.") { }
            column(MixedInkDescription; MixHeader."Item Description") { }
            column(QuantityToMix; MixHeader."Quantity to Mix") { }
            column(UnitOfMeasure; MixHeader."Unit of Measure Code") { }
            column(EcoLabels; MixHeader."Eco Label Codes") { }
            column(MixStatus; Format(MixHeader.Status)) { }
            column(PrintDate; Format(Today())) { }

            dataitem(MixLine; "CK Mix Line")
            {
                DataItemLink = "Mix Header Entry No." = field("Entry No.");
                DataItemTableView = sorting("Mix Header Entry No.", "Line No.");

                column(LineNo; MixLine."Line No.") { }
                column(ComponentItemNo; MixLine."Base Component Item No.") { }
                column(ComponentDescription; MixLine."Base Component Description") { }
                column(Percentage; MixLine.Percentage) { }
                column(QuantityRequired; MixLine."Quantity Required") { }
                column(QuantityUsed; MixLine."Quantity Used") { }
                column(ComponentLOTNo; MixLine."LOT No.") { }
                column(ShelfNo; MixLine."Shelf No.") { }
                column(LineStatus; Format(MixLine.Status)) { }

                trigger OnPreDataItem()
                begin
                    if not ShowConsumed then
                        MixLine.SetRange(Status, "CK Mix Line Status"::Pending);
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowConsumedLines; ShowConsumed)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Already Consumed Components';
                        ToolTip = 'Check to include base component lines that have already been consumed.';
                    }
                }
            }
        }
    }

    var
        ShowConsumed: Boolean;
}
