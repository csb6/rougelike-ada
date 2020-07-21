with Terminal_Interface.Curses;
with Config;
with Ada.Text_IO;

package body Gameboard is

   procedure load_actor_types(self : in out Object);
   procedure load_item_types(self : in out Object);

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
      self.map(23, 15) := ('d', Item.Item_Id'First);

      self.load_actor_types;

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
   begin
      Display.clear;
      if (Display.is_large_enough) then
         declare
            player_position : constant Actor.Position := self.actors.player_position;
         begin
            self.screen.draw(self.map, player_position.x, player_position.y);
         end;
      else
         Display.print(0, 0, "Screen too small");
      end if;
   exception
      when Terminal_Interface.Curses.Curses_Exception =>
         -- When width gets too small, ncurses throws an exception before
         -- the above code gets a chance to run, so need to catch the exception
         -- to let the user know
         Display.clear;
         Display.print(0, 0, "Screen too small");
   end redraw_resize;



   procedure load_actor_types(self : in out Object) is
      type_file : Config.Configuration;
      sections : Config.Section_List;
      line : Terminal_Interface.Curses.Line_Position := 0;

      -- The Actor_Type fields
      icon : Character;
      name : Item.Name_String;
      energy : Actor.Energy;
      stats : Actor.Battle_Stats;
   begin
      type_file.Init("data/actors.ini");
      -- Each section corresponds to one actor type
      sections := type_file.Read_Sections;

      for actor_type of sections loop
         if actor_type'Length > 0 then
            declare
               value : String := type_file.Value_Of(Section => actor_type,
                                                    Mark    => "icon",
                                                    Default => "?");
            begin
               icon := value(value'First);
            end;
            name := Item.add_padding(actor_type); -- Section heading is the type's name
            energy := Actor.Energy(type_file.Value_Of(Section => actor_type,
                                                      Mark    => "energy",
                                                      Default => 3));
            stats.attack := Actor.Attack_Value(type_file.Value_Of(Section => actor_type,
                                                                  Mark    => "attack",
                                                                  Default => 0));
            stats.defense := Actor.Defense_Value(type_file.Value_Of(Section => actor_type,
                                                                    Mark    => "defense",
                                                                    Default => 0));
            stats.ranged_attack := Actor.Attack_Value(type_file.Value_Of(Section => actor_type,
                                                                         Mark    => "ranged_attack",
                                                                         Default => 0));

            self.actor_types.add(icon, name, energy, stats);
         end if;
      end loop;
   end load_actor_types;

   procedure load_item_types(self : in out Object) is
   begin
      null;
   end load_item_types;

end Gameboard;
