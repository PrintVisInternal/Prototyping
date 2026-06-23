/// <summary>
/// Registers the PVS Ticket Classifier Copilot capability on app install.
/// </summary>
codeunit 50111 "PVS Ticket Classifier Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCopilotCapability();
    end;

    local procedure RegisterCopilotCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrl: Text[2048];
    begin
        LearnMoreUrl := 'https://www.printvis.com';
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"PVS Ticket Classifier") then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::"PVS Ticket Classifier",
                LearnMoreUrl);
    end;
}
