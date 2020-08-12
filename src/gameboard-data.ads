package Gameboard.Data is
   -- Given a plaintext file of characters, fills in the gameboard grid,
   -- matching the character at each position to the item/monster it represents
   procedure load_map(self : in out Object; path : String);
   
   -- Get a list of actor "types" (kinds of actors) from an .INI file
   -- and add them to self.actor_types, where they can be used as templates
   -- for individual actors. Expects the player actor type to be already added
   procedure load_actor_types(self : in out Object; path : String);
   
   -- Get a list of weapon item types from an .INI file and adds them to an array.
   -- Intended to be used either with Gameboard.Object.item_types.melee_weapons or
   -- Gameboard.Object.item_types.ranged_weapons, so it is not directly coupled to the
   -- Gameboard.Object type directly.
   procedure load_weapon_types(weapon_list : in out Item.Weapon_Type_Array;
                               path : String);
   
   -- Get a list of armor item types from an .INI file and adds them to
   -- Gameboard.Object.item_types.armor
   procedure load_armor_types(self : in out Object; path : String);
end Gameboard.Data;
