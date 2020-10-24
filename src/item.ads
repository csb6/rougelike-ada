with Ada.Containers.Hashed_Maps;

package Item is
   subtype Name_String is String(1 .. 16);
   -- Strings have to have a length of exactly 16, so this function
   -- adds any needed padding and removes any characters exceeding the limit
   function add_padding(name : String) return Name_String;

   type Weapon_Type is record
     icon : Character;
     name : Name_String;
     attack : Natural;
   end record;

   type Armor_Type is record
      icon : Character;
      name : Name_String;
      defense : Natural;
   end record;

   -- A range of id values; certain subsets are various types of items
   -- and other subsets are actors
   type Entity_Id is range -1 .. 125;
   No_Entity : constant Entity_Id := 0;
   Occupied_Tile : constant Entity_Id := -1;
   Floor_Icon : constant Character := '.';
   subtype Item_Id is Entity_Id range 1 .. 99;
   
   subtype Weapon_Id is Item_Id range Item_Id'First .. 50;
   subtype Melee_Weapon_Id is Weapon_Id range Weapon_Id'First .. 25;
   subtype Ranged_Weapon_Id is Weapon_Id range Melee_Weapon_Id'Last + 1 .. Weapon_Id'Last;
   subtype Armor_Id is Item_Id range Weapon_Id'Last + 1 .. Item_Id'Last;
   
   type Weapon_Type_Array is array(Weapon_Id range <>) of Weapon_Type;
   subtype Melee_Weapon_Type_Array is Weapon_Type_Array (Melee_Weapon_Id);
   subtype Ranged_Weapon_Type_Array is Weapon_Type_Array (Ranged_Weapon_Id);
   type Armor_Type_Array is array(Armor_Id) of Armor_Type;
   
   function hash(k : Character) return Ada.Containers.Hash_Type is (Ada.Containers.Hash_Type(Character'Pos(k)));
   package Icon_Entity_Map is new Ada.Containers.Hashed_Maps(Key_Type        => Character,
                                                             Element_Type    => Entity_Id,
                                                             Hash            => hash,
                                                             Equivalent_Keys => "=");
   
   type Item_Type_Table is tagged record
      melee_weapons : Melee_Weapon_Type_Array;
      ranged_weapons : Ranged_Weapon_Type_Array;
      armor : Armor_Type_Array;
      
      melee_insert : Melee_Weapon_Id := Melee_Weapon_Id'First;
      ranged_insert : Ranged_Weapon_Id := Ranged_Weapon_Id'First;
      armor_insert : Armor_Id := Armor_Id'First;
   end record;
   
   procedure make_lookup_map(self : Item_Type_Table; table : out Icon_Entity_Map.Map);
   
   -- Add new types of items
   procedure add_melee_weapon(self : in out Item_Type_Table;
                              icon : Character; name : Name_String;
                              attack : Natural);
   procedure add_ranged_weapon(self : in out Item_Type_Table;
                               icon : Character; name : Name_String;
                               attack : Natural);
   procedure add_armor(self : in out Item_Type_Table;
                       icon : Character; name : Name_String;
                       defense : Natural);
      
  private

end Item;
