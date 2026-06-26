codeunit 50103 "PVS Job Item Min Reel Width"
{
    [EventSubscriber(ObjectType::Table, Database::"PVS Job Item", 'OnAfterValidateEvent', 'Final Format Code', false, false)]
    local procedure OnAfterValidateFormatCode(var Rec: Record "PVS Job Item"; var xRec: Record "PVS Job Item")
    begin
        CalcMinReelWidth(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"PVS Job Item", 'OnAfterValidateEvent', 'Controlling Sheet Unit', false, false)]
    local procedure OnAfterValidateControllingSheetUnit(var Rec: Record "PVS Job Item"; var xRec: Record "PVS Job Item")
    begin
        CalcMinReelWidth(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"PVS Job Item", 'OnAfterValidateEvent', 'Imposition Type', false, false)]
    local procedure OnAfterValidateImpositionType(var Rec: Record "PVS Job Item"; var xRec: Record "PVS Job Item")
    begin
        CalcMinReelWidth(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"PVS Job Item", 'OnAfterValidateEvent', 'Front Overfold', false, false)]
    local procedure OnAfterValidateFrontOverfold(var Rec: Record "PVS Job Item"; var xRec: Record "PVS Job Item")
    begin
        CalcMinReelWidth(Rec);
    end;

    local procedure CalcMinReelWidth(var Rec: Record "PVS Job Item")
    var
        ImpositionRec: Record "PVS Imposition Code";
        Guard: Codeunit "PVS Min Reel Width Guard";
        LeavesWidth: Decimal;
    begin
        if Guard.IsCalcInProgress() then
            exit;

        if not ComponentTypeIsInside(Rec."Component Type") then
            exit;

        Rec.CalcFields("Controlling Sheet Unit");
        if (Rec."Final Format Code" = '') or (Rec."Controlling Sheet Unit" = '') or (Rec."Imposition Type" = '') then
            exit;

        if not ImpositionRec.Get(Rec."Imposition Type") then
            exit;

        LeavesWidth := ImpositionRec."Leaves Width";

        Guard.SetCalcInProgress(true);
        if TryApplyMinReelWidth(Rec, LeavesWidth) then; // errors silenced; execution always reaches the next line
        Guard.SetCalcInProgress(false);
    end;

    [TryFunction]
    local procedure TryApplyMinReelWidth(var Rec: Record "PVS Job Item"; LeavesWidth: Decimal)
    begin
        // Direct assignment does not fire OnValidate; no recursion risk here
        Rec."Minimum Reel Width" :=
            (LeavesWidth * Rec.Width) +
            ((LeavesWidth / 2) * (Rec."Front Overfold" + Rec."Milling Depth"));
    end;

    local procedure ComponentTypeIsInside(ComponentType: Code[10]): Boolean
    begin
        // Matches component types whose code contains 'INSIDE', consistent with the '*INSIDE*' filter in the spec
        exit(StrPos(UpperCase(ComponentType), 'INSIDE') > 0);
    end;
}
