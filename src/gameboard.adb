package body Gameboard is

   procedure make(self : in out Object) is
   begin
      self.actor_types.add(icon       => '@',
                           name       => Item.add_padding("Player"),
                           energy_val => 3,
                           stats      => (1, 1, 1));

      self.actors.add(kind => Actor.Player_Type_id,
                      pos  => (0, 0),
                      hp   => 10);
   end make;

end Gameboard;
