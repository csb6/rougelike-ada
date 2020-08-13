with Ada.Text_IO;
with Config;

package body Gameboard.Data is
   
   use type Item.Weapon_Id, Display.Y_Pos, Display.X_Pos;

   procedure load_map(self : in out Object; path : String) is
      map_file : Ada.Text_IO.File_Type;
      curr_row : Display.Y_Pos := Display.Y_Pos'First;
      curr_column : Display.X_Pos := Display.X_Pos'First;
   begin
      Ada.Text_IO.Open(map_file, Ada.Text_IO.In_File, path);

      Line_Loop:
      while (not Ada.Text_IO.End_Of_File(map_file)) loop
         declare
            file_line : constant String := Ada.Text_IO.Get_Line(map_file);
            -- Holds a potential match when trying to find what item type/
            -- actor type each letter represents
            entity_id : Item.Entity_Id;
         begin
            curr_column := Display.X_Pos'First;
            
            Column_Loop:
            for letter of file_line loop
               if (letter /= Item.Floor_Icon) then
                  -- See if the letter represents some kind of item
                  entity_id := self.item_types.find_id(letter);
                  if (entity_id /= Item.No_Entity) then
                     -- Letter represents a known item type
                     self.map(curr_row, curr_column).entity := entity_id;
                     self.map(curr_row, curr_column).icon := letter;
                  end if;
               end if;

               exit Column_Loop when curr_column + 1 not in Display.X_Pos;
               curr_column := curr_column + 1;
            end loop Column_Loop;
         end;

         exit Line_Loop when curr_row + 1 not in Display.Y_Pos;
         curr_row := curr_row + 1;
      end loop Line_Loop;
   end load_map;

   procedure load_actor_types(self : in out Object; path : String) is
      type_file : Config.Configuration;
      sections : Config.Section_List;

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

   procedure load_weapon_types(weapon_list : in out Item.Weapon_Type_Array;
                               path : String) is
      type_file : Config.Configuration;
      sections : Config.Section_List;
      insert_index : Item.Weapon_Id := weapon_list'First;

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

   procedure load_armor_types(self : in out Object; path : String) is
      type_file : Config.Configuration;
      sections : Config.Section_List;

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

end Gameboard.Data;
