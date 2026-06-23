table 50102 "PVS AI Case Setup"
{
    Caption = 'PVS AI Case Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; "History Months"; Integer)
        {
            Caption = 'History Months';
            InitValue = 12;
            MinValue = 1;
            MaxValue = 60;
        }
        field(3; "Last Refresh Date"; DateTime)
        {
            Caption = 'Last Refresh Date';
            Editable = false;
        }
        field(4; "AOAI Endpoint"; Text[250])
        {
            Caption = 'Azure OpenAI Endpoint';
        }
        field(5; "AOAI Deployment Name"; Text[100])
        {
            Caption = 'Azure OpenAI Deployment Name';
        }
        field(6; "Enable Copilot"; Boolean)
        {
            Caption = 'Enable Copilot';
        }
        field(7; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category".Code;
        }
        field(8; "Total Cases Loaded"; Integer)
        {
            Caption = 'Total Cases Loaded';
            Editable = false;
        }
        field(9; "Total Patterns Found"; Integer)
        {
            Caption = 'Total Patterns Found';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
