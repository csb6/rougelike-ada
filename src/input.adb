with Display, Actor;
with Terminal_Interface.Curses_Constants;

package body Input is
   package Curses renames Terminal_Interface.Curses_Constants;
   
   function handle(board : in out Gameboard.Object) return Boolean is
      use type Display.X_Offset, Display.Y_Offset;
      
      procedure make_move(dx : Display.X_Offset; dy : Display.Y_Offset) is
      begin
         if (Display.has_cursor) then
            Display.translate_cursor(dx, dy);
         else
            board.translate_player(dx, dy);
         end if;
      end make_move;
   begin
      case Display.get_input is
         when Display.Key_Ctrl_X | Display.Key_Ctrl_C =>
            -- Exit the game
            return False;
         when Character'Pos('w') => make_move(0, -1);
         when Character'Pos('s') => make_move(0, 1);
         when Character'Pos('d') => make_move(1, 0);
         when Character'Pos('a') => make_move(-1, 0);
         when Character'Pos('t') =>
            if (not Display.has_cursor) then
               declare
                  player_pos : Actor.Position := board.player_position;
                  corner_x : Display.X_Pos;
                  corner_y : Display.Y_Pos;
               begin
                  board.get_upper_left(corner_x, corner_y);
                  Display.move_cursor(player_pos.x - corner_x, player_pos.y - corner_y);
                  Display.show_cursor;
               end;
            else
               board.teleport_player_to_cursor;
               Display.hide_cursor;
            end if;
         when Curses.Key_Resize | Display.Key_Escape =>
            board.redraw;
            Display.hide_cursor;
         when Character'Pos('i') =>
            board.show_inventory;
         when others =>
            null;
      end case;
      
      return True;
   end handle;

end Input;
