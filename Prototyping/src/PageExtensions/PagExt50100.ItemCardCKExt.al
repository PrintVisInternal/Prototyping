pageextension 50100 "CK Item Card Ext" extends "Item Card"
{
    actions
    {
        addlast(Navigation)
        {
            action(ColorKitchenRecipe)
            {
                Caption = 'Color Kitchen Recipe';
                ApplicationArea = All;
                Image = BOMVersions;
                ToolTip = 'Opens the Color Kitchen Recipe for this item. Define the base component inks and their percentages that make up this mixed ink.';

                trigger OnAction()
                var
                    RecipeLine: Record "CK Recipe Line";
                begin
                    RecipeLine.SetRange("Item No.", Rec."No.");
                    Page.Run(Page::"CK Recipe Page", RecipeLine);
                end;
            }
        }
    }
}
