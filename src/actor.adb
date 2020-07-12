package body Actor is

   procedure add_stack(self : in out Inventory_Table;
                       actor : Actor_Id; item : Item_Id;
                       count : Natural) is
      -- The first element of the actor's sub-range
      start_index : Inventory_Index := self.size;
      -- The last element of the actor's sub-range
      end_index : Inventory_Index := self.size;
      found_start : Boolean := False;
      insert_index : Inventory_Index;
   begin
      if (self.size /= 0) then
         -- Only search if anything exists to search through
         Search_Loop:
         -- Find the bounds of the actor's sub-range
         for index in Inventory_Index range self.actor_ids'First..self.size loop
            if (not found_start and then self.actor_ids(index) = actor) then
               start_index := index;
               found_start := True;
            elsif (found_start and then self.actor_ids(index) /= actor) then
               end_index := index;
               exit Search_Loop;
            end if;
         end loop Search_Loop;
      end if;

      insert_index := start_index;

      -- Check if there is an existing stack for the given item for this actor
      for index in Inventory_Index range start_index..end_index loop
         if (self.stacks(index).id = item) then
            -- Stack already exists for this actor, just add to it, stop
            self.stacks(index).count := self.stacks(index).count + count;
            return;
         end if;
         insert_index := index;
      end loop;

      -- If no stack found, insert the new item, updating all rows of the table
      self.stacks(insert_index+1..self.size+1) := self.stacks(insert_index..self.size);
      self.stacks(insert_index) := (id => item, count => count);
      self.actor_ids(insert_index+1..self.size+1) := self.actor_ids(insert_index..self.size);
      self.actor_ids(insert_index) := actor;

      self.size := self.size + 1;
   end add_stack;


   procedure add(self : in out Actor_Type_Table; icon : Character;
                 name : Name_String; energy_val : Energy; stats : Battle_Stats) is
   begin
      self.icons(self.size) := icon;
      self.names(self.size) := name;
      self.energies(self.size) := energy_val;
      self.battle_stats(self.size) := stats;

      self.size := self.size + 1;
   end add;
     
end Actor;
