codeunit 50100 "CK Management"
{
    /// <summary>
    /// Generates a unique LOT number for a newly mixed ink batch.
    /// Format: CK-YYYYMMDDHHMMSS
    /// </summary>
    procedure GenerateLOTNo(): Code[50]
    var
        DateTimeText: Text;
    begin
        DateTimeText := Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>');
        exit(CopyStr('CK-' + DateTimeText, 1, 50));
    end;

    /// <summary>
    /// Populates Mix Lines from the Color Kitchen Recipe for the given Mix Header.
    /// Existing lines are replaced. Quantities are calculated from the recipe percentages
    /// and the Quantity to Mix on the header.
    /// </summary>
    procedure LoadRecipeLines(MixHeaderEntryNo: Integer)
    var
        MixHeader: Record "CK Mix Header";
        RecipeLine: Record "CK Recipe Line";
        MixLine: Record "CK Mix Line";
        LineNo: Integer;
    begin
        if not MixHeader.Get(MixHeaderEntryNo) then
            exit;

        // Remove any previously loaded lines so we start fresh
        MixLine.SetRange("Mix Header Entry No.", MixHeaderEntryNo);
        MixLine.DeleteAll(true);

        RecipeLine.SetRange("Item No.", MixHeader."Item No.");
        if not RecipeLine.FindSet() then
            exit;

        LineNo := 10000;
        repeat
            MixLine.Init();
            MixLine."Mix Header Entry No." := MixHeaderEntryNo;
            MixLine."Line No." := LineNo;
            MixLine."Base Component Item No." := RecipeLine."Base Component Item No.";
            MixLine."Base Component Description" := RecipeLine."Base Component Description";
            MixLine.Percentage := RecipeLine.Percentage;
            if MixHeader."Quantity to Mix" > 0 then
                MixLine."Quantity Required" :=
                    Round(MixHeader."Quantity to Mix" * RecipeLine.Percentage / 100, 0.001);
            MixLine."Quantity Used" := MixLine."Quantity Required";
            MixLine.Status := "CK Mix Line Status"::Pending;
            MixLine.Insert(true);
            LineNo += 10000;
        until RecipeLine.Next() = 0;
    end;

    /// <summary>
    /// Posts negative item adjustments for each pending base component line,
    /// recording the operator-supplied LOT numbers. Advances header status to In Progress.
    /// </summary>
    procedure PostConsumption(MixHeaderEntryNo: Integer)
    var
        MixHeader: Record "CK Mix Header";
        MixLine: Record "CK Mix Line";
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        LineNo: Integer;
        DocumentNo: Code[20];
    begin
        if not MixHeader.Get(MixHeaderEntryNo) then
            exit;

        DocumentNo := CopyStr('CK-' + Format(MixHeaderEntryNo), 1, 20);

        MixLine.SetRange("Mix Header Entry No.", MixHeaderEntryNo);
        MixLine.SetRange(Status, "CK Mix Line Status"::Pending);
        if not MixLine.FindSet() then
            exit;

        LineNo := 10000;
        repeat
            if MixLine."Quantity Used" > 0 then begin
                Clear(ItemJnlLine);
                ItemJnlLine."Line No." := LineNo;
                ItemJnlLine.Validate("Posting Date", Today());
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                ItemJnlLine.Validate("Item No.", MixLine."Base Component Item No.");
                ItemJnlLine.Validate(Quantity, MixLine."Quantity Used");
                ItemJnlLine."Lot No." := MixLine."LOT No.";
                ItemJnlLine."Document No." := DocumentNo;
                ItemJnlLine."Source Code" := GetSourceCode();
                ItemJnlPostLine.RunWithCheck(ItemJnlLine);

                MixLine.Status := "CK Mix Line Status"::Consumed;
                MixLine.Modify(true);
            end;
            LineNo += 10000;
        until MixLine.Next() = 0;

        MixHeader.Status := "CK Mix Status"::"In Progress";
        MixHeader.Modify(true);
    end;

    /// <summary>
    /// Generates a new LOT number if needed, then posts a positive item adjustment
    /// to put the mixed ink into stock. Advances header status to Completed.
    /// </summary>
    procedure PostMixedInkToStock(MixHeaderEntryNo: Integer)
    var
        MixHeader: Record "CK Mix Header";
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DocumentNo: Code[20];
    begin
        if not MixHeader.Get(MixHeaderEntryNo) then
            exit;

        if MixHeader."LOT No." = '' then
            MixHeader."LOT No." := GenerateLOTNo();

        if MixHeader."Quantity Mixed" = 0 then
            MixHeader."Quantity Mixed" := MixHeader."Quantity to Mix";

        DocumentNo := CopyStr('CK-' + Format(MixHeaderEntryNo), 1, 20);

        Clear(ItemJnlLine);
        ItemJnlLine."Line No." := 10000;
        ItemJnlLine.Validate("Posting Date", Today());
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
        ItemJnlLine.Validate("Item No.", MixHeader."Item No.");
        ItemJnlLine.Validate(Quantity, MixHeader."Quantity Mixed");
        ItemJnlLine."Lot No." := MixHeader."LOT No.";
        ItemJnlLine."Document No." := DocumentNo;
        ItemJnlLine."Source Code" := GetSourceCode();
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        MixHeader.Status := "CK Mix Status"::Completed;
        MixHeader.Modify(true);
    end;

    /// <summary>
    /// Returns a formatted text of all base component LOT numbers recorded on a mix.
    /// Used for label printing and job ticket display.
    /// </summary>
    procedure GetBaseComponentLOTsText(MixHeaderEntryNo: Integer): Text
    var
        MixLine: Record "CK Mix Line";
        LOTText: Text;
    begin
        MixLine.SetRange("Mix Header Entry No.", MixHeaderEntryNo);
        MixLine.SetFilter("LOT No.", '<>%1', '');
        if MixLine.FindSet() then
            repeat
                if LOTText <> '' then
                    LOTText += '; ';
                LOTText += MixLine."Base Component Item No." + ': ' + MixLine."LOT No.";
            until MixLine.Next() = 0;
        exit(LOTText);
    end;

    local procedure GetSourceCode(): Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SourceCodeSetup.Get() then
            exit(SourceCodeSetup."Item Journal");
        exit('');
    end;
}
