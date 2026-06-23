/// <summary>
/// Populates the PVS Case History table from historical PrintVis cases.
/// </summary>
codeunit 50100 "PVS Case History Mgmt"
{
    Access = Public;

    trigger OnRun()
    begin
        PopulateHistory();
    end;

    /// <summary>
    /// Clears and repopulates the Case History table with cases from the last N months
    /// as configured in PVS AI Case Setup.
    /// </summary>
    procedure PopulateHistory()
    var
        Setup: Record "PVS AI Case Setup";
        CaseHistory: Record "PVS Case History";
        PVSCaseHeader: Record "PVS Case";
        Customer: Record Customer;
        PatternAnalysis: Codeunit "PVS Pattern Analysis";
        FromDate: Date;
        InsertCount: Integer;
    begin
        GetOrCreateSetup(Setup);
        FromDate := CalcDate('<-' + Format(Setup."History Months") + 'M>', Today());

        CaseHistory.DeleteAll(false);

        PVSCaseHeader.SetFilter(PVSCaseHeader."Order Date", '>=%1', FromDate);
        if PVSCaseHeader.FindSet() then
            repeat
                CaseHistory.Init();
                CaseHistory."Case No." := CopyStr(Format(PVSCaseHeader.ID), 1, MaxStrLen(CaseHistory."Case No."));
                CaseHistory."Customer No." := PVSCaseHeader."Customer No.";
                CaseHistory."Job Type Code" := PVSCaseHeader."Job Type Code";
                CaseHistory."Order Date" := PVSCaseHeader."Order Date";
                CaseHistory."Due Date" := PVSCaseHeader."Due Date";
                CaseHistory."Quantity" := PVSCaseHeader."Quantity 1";
                CaseHistory."Total Amount" := PVSCaseHeader."Total Sales Price";
                CaseHistory."Status" := Format(PVSCaseHeader.Status);
                CaseHistory."Created Date" := PVSCaseHeader."Order Date";

                if (CaseHistory."Order Date" <> 0D) and (CaseHistory."Due Date" <> 0D) and
                   (CaseHistory."Due Date" >= CaseHistory."Order Date")
                then
                    CaseHistory."Turnaround Days" :=
                        CaseHistory."Due Date" - CaseHistory."Order Date";

                if Customer.Get(PVSCaseHeader."Customer No.") then begin
                    CaseHistory."Customer Name" :=
                        CopyStr(Customer.Name, 1, MaxStrLen(CaseHistory."Customer Name"));
                    CaseHistory."Customer Segment" := Customer."Customer Posting Group";
                end;

                CaseHistory.Insert(false);
                InsertCount += 1;
            until PVSCaseHeader.Next() = 0;

        Setup."Total Cases Loaded" := InsertCount;
        Setup."Last Refresh Date" := CurrentDateTime();
        Setup.Modify(true);

        PatternAnalysis.AnalyzePatterns();
    end;

    /// <summary>
    /// Creates a recurring Job Queue Entry that refreshes case history nightly.
    /// </summary>
    procedure CreateJobQueueEntry()
    var
        Setup: Record "PVS AI Case Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        GetOrCreateSetup(Setup);

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"PVS Case History Mgmt";
        JobQueueEntry."Job Queue Category Code" := Setup."Job Queue Category Code";
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1440;
        JobQueueEntry."Starting Time" := 020000T;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := false;
        JobQueueEntry."Run on Sundays" := false;
        JobQueueEntry.Description := CopyStr(
            'Refresh PVS Case History (AI)', 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry.Insert(true);

        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);

        Message('Job Queue Entry created. Case history will refresh nightly at 02:00.');
    end;

    local procedure GetOrCreateSetup(var Setup: Record "PVS AI Case Setup")
    begin
        if not Setup.Get('DEFAULT') then begin
            Setup.Init();
            Setup.Code := 'DEFAULT';
            Setup."History Months" := 12;
            Setup.Insert(true);
        end;
    end;
}
