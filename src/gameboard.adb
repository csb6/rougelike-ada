package body Gameboard is

   procedure make(self : in out Object) is
   begin
      self.actor_types.add(icon  => '@',
                           name  => Item.add_padding("Player"),
                           stats => (1, 1, 1));
      self.item_types.add_melee_weapon(icon   => 'd',
                                       name   => Item.add_padding("Dagger"),
                                       attack => 3);

      self.actors.add(kind => Actor.Player_Type_Id,
                      pos  => (0, 0));

      self.map(0, 0) := ('@', Actor.Player_Id);
      self.map(23, 15) := ('d', 0);

      Display.clear;
      self.screen.draw(self.map, 0, 0);
   end make;

   procedure move(self : in out Object; curr_actor : Actor.Actor_Id;
                  column : Display.X_Pos; row : Display.Y_Pos) is
      use Item;
      target : constant Item.Entity_Id := self.map(row, column).entity;
      actor_x : constant Display.X_Pos := self.actors.positions(curr_actor).x;
      actor_y : constant Display.Y_Pos := self.actors.positions(curr_actor).y;
   begin
      if (target = Item.Occupied_Tile) then
         return;
      end if;

      if (target = Item.No_Entity) then
         -- Move the actor to a previously empty tile
         declare
            actor_icon : constant Character := self.map(actor_y, actor_x).icon;
         begin
            self.map(actor_y, actor_x) := (Item.Floor_Icon, Item.No_Entity);
            self.map(row, column) := (actor_icon, curr_actor);
            self.actors.positions(curr_actor) := (column, row);

            Display.clear;
            self.screen.draw(self.map, column, row);
         end;
      elsif (target in Item.Item_Id'Range) then
         -- Pickup the Item at the target square
         declare
            target_item : constant Item.Item_Id := Item.Item_Id(target);
         begin
            self.items.add_stack(actor => curr_actor,
                                 item  => target_item,
                                 count => 1);
            self.map(row, column) := (Item.Floor_Icon, Item.No_Entity);

            Display.clear;
            self.screen.draw(self.map, actor_x, actor_y);
         end;
      end if;
   end move;

   procedure translate_player(self : in out Object; dx : Display.DX;
                              dy : Display.DY) is
      new_x : constant Integer := Integer(self.actors.positions(Actor.Player_Id).x) + Integer(dx);
      new_y : constant Integer := Integer(self.actors.positions(Actor.Player_Id).y) + Integer(dy);
   begin
      self.move(Actor.Player_Id, Display.X_Pos(new_x), Display.Y_Pos(new_y));
   end translate_player;

   procedure redraw_resize(self : in out Object) is
      player_position : constant Actor.Position := self.actors.player_position;
   begin
      Display.clear;
      self.screen.draw(self.map, player_position.x, player_position.y);
   end redraw_resize;

end Gameboard;
