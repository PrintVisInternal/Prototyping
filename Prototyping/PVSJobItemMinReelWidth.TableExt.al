tableextension 50100 "PVS Job Item Min Reel Width" extends "PVS Job Item"
{
    fields
    {
        field(50100; "Minimum Reel Width"; Decimal)
        {
            Caption = 'Minimum Reel Width';
            DataClassification = CustomerContent;
            ToolTip = 'Minimum Reel Width in mm';

            trigger OnValidate()
            var
                Diff: Decimal;
                Guard: Codeunit "PVS Min Reel Width Guard";
            begin
                if Guard.IsCalcInProgress() then
                    exit;
                Diff := Rec."Minimum Reel Width" - xRec."Minimum Reel Width";
                if Diff <> 0 then
                    Rec."Front Overfold" := Rec."Front Overfold" + Diff;
            end;
        }
    }
}
