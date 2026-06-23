table 50100 "PVS Case History"
{
    Caption = 'PVS Case History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Case No."; Code[20])
        {
            Caption = 'Case No.';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(5; "Job Type Code"; Code[20])
        {
            Caption = 'Job Type Code';
        }
        field(6; "Job Type Description"; Text[100])
        {
            Caption = 'Job Type Description';
        }
        field(7; "Material Code"; Code[20])
        {
            Caption = 'Material Code';
        }
        field(8; "Material Description"; Text[50])
        {
            Caption = 'Material Description';
        }
        field(9; "Description"; Text[200])
        {
            Caption = 'Description';
        }
        field(10; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(11; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(12; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 2;
        }
        field(13; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DecimalPlaces = 2 : 2;
        }
        field(14; "Turnaround Days"; Integer)
        {
            Caption = 'Turnaround Days';
        }
        field(15; "Status"; Text[50])
        {
            Caption = 'Status';
        }
        field(16; "Created Date"; Date)
        {
            Caption = 'Created Date';
        }
        field(17; "Customer Segment"; Text[50])
        {
            Caption = 'Customer Segment';
        }
        field(18; "Copilot Assisted"; Boolean)
        {
            Caption = 'Copilot Assisted';
        }
        field(19; "Copilot Assisted At"; DateTime)
        {
            Caption = 'Copilot Assisted At';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(CaseNo; "Case No.") { }
        key(CustomerDate; "Customer No.", "Created Date") { }
        key(JobTypeMaterial; "Job Type Code", "Material Code") { }
    }
}
