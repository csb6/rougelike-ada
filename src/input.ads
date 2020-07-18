with Gameboard;

package Input is
   
   -- Returns false if the game needs to terminate, else is True
   -- Blocks on user input
   function handle(board : in out Gameboard.Object) return Boolean;

end Input;
