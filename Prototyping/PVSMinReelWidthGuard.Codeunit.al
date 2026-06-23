codeunit 50101 "PVS Min Reel Width Guard"
{
    SingleInstance = true;

    var
        CalcInProgress: Boolean;

    procedure SetCalcInProgress(Value: Boolean)
    begin
        CalcInProgress := Value;
    end;

    procedure IsCalcInProgress(): Boolean
    begin
        exit(CalcInProgress);
    end;
}
