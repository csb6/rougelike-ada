with Actor;
with Display;
with Gameboard;
with Input;

procedure Rougelike is
   board : Gameboard.Object;
begin
   Gameboard.make(board);

   Display.present;
   while(Input.handle(board)) loop
      Display.present;
   end loop;
end Rougelike;
