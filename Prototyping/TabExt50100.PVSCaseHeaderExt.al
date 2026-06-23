/// <summary>
/// Extends the PrintVis Case table with Copilot audit fields.
/// NOTE: If the base table name differs from "PVS Case" in your environment,
///       update the extends clause accordingly.
/// </summary>
tableextension 50100 "PVS Case Header Ext" extends "PVS Case"
{
    fields
    {
        field(50100; "Copilot Assisted"; Boolean)
        {
            Caption = 'Copilot Assisted';
            DataClassification = CustomerContent;
            ToolTip = 'Indicates this case was created with the PrintVis Copilot assistant.';
        }
        field(50101; "Copilot Assisted At"; DateTime)
        {
            Caption = 'Copilot Assisted At';
            DataClassification = CustomerContent;
            ToolTip = 'Date and time the Copilot assistant was used to create this case.';
        }
    }
}
