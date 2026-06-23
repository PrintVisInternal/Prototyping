/// <summary>
/// Defines the standard classification categories for PrintVis support tickets.
/// </summary>
enum 50110 "PVS Ticket Category"
{
    Extensible = false;

    value(0; Issue)
    {
        Caption = 'Issue';
    }
    value(1; HowTo)
    {
        Caption = 'How To';
    }
    value(2; EventRequest)
    {
        Caption = 'Event Request';
    }
    value(3; Idea)
    {
        Caption = 'Idea';
    }
    value(4; License)
    {
        Caption = 'License';
    }
    value(5; BCRelated)
    {
        Caption = 'BC-Related';
    }
    value(6; TechnicalQuestion)
    {
        Caption = 'Technical Question';
    }
    value(7; ResourceRequest)
    {
        Caption = 'Resource Request';
    }
    value(8; Other)
    {
        Caption = 'Other';
    }
}
