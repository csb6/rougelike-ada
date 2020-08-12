package body Actor is
   
   function find_range(self : Inventory_Table; actor : Actor_Id;
                       first : out Inventory_Index; last : out Inventory_Index)
                       return Boolean is
      found_first : Boolean := False;
   begin
      first := Inventory_Index'First;
      last := Inventory_Index'First;
      
      -- Only search if anything exists to search through
      if (self.size = 0) then
         return False;
      end if;

      Search_Loop:
      -- Find the bounds of the actor's sub-range
      for index in Inventory_Index range self.actor_ids'First .. self.size loop
         if (not found_first and then self.actor_ids(index) = actor) then
            first := index;
            found_first := True;
         elsif (found_first and then self.actor_ids(index) /= actor) then
            last := index - 1;
            exit Search_Loop;
         end if;
      end loop Search_Loop;

      return found_first;
   end find_range;

   procedure add_stack(self : in out Inventory_Table;
                       actor : Actor_Id; item : Item_Id;
                       count : Natural) is
      -- The first element of the actor's sub-range
      start_index : Inventory_Index;
      -- The last element of the actor's sub-range
      end_index : Inventory_Index;
      insert_index : Inventory_Index;
      found_actor : Boolean;
   begin
      found_actor := self.find_range(actor, start_index, end_index);
      insert_index := start_index;

      if (found_actor) then
         -- Check if there is an existing stack for the given item for this actor
         for index in Inventory_Index range start_index .. end_index loop
            if (self.stacks(index).id = item) then
               -- Stack already exists for this actor, just add to it, stop
               self.stacks(index).count := self.stacks(index).count + count;
               return;
            end if;
            insert_index := index;
         end loop;
      end if;

      -- If no stack found/no actor found, insert the new item, updating all rows of the table
      self.stacks(insert_index+1..self.size+1) := self.stacks(insert_index..self.size);
      self.stacks(insert_index) := (id => item, count => count);
      self.actor_ids(insert_index+1..self.size+1) := self.actor_ids(insert_index..self.size);
      self.actor_ids(insert_index) := actor;

      self.size := self.size + 1;
   end add_stack;


   procedure add(self : in out Actor_Type_Table;
                 icon : Character;
                 name : Name_String;
                 energy_val : Energy := Energy'Last;
                 stats : Battle_Stats) is
   begin
      self.icons(self.size) := icon;
      self.names(self.size) := name;
      self.energies(self.size) := energy_val;
      self.battle_stats(self.size) := stats;

      self.size := self.size + 1;
   end add;
   
   procedure add(self : in out Actor_Table;
                 kind : Actor_Type_Id;
                 pos : Position; hp : Health) is
   begin
      self.kinds(self.insert) := kind;
      self.positions(self.insert) := pos;
      self.healths(self.insert) := hp;
      
      self.insert := self.insert + 1;
   end add;
   
   function player_position(self : in out Actor_Table) return Position is
   begin
      return self.positions(Player_Id);
   end player_position;
     
end Actor;
