

package Item is
   type Name_String is new String(1 .. 16);

   type Weapon_Type is record
     name : Name_String;
     icon : Character;
     attack : Natural;
   end record;

   type Armor_Type is record
      name : Name_String;
      icon : Character;
      defense : Natural;
   end record;

   type Item_Id is range 0 .. 100;
   No_Item : constant Item_Id := 0;
   
   subtype Weapon_Id is Item_Id range 1 .. 50;
   subtype Melee_Weapon_Id is Weapon_Id range 1 .. 25;
   subtype Ranged_Weapon_Id is Weapon_Id range 26 .. Weapon_Id'Last;
   subtype Armor_Id is Item_Id range 51 .. Item_Id'Last;
   
   type Melee_Weapon_Type_Array is array(Melee_Weapon_Id) of Weapon_Type;
   type Ranged_Weapon_Type_Array is array(Ranged_Weapon_Id) of Weapon_Type;
   type Armor_Type_Array is array(Armor_Id) of Armor_Type;
   
   type Item_Type_Table is record
      melee_weapons : Melee_Weapon_Type_Array;
      ranged_weapons : Ranged_Weapon_Type_Array;
      armor : Armor_Type_Array;
   end record;

end Item;
