with Actor;
with Item;
with Display;

package Gameboard is
   type Object is tagged private;

   procedure make(self : in out Object);
   procedure move(self : in out Object; curr_actor : Actor.Actor_Id;
                  column : Display.X_Pos; row : Display.Y_Pos);
   procedure translate_player(self : in out Object; dx : Display.DX;
                              dy : Display.DY);
   procedure redraw_resize(self : in out Object);
private
   type Object is tagged record
      screen : Display.Manager;
      
      actor_types : Actor.Actor_Type_Table;
      item_types : Item.Item_Type_Table;
      actors : Actor.Actor_Table;
      
      map : Display.Grid;
   end record;
end Gameboard;
