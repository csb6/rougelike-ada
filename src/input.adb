with Display;
with Terminal_Interface.Curses_Constants;

package body Input is
   package Curses renames Terminal_Interface.Curses_Constants;
   
   function handle(board : in out Gameboard.Object) return Boolean is
      use all type Display.X_Offset, Display.Y_Offset;
   begin
      case Display.get_input is
         when Display.Key_Ctrl_X | Display.Key_Ctrl_C =>
            -- Exit the game
            return False;
         when Curses.Key_Up    => board.translate_player(0, -1);
         when Curses.Key_Down  => board.translate_player(0, 1);
         when Curses.Key_Right => board.translate_player(1, 0);
         when Curses.Key_Left  => board.translate_player(-1, 0);
         when Curses.Key_Resize | Curses.Key_Backspace | Display.Key_Backspace_2 =>
            board.redraw;
         when Character'Pos('i') =>
            board.show_inventory;
         when others =>
            null;
      end case;
      
      return True;
   end handle;

end Input;
