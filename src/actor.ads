with Item; use Item;
with Display;
with Ada.Containers.Hashed_Maps;

package Actor is
   -- These are the variable stats for each actor
   type Battle_Value is range 0 .. 50;
   subtype Attack_Value is Battle_Value;
   subtype Defense_Value is Battle_Value;
   type Energy is range 0 .. 5;
   type Health is range 0 .. 100;

   type Equip_Slot is (Head, Chest, Legs, Feet, Melee, Ranged);

   -- Represents a certain 'type' or class of Actor (e.g. Tiger)
   type Actor_Type_Id is range 0 .. 16;
   -- Represents a certain Actor instance (e.g. Tony the Tiger)
   subtype Actor_Id is Entity_Id range Item_Id'Last + 1 .. Entity_Id'Last;

   Player_Id : constant Actor_Id := Actor_Id'First;
   Player_Type_Id : constant Actor_Type_Id := Actor_Type_Id'First;


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
   type Equipment_Set is array(Actor_Id, Equip_Slot) of Boolean
     with Pack;

   type Inventory_Table is tagged record
      actor_ids : Actor_Id_Array;
      stacks : Item_Stack_Array;
      size : Inventory_Index := 0;

      equipment : Equipment_Set;
   end record;
   function find_range(self : Inventory_Table; actor : Actor_Id;
                       first : out Inventory_Index; last : out Inventory_Index)
                       return Boolean;
   procedure add_stack(self : in out Inventory_Table;
                       actor : Actor_Id; item : Item_Id;
                       count : Natural)
     with Pre => self.size < self.actor_ids'Last;


   type Icon_Array is array(Actor_Type_Id) of Character;
   type Icon_To_Actor_Map is array(Character) of Actor_Type_Id;
   type Name_Array is array(Actor_Type_Id) of Name_String;
   type Energy_Array is array(Actor_Type_Id) of Energy;
   type Battle_Stats_Array is array(Actor_Type_Id) of Battle_Stats;

   type Actor_Type_Table is tagged record
      icons : Icon_Array;
      names : Name_Array;
      energies : Energy_Array;
      battle_stats : Battle_Stats_Array;

      size : Actor_Type_Id := 0;
   end record;
   package Icon_ActorType_Map is new Ada.Containers.Hashed_Maps(Character, Actor_Type_Id, Item.hash, "=");
   procedure add(self : in out Actor_Type_Table;
                 icon : Character;
                 name : Name_String;
                 energy_val : Energy := Energy'Last;
                 stats : Battle_Stats)
     with Pre => self.size < self.icons'Last + 1;
   procedure make_lookup_map(self : Actor_Type_Table; table : out Icon_ActorType_Map.Map);

   type Actor_Type_Array is array(Actor_Id) of Actor_Type_Id;
   type Actor_Position_Array is array(Actor_Id) of Position;
   type Actor_Health_Array is array(Actor_Id) of Health;

   type Actor_Table is tagged record
      kinds : Actor_Type_Array;
      positions : Actor_Position_Array;
      healths : Actor_Health_Array;

      insert : Actor_Id := Actor_Id'First;
   end record;
   function add(self : in out Actor_Table;
                kind : Actor_Type_Id;
                pos : Position; hp : Health) return Actor_Id;

   procedure add(self : in out Actor_Table;
                 kind : Actor_Type_Id;
                 pos : Position;
                 hp : Health);
   function player_position(self : Actor_Table) return Position
     with Inline => True;
end Actor;
