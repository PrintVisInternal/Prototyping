codeunit 50103 "PVS AI Case Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCopilotCapability();
    end;

    trigger OnInstallAppPerCompany()
    begin
        InitializeSetup();
    end;

    local procedure RegisterCopilotCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrl: Text[2048];
    begin
        LearnMoreUrl := 'https://www.printvis.com';
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"PVS Case Assistant") then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::"PVS Case Assistant",
                LearnMoreUrl);
    end;

    local procedure InitializeSetup()
    var
        Setup: Record "PVS AI Case Setup";
    begin
        if not Setup.Get('DEFAULT') then begin
            Setup.Init();
            Setup.Code := 'DEFAULT';
            Setup."History Months" := 12;
            Setup."Enable Copilot" := false;
            Setup.Insert(true);
        end;
    end;
}
