with Terminal_Interface.Curses;
with Config;

package body Gameboard is

   package Curses renames Terminal_Interface.Curses;

   procedure load_actor_types(self : in out Object; path : String);
   procedure load_weapon_types(weapon_list : in out Item.Weapon_Type_Array;
                               path : String);
   procedure load_armor_types(self : in out Object; path : String);

   procedure make(self : in out Object) is
   begin
      self.actor_types.add(icon  => '@',
                           name  => Item.add_padding("Player"),
                           stats => (1, 1, 1));

      self.actors.add(kind => Actor.Player_Type_Id,
                      pos  => (0, 0), hp => 5);

      self.map(0, 0) := ('@', Actor.Player_Id);
      self.map(23, 15) := ('s', Item.Item_Id'First);

      self.load_actor_types("data/actors.ini");
      self.load_armor_types("data/armor.ini");
      load_weapon_types(self.item_types.melee_weapons, "data/melee-weapons.ini");
      load_weapon_types(self.item_types.ranged_weapons, "data/ranged-weapons.ini");

      self.screen.draw(self.map, 0, 0);
   end make;

   procedure move(self : in out Object; curr_actor : Actor.Actor_Id;
                  column : Display.X_Pos; row : Display.Y_Pos) is
      use all type Item.Entity_Id;
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

   procedure translate_player(self : in out Object; dx : Display.X_Offset;
                              dy : Display.Y_Offset) is
      use all type Curses.Column_Position, Curses.Line_Position;
      new_x : Curses.Column_Position := self.actors.positions(Actor.Player_Id).x + dx;
      new_y : Curses.Line_Position := self.actors.positions(Actor.Player_Id).y + dy;
   begin
      if (new_x not in Display.X_Pos or else new_y not in Display.Y_Pos) then
         -- Don't allow out-of-bounds moves
         return;
      end if;
      self.move(Actor.Player_Id, new_x, new_y);
   end translate_player;


   procedure show_inventory(self : in out Object) is
      start_index, end_index : Actor.Inventory_Index;
      found_player : Boolean;
   begin
      found_player := self.items.find_range(Actor.Player_Id, start_index, end_index);
      Display.print(0, 0, "Inventory (Backspace to exit):");
      if (not found_player) then
         Display.print(0, 1, "  Empty");
      else
         declare
            curr_line : Curses.Line_Position := 1;
            curr_id : Item.Item_Id;
            curr_item_name : Item.Name_String;
         begin
            for index in Actor.Inventory_Index range start_index .. end_index loop
               curr_id := self.items.stacks(index).id;
               case curr_id is
               when Item.Melee_Weapon_Id'Range =>
                  curr_item_name := self.item_types.melee_weapons(curr_id).name;
               when Item.Ranged_Weapon_Id'Range =>
                  curr_item_name := self.item_types.ranged_weapons(curr_id).name;
               when Item.Armor_Id'Range =>
                  curr_item_name := self.item_types.armor(curr_id).name;
               when others =>
                  curr_item_name := Item.add_padding("Unknown Item");
               end case;
               Display.print(0, curr_line, "  " & curr_item_name);
            end loop;
         end;
      end if;
   end show_inventory;

   procedure redraw(self : in out Object) is
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
      when Curses.Curses_Exception =>
         -- When width gets too small, ncurses throws an exception before
         -- the above code gets a chance to run, so need to catch the exception
         -- to let the user know
         Display.clear;
         Display.print(0, 0, "Screen too small");
   end redraw;



   -- Get a list of actor "types" (kinds of actors) from an .INI file
   -- and add them to self.actor_types, where they can be used as templates
   -- for individual actors. Expects the player actor type to be already added
   procedure load_actor_types(self : in out Object; path : String) is
      type_file : Config.Configuration;
      sections : Config.Section_List;
      line : Curses.Line_Position := 0;

      -- The Actor_Type fields
      icon : Character;
      name : Item.Name_String;
      energy : Actor.Energy;
      stats : Actor.Battle_Stats;
   begin
      type_file.Init(path);
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

   -- Get a list of weapon item types from an .INI file and adds them to an array.
   -- Intended to be used either with Gameboard.Object.item_types.melee_weapons or
   -- Gameboard.Object.item_types.ranged_weapons, so it is not directly coupled to the
   -- Gameboard.Object type directly.
   procedure load_weapon_types(weapon_list : in out Item.Weapon_Type_Array;
                               path : String) is
      type_file : Config.Configuration;
      sections : Config.Section_List;
      line : Curses.Line_Position := 0;
      insert_index : Item.Weapon_Id := weapon_list'First;
      use all type Item.Weapon_Id;

      -- The Weapon_Type fields
      icon : Character;
      name : Item.Name_String;
      attack : Natural;
   begin
      type_file.Init(path);
      -- Each section corresponds to one weapon type
      sections := type_file.Read_Sections;

      for item_type of sections loop
         declare
            value : String := type_file.Value_Of(Section => item_type,
                                                 Mark    => "icon",
                                                 Default => "?");
         begin
            icon := value(value'First);
         end;
         name := Item.add_padding(item_type); -- Section heading is the type's name
         attack := type_file.Value_Of(Section => item_type,
                                      Mark    => "attack",
                                      Default => 0);
         weapon_list(insert_index) := (icon, name, attack);
         insert_index := insert_index + 1;
      end loop;
   end load_weapon_types;

   -- Get a list of armor item types from an .INI file and adds them to
   -- Gameboard.Object.item_types.armor
   procedure load_armor_types(self : in out Object; path : String) is
      type_file : Config.Configuration;
      sections : Config.Section_List;
      line : Curses.Line_Position := 0;

      -- The Armor_Type fields
      icon : Character;
      name : Item.Name_String;
      defense : Natural;
   begin
      type_file.Init(path);
      sections := type_file.Read_Sections;

      for armor_type of sections loop
         declare
            value : String := type_file.Value_Of(Section => armor_type,
                                                 Mark    => "icon",
                                                 Default => "?");
         begin
            icon := value(value'First);
         end;

         name := Item.add_padding(armor_type);
         defense := type_file.Value_Of(Section => armor_type,
                                       Mark    => "defense",
                                       Default => 0);

         self.item_types.add_armor(icon, name, defense);
      end loop;
   end load_armor_types;

end Gameboard;
