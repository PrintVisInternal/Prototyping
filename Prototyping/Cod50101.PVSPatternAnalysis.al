/// <summary>
/// Analyses Case History records to produce pattern summaries stored in PVS Case Pattern.
/// Patterns group cases by Job Type + Material + Customer Segment and compute statistical
/// summaries (averages, min/max, confidence score) used to guide Copilot suggestions.
/// </summary>
codeunit 50101 "PVS Pattern Analysis"
{
    Access = Public;

    /// <summary>
    /// Rebuilds the PVS Case Pattern table from all current PVS Case History records.
    /// </summary>
    procedure AnalyzePatterns()
    var
        Setup: Record "PVS AI Case Setup";
        CasePattern: Record "PVS Case Pattern";
        CaseHistory: Record "PVS Case History";
        TotalAmount: Decimal;
        MinAmount: Decimal;
        MaxAmount: Decimal;
        TotalQuantity: Decimal;
        TotalTurnaround: Decimal;
        CaseCount: Integer;
        PatternCount: Integer;
        CurrentJobType: Code[20];
        CurrentMaterial: Code[20];
        CurrentSegment: Text[50];
    begin
        CasePattern.DeleteAll(false);

        CaseHistory.SetCurrentKey(CaseHistory."Job Type Code", CaseHistory."Material Code", CaseHistory."Customer Segment");
        if not CaseHistory.FindSet() then
            exit;

        CurrentJobType := CaseHistory."Job Type Code";
        CurrentMaterial := CaseHistory."Material Code";
        CurrentSegment := CaseHistory."Customer Segment";
        InitAccumulators(TotalAmount, MinAmount, MaxAmount, TotalQuantity, TotalTurnaround, CaseCount);

        repeat
            if (CaseHistory."Job Type Code" <> CurrentJobType) or
               (CaseHistory."Material Code" <> CurrentMaterial) or
               (CaseHistory."Customer Segment" <> CurrentSegment)
            then begin
                WritePattern(
                    CasePattern, CurrentJobType, CurrentMaterial, CurrentSegment,
                    TotalAmount, MinAmount, MaxAmount, TotalQuantity, TotalTurnaround, CaseCount);
                PatternCount += 1;

                CurrentJobType := CaseHistory."Job Type Code";
                CurrentMaterial := CaseHistory."Material Code";
                CurrentSegment := CaseHistory."Customer Segment";
                InitAccumulators(
                    TotalAmount, MinAmount, MaxAmount, TotalQuantity, TotalTurnaround, CaseCount);
            end;

            AccumulateCase(
                CaseHistory, TotalAmount, MinAmount, MaxAmount,
                TotalQuantity, TotalTurnaround, CaseCount);
        until CaseHistory.Next() = 0;

        // Write the last group
        if CaseCount > 0 then begin
            WritePattern(
                CasePattern, CurrentJobType, CurrentMaterial, CurrentSegment,
                TotalAmount, MinAmount, MaxAmount, TotalQuantity, TotalTurnaround, CaseCount);
            PatternCount += 1;
        end;

        if Setup.Get('DEFAULT') then begin
            Setup."Total Patterns Found" := PatternCount;
            Setup.Modify(true);
        end;
    end;

    local procedure InitAccumulators(
        var TotalAmount: Decimal;
        var MinAmount: Decimal;
        var MaxAmount: Decimal;
        var TotalQuantity: Decimal;
        var TotalTurnaround: Decimal;
        var CaseCount: Integer)
    begin
        TotalAmount := 0;
        MinAmount := 0;
        MaxAmount := 0;
        TotalQuantity := 0;
        TotalTurnaround := 0;
        CaseCount := 0;
    end;

    local procedure AccumulateCase(
        CaseHistory: Record "PVS Case History";
        var TotalAmount: Decimal;
        var MinAmount: Decimal;
        var MaxAmount: Decimal;
        var TotalQuantity: Decimal;
        var TotalTurnaround: Decimal;
        var CaseCount: Integer)
    begin
        CaseCount += 1;
        TotalAmount += CaseHistory."Total Amount";
        TotalQuantity += CaseHistory.Quantity;
        TotalTurnaround += CaseHistory."Turnaround Days";

        if CaseCount = 1 then begin
            MinAmount := CaseHistory."Total Amount";
            MaxAmount := CaseHistory."Total Amount";
        end else begin
            if CaseHistory."Total Amount" < MinAmount then
                MinAmount := CaseHistory."Total Amount";
            if CaseHistory."Total Amount" > MaxAmount then
                MaxAmount := CaseHistory."Total Amount";
        end;
    end;

    local procedure WritePattern(
        var CasePattern: Record "PVS Case Pattern";
        JobTypeCode: Code[20];
        MaterialCode: Code[20];
        CustomerSegment: Text[50];
        TotalAmount: Decimal;
        MinAmount: Decimal;
        MaxAmount: Decimal;
        TotalQuantity: Decimal;
        TotalTurnaround: Decimal;
        CaseCount: Integer)
    begin
        CasePattern.Init();
        CasePattern."Job Type Code" := JobTypeCode;
        CasePattern."Material Code" := MaterialCode;
        CasePattern."Customer Segment" :=
            CopyStr(CustomerSegment, 1, MaxStrLen(CasePattern."Customer Segment"));
        CasePattern."Case Count" := CaseCount;
        CasePattern."Min Total Amount" := MinAmount;
        CasePattern."Max Total Amount" := MaxAmount;
        CasePattern."Last Updated" := CurrentDateTime();

        if CaseCount > 0 then begin
            CasePattern."Avg Total Amount" := Round(TotalAmount / CaseCount, 0.01);
            CasePattern."Avg Quantity" := Round(TotalQuantity / CaseCount, 0.01);
            CasePattern."Avg Turnaround Days" := Round(TotalTurnaround / CaseCount, 0.1);
        end;

        // Confidence = min(100, sqrt(CaseCount) * 20) — more cases = higher confidence
        CasePattern."Confidence Score" :=
            Round(MinDecimal(100, Sqrt(CaseCount) * 20), 0.1);

        CasePattern.Insert(false);
    end;

    local procedure MinDecimal(A: Decimal; B: Decimal): Decimal
    begin
        if A < B then
            exit(A);
        exit(B);
    end;
}
