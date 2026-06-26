report 51001 "THR Thursday25 Cases"
{
    ApplicationArea = All;
    Caption = 'Thursday25 Cases';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = Word;
    WordLayout = 'src/THRThursday25Cases.docx';

    dataset
    {
        dataitem("PVS Case"; "PVS Case")
        {
            RequestFilterFields = "Order No.", Archived, "Creation Date";

            column(OrderNo; "PVS Case"."Order No.")
            {
                Caption = 'Order No.';
            }
            column(JobName; "PVS Case"."Job Name")
            {
                Caption = 'Job Name';
            }
            column(StatusCode; "PVS Case"."Status Code")
            {
                Caption = 'Status Code';
            }

            trigger OnPreDataItem()
            begin
                if GetFilter("Order No.") = '' then
                    SetFilter("Order No.", '<>%1', '');
                if GetFilter(Archived) = '' then
                    SetRange(Archived, true);
                if GetFilter("Creation Date") = '' then
                    SetFilter("Creation Date", '>=%1', CalcDate('<-2M>', Today));
            end;

            trigger OnAfterGetRecord()
            begin
                TotalCases += 1;
            end;
        }

        dataitem(SummaryLine; Integer)
        {
            DataItemTableView = where(Number = const(1));

            column(TotalCases; TotalCases)
            {
                Caption = 'Total Cases';
            }
        }
    }

    var
        TotalCases: Integer;
}
