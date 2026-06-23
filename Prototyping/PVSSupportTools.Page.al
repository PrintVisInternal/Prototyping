/// <summary>
/// Standalone support tools page. Provides a central entry point for Copilot-assisted
/// support features when no suitable PrintVis Role Center is available to extend.
/// </summary>
page 50112 "PVS Support Tools"
{
    PageType = Card;
    Caption = 'PVS Support Tools';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(CopilotGroup)
            {
                Caption = 'Copilot Features';
                InstructionalText = 'Use the actions below to access AI-powered support tools for PrintVis.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(SupportGroup)
            {
                Caption = 'Support';

                action(ClassifyTicket)
                {
                    ApplicationArea = All;
                    Caption = 'Classify Support Ticket';
                    Image = Sparkle;
                    ToolTip = 'Paste a support ticket description and let AI classify it into a standard PrintVis category.';

                    trigger OnAction()
                    begin
                        Page.RunModal(Page::"PVS Ticket Classifier");
                    end;
                }
                action(ViewLog)
                {
                    ApplicationArea = All;
                    Caption = 'View Classification Log';
                    Image = Log;
                    ToolTip = 'View all previously classified support tickets.';
                    RunObject = Page "PVS Ticket Classification Log";
                }
            }
        }
        area(Promoted)
        {
            actionref(ClassifyTicket_Promoted; ClassifyTicket) { }
            actionref(ViewLog_Promoted; ViewLog) { }
        }
    }
}
