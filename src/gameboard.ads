with Actor;
with Item;
with Display;

package Gameboard is
   type Grid is array(Display.Y_Pos, Display.X_Pos) of Display.Cell;
   
   type Object is tagged private;

   procedure make(self : in out Object);

private
   type Object is tagged record
      actor_types : Actor.Actor_Type_Table;
      item_types : Item.Item_Type_Table;
      actors : Actor.Actor_Table;
      
      map : Grid;
   end record;
end Gameboard;
