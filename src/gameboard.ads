with Actor;
with Item;
with Display;

package Gameboard is
   -- Holds the game's main data structures, as well as most of the
   -- game logic.
   type Object is tagged private;

   -- Constructor for Gameboard.Object. Loads/sets-up the various
   -- data structures holding kinds of actors/items, as well as
   -- setting up the map
   procedure make(self : in out Object);
   
   -- Performs an actor on behalf of an actor (e.g. changing position
   -- or picking up an item)
   procedure move(self : in out Object;
                  curr_actor : Actor.Actor_Id := Actor.Player_Id;
                  column : Display.X_Pos; row : Display.Y_Pos);
   
   procedure teleport_player_to_cursor(self : in out Object);
   
   -- Same as move(), but targets an offset of the current position
   -- rather than an absolute position
   procedure translate_player(self : in out Object; dx : Display.X_Offset;
                              dy : Display.Y_Offset);
   
   procedure show_inventory(self : in out Object);

   -- Recalculates how/where to start drawing the screen and then
   -- clears/redraws the screen. Intended to be called when the user
   -- resizes the terminal window/needs to clear any UI drawn over board
   procedure redraw(self : in out Object);
private
   type Object is tagged record
      screen : Display.Manager;
      
      actor_types : Actor.Actor_Type_Table;
      item_types : Item.Item_Type_Table;
      actors : Actor.Actor_Table;
      items : Actor.Inventory_Table;
      
      map : Display.Grid;
   end record;
end Gameboard;
