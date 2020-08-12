with Ada.Strings.Fixed;

package body Item is
   function add_padding(name : String) return Name_String is
      result : Name_String := Ada.Strings.Fixed.Head(name, Name_String'Length);
   begin
      return result;
   end add_padding;



   function find_id(self : in Item_Type_Table; icon : Character) return Entity_Id is
   begin
      for id in Melee_Weapon_Id'First .. self.melee_insert loop
         if (self.melee_weapons(id).icon = icon) then
            return id;
         end if;
      end loop;

      for id in Ranged_Weapon_Id'First .. self.ranged_insert loop
         if (self.ranged_weapons(id).icon = icon) then
            return id;
         end if;
      end loop;

      for id in Armor_Id'First .. self.armor_insert loop
         if (self.armor(id).icon = icon) then
            return id;
         end if;
      end loop;

      return No_Entity;
   end find_id;


   procedure add_melee_weapon(self : in out Item_Type_Table;
                              icon : Character; name : Name_String;
                              attack : Natural) is
   begin
      self.melee_weapons(self.melee_insert) := (icon, name, attack);
      self.melee_insert := self.melee_insert + 1;
   end add_melee_weapon;

   procedure add_ranged_weapon(self : in out Item_Type_Table;
                               icon : Character; name : Name_String;
                               attack : Natural) is
   begin
      self.ranged_weapons(self.ranged_insert) := (icon, name, attack);
      self.ranged_insert := self.ranged_insert + 1;
   end add_ranged_weapon;

   procedure add_armor(self : in out Item_Type_Table;
                       icon : Character; name : Name_String;
                       defense : Natural) is
   begin
      self.armor(self.armor_insert) := (icon, name, defense);
      self.armor_insert := self.armor_insert + 1;
   end add_armor;

end Item;
