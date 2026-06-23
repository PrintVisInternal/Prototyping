permissionset 50110 "PVS Ticket Classifier"
{
    Caption = 'PVS Ticket Classifier';
    Assignable = true;

    Permissions =
        tabledata "PVS Ticket Classification" = RIMD,
        table "PVS Ticket Classification" = X,
        codeunit "PVS Ticket Classifier AI" = X,
        page "PVS Ticket Classifier" = X,
        page "PVS Ticket Classification Log" = X;
}
