page 50100 "PVS AI Case Setup"
{
    PageType = Card;
    Caption = 'PVS AI Case Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PVS AI Case Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("History Months"; Rec."History Months")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of months of case history to load for pattern analysis.';
                }
                field("Last Refresh Date"; Rec."Last Refresh Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date and time the case history was last refreshed.';
                }
                field("Total Cases Loaded"; Rec."Total Cases Loaded")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total number of cases loaded into the history table.';
                }
                field("Total Patterns Found"; Rec."Total Patterns Found")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total number of patterns identified from case history.';
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Job Queue Category used for the scheduled history refresh job.';
                }
            }
            group(CopilotSettings)
            {
                Caption = 'Copilot / Azure OpenAI';

                field("Enable Copilot"; Rec."Enable Copilot")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable the Copilot Case Assistant feature.';
                }
                field("AOAI Endpoint"; Rec."AOAI Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Your Azure OpenAI endpoint URL (e.g. https://<resource>.openai.azure.com/).';
                }
                field("AOAI Deployment Name"; Rec."AOAI Deployment Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The deployment name of the GPT model in Azure OpenAI Studio.';
                }
                field(APIKeyInput; APIKeyDisplayText)
                {
                    ApplicationArea = All;
                    Caption = 'Azure OpenAI API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Enter the Azure OpenAI API key. The value is stored securely and cannot be read back.';

                    trigger OnValidate()
                    begin
                        if APIKeyDisplayText <> '' then begin
                            IsolatedStorage.Set('PVSAOAIApiKey', APIKeyDisplayText, DataScope::Module);
                            APIKeyDisplayText := '********';
                            Message('API Key saved securely.');
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshHistory)
            {
                ApplicationArea = All;
                Caption = 'Refresh Case History';
                ToolTip = 'Reload the last N months of cases from PrintVis into the history table and re-run pattern analysis.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    HistoryMgmt: Codeunit "PVS Case History Mgmt";
                begin
                    HistoryMgmt.PopulateHistory();
                    Rec.Get(Rec.Code);
                    Message('Case history refreshed. %1 cases loaded, %2 patterns found.',
                        Rec."Total Cases Loaded", Rec."Total Patterns Found");
                end;
            }
            action(AnalyzePatterns)
            {
                ApplicationArea = All;
                Caption = 'Re-analyse Patterns';
                ToolTip = 'Re-run pattern analysis on the existing history without reloading cases.';
                Image = Alerts;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    PatternAnalysis: Codeunit "PVS Pattern Analysis";
                begin
                    PatternAnalysis.AnalyzePatterns();
                    Rec.Get(Rec.Code);
                    Message('%1 patterns found.', Rec."Total Patterns Found");
                end;
            }
            action(ViewPatterns)
            {
                ApplicationArea = All;
                Caption = 'View Patterns';
                ToolTip = 'Open the Case Patterns list to inspect all discovered patterns.';
                Image = List;
                RunObject = Page "PVS Case Patterns";
            }
            action(CreateJobQueue)
            {
                ApplicationArea = All;
                Caption = 'Schedule Nightly Refresh';
                ToolTip = 'Create a Job Queue Entry to refresh case history every night at 02:00.';
                Image = JobQueueEntry;

                trigger OnAction()
                var
                    HistoryMgmt: Codeunit "PVS Case History Mgmt";
                begin
                    HistoryMgmt.CreateJobQueueEntry();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('DEFAULT') then begin
            Rec.Init();
            Rec.Code := 'DEFAULT';
            Rec."History Months" := 12;
            Rec.Insert(true);
        end;
        APIKeyDisplayText := '********';
    end;

    var
        APIKeyDisplayText: Text;
}
