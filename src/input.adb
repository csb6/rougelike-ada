with Display;

package body Input is
   
   function handle(board : in out Gameboard.Object) return Boolean is
   begin
      case Display.get_input is
         when Display.Key_Ctrl_X | Display.Key_Ctrl_C =>
            -- Exit the game
            return False;
         when others =>
            null;
      end case;
      
      return True;
   end handle;

end Input;
