with Item; use Item;
with Display;

package Actor is
   -- These are the variable stats for each actor
   type Attack_Value is range 0 .. 50;
   type Defense_Value is range 0 .. 50;
   type Energy is range 0 .. 5;
   type Health is range 0 .. 100;

   type Equip_Slot is (Head, Chest, Legs, Feet, Melee, Ranged);

   -- Represents a certain 'type' or class of Actor (e.g. Tiger)
   type Actor_Type_Id is range 0 .. 15;
   -- Represents a certain Actor instance (e.g. Tony the Tiger)
   subtype Actor_Id is Entity_Id range Item_Id'Last + 1 .. Entity_Id'Last;
   -- The player is their own type and instance. Both are at index 0
   -- in their respective arrays
   Player_Id : constant Actor_Id := Actor_Id'First;
   Player_Type_id : constant Actor_Type_Id := Actor_Type_Id'First;


   type Battle_Stats is record
      attack : Attack_Value;
      ranged_attack : Attack_Value;
      defense : Defense_Value;
   end record;

   type Position is record
      x : Display.X_Pos;
      y : Display.Y_Pos;
   end record;

   -- Each index is a homogenous stack of some entity's items
   subtype Inventory_Index is Natural range 0 .. 50;
   type Item_Stack is record
      id : Item_Id;
      count : Natural;
   end record;
   type Actor_Id_Array is array(Inventory_Index) of Actor_Id;
   type Item_Stack_Array is array(Inventory_Index) of Item_Stack;
   type Equipment_Set is array(Actor_Id, Equip_Slot) of Boolean;
   pragma Pack (Equipment_Set); -- To make Equipment_Set a bitset

   type Inventory_Table is tagged record
      actor_ids : Actor_Id_Array;
      stacks : Item_Stack_Array;
      size : Inventory_Index := 0;

      equipment : Equipment_Set;
   end record;
   
   procedure add_stack(self : in out Inventory_Table;
                       actor : Actor_Id; item : Item_Id;
                       count : Natural)
     with Pre => self.size < self.actor_ids'Last + 1;


   type Icon_Array is array(Actor_Type_Id) of Character;
   type Name_Array is array(Actor_Type_Id) of Name_String;
   type Energy_Array is array(Actor_Type_Id) of Energy;
   type Battle_Stats_Array is array(Actor_Type_Id) of Battle_Stats;

   type Actor_Type_Table is tagged record
      icons : Icon_Array;
      names : Name_Array;
      energies : Energy_Array;
      battle_stats : Battle_Stats_Array;

      size : Actor_Type_Id := Actor_Type_Id'First;
   end record;
   
   procedure add(self : in out Actor_Type_Table; icon : Character;
                 name : Name_String; energy_val : Energy; stats : Battle_Stats)
     with Pre => self.size < self.icons'Last + 1;


   type Actor_Type_Array is array(Actor_Id) of Actor_Type_Id;
   type Actor_Position_Array is array(Actor_Id) of Position;
   type Actor_Health_Array is array(Actor_Id) of Health;

   type Actor_Table is tagged record
      kinds : Actor_Type_Array;
      positions : Actor_Position_Array;
      healths : Actor_Health_Array;

      size : Actor_Id := Actor_Id'First;
   end record;

   procedure add(self : in out Actor_Table; kind : Actor_Type_Id;
                 pos : Position; hp : Health);
   function player_position(self : in out Actor_Table) return Position;
end Actor;
