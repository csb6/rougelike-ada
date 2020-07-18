with Actor;
with Display;
with Gameboard;
with Input;

procedure Rougelike is
   screen : Display.Manager;
   board : Gameboard.Object;
begin
   Gameboard.make(board);

   Display.clear;
   while(Input.handle(board)) loop
      null;
   end loop;
end Rougelike;
