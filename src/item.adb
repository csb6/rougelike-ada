with Ada.Strings.Fixed;

package body Item is
   function add_padding(name : String) return Name_String is
      result : Name_String := Ada.Strings.Fixed.Head(name, Name_String'Length);
   begin
      return result;
   end add_padding;


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
