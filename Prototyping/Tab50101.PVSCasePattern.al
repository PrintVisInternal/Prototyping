table 50101 "PVS Case Pattern"
{
    Caption = 'PVS Case Pattern';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Pattern ID"; Integer)
        {
            Caption = 'Pattern ID';
            AutoIncrement = true;
        }
        field(2; "Job Type Code"; Code[20])
        {
            Caption = 'Job Type Code';
        }
        field(3; "Job Type Description"; Text[100])
        {
            Caption = 'Job Type Description';
        }
        field(4; "Material Code"; Code[20])
        {
            Caption = 'Material Code';
        }
        field(5; "Customer Segment"; Text[50])
        {
            Caption = 'Customer Segment';
        }
        field(6; "Avg Quantity"; Decimal)
        {
            Caption = 'Avg Quantity';
            DecimalPlaces = 0 : 2;
        }
        field(7; "Avg Total Amount"; Decimal)
        {
            Caption = 'Avg Total Amount';
            DecimalPlaces = 2 : 2;
        }
        field(8; "Min Total Amount"; Decimal)
        {
            Caption = 'Min Total Amount';
            DecimalPlaces = 2 : 2;
        }
        field(9; "Max Total Amount"; Decimal)
        {
            Caption = 'Max Total Amount';
            DecimalPlaces = 2 : 2;
        }
        field(10; "Avg Turnaround Days"; Decimal)
        {
            Caption = 'Avg Turnaround Days';
            DecimalPlaces = 1 : 1;
        }
        field(11; "Case Count"; Integer)
        {
            Caption = 'Case Count';
        }
        field(12; "Confidence Score"; Decimal)
        {
            Caption = 'Confidence Score (%)';
            DecimalPlaces = 0 : 1;
            MinValue = 0;
            MaxValue = 100;
        }
        field(13; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
        }
        field(14; "Common Description"; Text[200])
        {
            Caption = 'Common Description';
        }
    }

    keys
    {
        key(PK; "Pattern ID")
        {
            Clustered = true;
        }
        key(JobTypeMaterialSegment; "Job Type Code", "Material Code", "Customer Segment") { }
        key(ConfidenceScore; "Confidence Score") { }
    }
}
