package Item is
   subtype Name_String is String(1 .. 16);
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
   -- and others subsets are actors
   type Entity_Id is range -1 .. 125;
   No_Entity : constant Entity_Id := 0;
   Occupied_Tile : constant Entity_Id := -1;
   Floor_Icon : constant Character := '.';
   subtype Item_Id is Entity_Id range 1 .. 99;
   
   subtype Weapon_Id is Item_Id range 1 .. 50;
   subtype Melee_Weapon_Id is Weapon_Id range Weapon_Id'First .. 25;
   subtype Ranged_Weapon_Id is Weapon_Id range Melee_Weapon_Id'Last + 1 .. Weapon_Id'Last;
   subtype Armor_Id is Item_Id range Weapon_Id'Last + 1 .. Item_Id'Last;
   
   type Melee_Weapon_Type_Array is array(Melee_Weapon_Id) of Weapon_Type;
   type Ranged_Weapon_Type_Array is array(Ranged_Weapon_Id) of Weapon_Type;
   type Armor_Type_Array is array(Armor_Id) of Armor_Type;
   
   type Item_Type_Table is tagged record
      melee_weapons : Melee_Weapon_Type_Array;
      ranged_weapons : Ranged_Weapon_Type_Array;
      armor : Armor_Type_Array;
      
      melee_insert : Melee_Weapon_Id := Melee_Weapon_Id'First;
      ranged_insert : Ranged_Weapon_Id := Ranged_Weapon_Id'First;
      armor_insert : Armor_Id := Armor_Id'First;
   end record;
   
   procedure add_melee_weapon(self : in out Item_Type_Table;
                              icon : Character; name : Name_String;
                              attack : Natural);
   procedure add_ranged_weapon(self : in out Item_Type_Table;
                               icon : Character; name : Name_String;
                               attack : Natural);
   procedure add_armor(self : in out Item_Type_Table;
                       icon : Character; name : Name_String;
                       defense : Natural);

end Item;
