permissionset 50100 "PVS AI Case User"
{
    Caption = 'PVS AI Case User';
    Assignable = true;

    Permissions =
        tabledata "PVS Case History" = RIMD,
        tabledata "PVS Case Pattern" = RIMD,
        tabledata "PVS AI Case Setup" = RIMD,
        table "PVS Case History" = X,
        table "PVS Case Pattern" = X,
        table "PVS AI Case Setup" = X,
        codeunit "PVS Case History Mgmt" = X,
        codeunit "PVS Pattern Analysis" = X,
        codeunit "PVS Copilot Case Gen" = X,
        page "PVS AI Case Setup" = X,
        page "PVS Case Patterns" = X,
        page "PVS Copilot Case Dialog" = X,
        page "PVS Case History Subform" = X;
}
