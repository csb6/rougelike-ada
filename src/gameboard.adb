with Terminal_Interface.Curses;
with Ada.Numerics.Discrete_Random;
with Gameboard.Data;

package body Gameboard is

   package Curses renames Terminal_Interface.Curses;
   use all type Curses.Column_Position, Curses.Line_Position, Item.Entity_Id,
       Actor.Battle_Value;

   --Setup RNG for determining who wins skill checks/battles
   package Random_Battle_Value is new Ada.Numerics.Discrete_Random(Actor.Battle_Value);
   rng : Random_Battle_Value.Generator;

   -- Utility functions/procedures
   function melee_attack(self : in out Object;
                         attacker : Actor.Actor_Id; target : Actor.Actor_Id)
                         return Boolean;


   procedure make(self : in out Object) is
   begin
      -- Uniquely seed the RNG
      Random_Battle_Value.Reset(rng);

      self.actor_types.add(icon  => '@',
                           name  => Item.add_padding("Player"),
                           stats => (1, 1, 1));

      self.actors.add(kind => Actor.Player_Type_Id,
                      pos  => (0, 0), hp => 5);

      Data.load_actor_types(self, "data/actors.ini");
      Data.load_armor_types(self, "data/armor.ini");
      Data.load_weapon_types(self.item_types.melee_weapons, "data/melee-weapons.ini");
      Data.load_weapon_types(self.item_types.ranged_weapons, "data/ranged-weapons.ini");

      Data.load_map(self, "data/map1.txt");
      self.map(0, 0) := ('@', Actor.Player_Id);

      self.screen.draw(self.map, 0, 0);
   end make;

   procedure move(self : in out Object;
                  curr_actor : Actor.Actor_Id := Actor.Player_Id;
                  column : Display.X_Pos; row : Display.Y_Pos) is
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
      elsif (target in Item.Item_Id) then
         -- Pickup the Item at the target square
         self.items.add_stack(actor => curr_actor,
                              item  => target,
                              count => 1);
         self.map(row, column) := (Item.Floor_Icon, Item.No_Entity);

         Display.clear;
         self.screen.draw(self.map, actor_x, actor_y);
      elsif (target in Actor.Actor_Id) then
         -- Attack the actor at that position
         declare
            attacker_wins : Boolean := self.melee_attack(attacker => curr_actor,
                                                         target => target);
            attacker_type : Actor.Actor_Type_Id := self.actors.kinds(curr_actor);
            target_type : Actor.Actor_Type_Id := self.actors.kinds(target);
            attacker_name : Item.Name_String := self.actor_types.names(attacker_type);
            target_name : Item.Name_String := self.actor_types.names(target_type);
         begin
            if (attacker_wins) then
               self.screen.log(attacker_name & " attacked " & target_name);
            else
               self.screen.log(target_name & " attacked " & attacker_name);
            end if;
            Display.clear;
            self.screen.draw(self.map, actor_x, actor_y);
         end;
      end if;
   end move;

   procedure teleport_player_to_cursor(self : in out Object) is
      cursor_x : Curses.Column_Position;
      cursor_y : Curses.Line_Position;
      corner_x : Display.X_Pos;
      corner_y : Display.Y_Pos;
   begin
      Display.get_cursor_position(cursor_x, cursor_y);
      self.screen.get_upper_left(corner_x, corner_y);
      cursor_x := cursor_x + corner_x;
      cursor_y := cursor_y + corner_y;

      if (cursor_x in Display.X_Pos and then cursor_y in Display.Y_Pos) then
         self.move(Actor.Player_Id, cursor_x, cursor_y);
      end if;
   end teleport_player_to_cursor;

   procedure translate_player(self : in out Object; dx : Display.X_Offset;
                              dy : Display.Y_Offset) is
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
      Display.print(0, 0, "Inventory (ESC to exit):");
      if (not found_player) then
         Display.print(0, 1, "  Empty");
      else
         declare
            curr_line : Curses.Line_Position := 1;
            curr_id : Item.Item_Id;
            curr_item_name : Item.Name_String;
            curr_item_count : Natural;
         begin
            for index in Actor.Inventory_Index range start_index .. end_index loop
               curr_id := self.items.stacks(index).id;
               curr_item_count := self.items.stacks(index).count;
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

               Display.print(0, curr_line, "  " & curr_item_name & "  " & curr_item_count'Image);
               curr_line := curr_line + 1;
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


   function melee_attack(self : in out Object;
                         attacker : Actor.Actor_Id; target : Actor.Actor_Id)
                         return Boolean is
      use Random_Battle_Value;

      target_type : Actor.Actor_Type_Id := self.actors.kinds(target);
      attacker_type : Actor.Actor_Type_Id := self.actors.kinds(attacker);

      -- TODO: account for armor/weapons in each of these cumulative stats
      target_defense : Actor.Battle_Value := self.actor_types.battle_stats(target_type).defense;
      attacker_attack : Actor.Battle_Value := self.actor_types.battle_stats(attacker_type).attack;

      -- >= midpoint: attacker wins
      -- < midpoint: defender wins
      midpoint : Actor.Battle_Value := (Actor.Battle_Value'Last + Actor.Battle_Value'First) / 2;
   begin
      -- Boost attacker's chance of winning if they have higher attack than target's defense
      -- Boost target's chance of winning if they have higher defense than attacker's attack
      midpoint := midpoint - (attacker_attack - target_defense);

      return Random(rng) >= midpoint;
   end melee_attack;

end Gameboard;
