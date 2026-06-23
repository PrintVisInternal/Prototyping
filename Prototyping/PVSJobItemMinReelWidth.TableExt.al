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
                // xRec holds the pre-validate value; Diff is 0 when unchanged (e.g. first-time insert)
                Diff := Rec."Minimum Reel Width" - xRec."Minimum Reel Width";
                if (Diff <> 0) and (xRec."Minimum Reel Width" <> 0) then
                    // Per spec: the difference (new - old) is added 1:1 to Front Overfold
                    Rec."Front Overfold" := Rec."Front Overfold" + Diff;
            end;
        }
    }
}
