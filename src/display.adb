with Ada.Strings.Fixed;

package body Display is
   
   use type Curses.Column_Position, Curses.Line_Position;

   Min_Display_Width : constant := 24; -- in cells
   Min_Display_Height : constant := 16;
   GUI_Width : constant := 10; -- in cells
   GUI_Height : constant := 10;
   Input_Timeout : constant := 10; -- in ms
   
   -- NCurses global variables
   Current_Cursor_Visibility : Curses.Cursor_Visibility := Curses.Invisible;
   Cursor_Is_Visible : Boolean := False;
   Cursor_X : Curses.Column_Position := 0;
   Cursor_Y : Curses.Line_Position := 0;
   
   procedure Initialize(self : in out Manager) is
   begin
      Curses.Init_Screen;
      Curses.Set_Raw_Mode(True);
      Curses.Set_Echo_Mode(False);
      Curses.Set_KeyPad_Mode(SwitchOn => False);
      
      if not Curses.Has_Colors then
         raise Constraint_Error with "Terminal does not support color";
      end if;
      
      Display.hide_cursor;
   end Initialize;
   
   procedure Finalize(self : in out Manager) is
   begin
      Curses.End_Windows;
   end Finalize;

   procedure clear_char(column : Curses.Column_Position;
                        row : Curses.Line_Position) is
   begin
      Curses.add(Column => column, Line => row,
                 Ch => Item.Floor_Icon);
   end clear_char;
   
   procedure clear is
   begin
      Curses.Clear;
   end clear;

   procedure present is
   begin
      if not has_cursor then
         Curses.Refresh;
      else
         Curses.Move_Cursor(Line => Cursor_Y, Column => Cursor_X);
      end if;
   end present;
   
   procedure print(column : Curses.Column_Position; row : Curses.Line_Position;
                   text : String) is
   begin
      Curses.Add(Column => column, Line => row,
                 Str => text);
   end print;
   
   procedure show_cursor is
   begin
      Current_Cursor_Visibility := Curses.Normal;
      Curses.Set_Cursor_Visibility(Current_Cursor_Visibility);
      Curses.Move_Cursor(Line => Cursor_Y, Column => Cursor_X);
      Cursor_Is_Visible := True;
   end show_cursor;
   
   procedure hide_cursor is
   begin
      Current_Cursor_Visibility := Curses.Invisible;
      Curses.Set_Cursor_Visibility(Current_Cursor_Visibility);
      Cursor_Is_Visible := False;
   end hide_cursor;
   
   function has_cursor return Boolean is
   begin
      return Cursor_Is_Visible;
   end has_cursor;
   
   procedure move_cursor(x : Curses.Column_Position; y : Curses.Line_Position) is
   begin
      if x not in Display.X_Pos or else y not in Display.Y_Pos
        or else x >= Curses.Column_Position(Display.width) - 1
        or else y >= Curses.Line_Position(Display.height) - 1 then
         -- Don't allow out-of-bounds moves
         return;
      end if;
      Cursor_X := x;
      Cursor_Y := y;
   end move_cursor;
   
   procedure translate_cursor(dx : Curses.Column_Position;
                              dy : Curses.Line_Position) is
      new_x : Curses.Column_Position := Cursor_X + dx;
      new_y : Curses.Line_Position := Cursor_Y + dy;
   begin
      move_cursor(new_x, new_y);
   end translate_cursor;
   
   procedure get_cursor_position(x : out Curses.Column_Position;
                                 y : out Curses.Line_Position) is
   begin
      Curses.Get_Cursor_Position(Line => y, Column => x);
   end get_cursor_position;
   
   procedure put(column : Curses.Column_Position; row : Curses.Line_Position;
                 letter : Character) is
   begin
      Curses.add(Column => column, Line => row,
                 Ch => letter);
   end put;
   
   function is_large_enough return Boolean is
   begin
      return Curses.Columns >= Min_Display_Width
        and then Curses.Lines >= Min_Display_Height;
   end is_large_enough;
   
   function width return Positive is
   begin
      return Positive(Curses.Columns);
   end width;
   
   function height return Positive is
   begin
      return Positive(Curses.Lines);
   end height;
   
   -- Find map x-coordinate to place in the top-left corner of the screen
   function calculate_camera_x(player_x : X_Pos) return X_Pos is
      use Curses;
      -- The amount of width that can be used to show the map
      visible_width : Column_Position := Column_Position'Min(Map_Width, Curses.Columns - 1);
   begin
      if Column_Position(player_x) < visible_width / 2 then
         -- If player is near left edge of map, lock the camera
         return 0;
      elsif Column_Position(player_x) >= Map_Width - visible_width / 2 then
         -- If player is near right edge of map, lock the camera
         return X_Pos(Map_Width - visible_width);
      else
         -- Else, keep player in the middle of the displayed area
         return X_Pos(player_x - visible_width / 2);
      end if;
   end calculate_camera_x;
   
   -- Find map y-coordinate to place in the top-left corner of the screen
   function calculate_camera_y(player_y : Y_Pos) return Y_Pos is
      use Curses;
      -- The amount of height that can be used to show the map (with Map_Height as its max)
      visible_height : Line_Position := Line_Position'Min(Map_Height, Curses.Lines - 1);
   begin
      if Line_Position(player_y) < visible_height / 2 then
         -- If player is near top edge of map, lock the camera
         return 0;
      elsif Line_Position(player_y) >= Map_Width - visible_height / 2 then
         -- If player is near bottom edge of map, lock the camera
         return Y_Pos(Map_Width - visible_height);
      else
         -- Else, keep player in the middle of the displayed area
         return Y_Pos(Line_Position(player_y) - visible_height / 2);
      end if;
   end calculate_camera_y;
   
   function get_input return Curses.Real_Key_Code is
   begin
      return Curses.Get_Keystroke;
   end get_input;
   
   procedure draw(screen : in out Manager; map : in out Grid;
                  player_x : X_Pos; player_y : Y_Pos) is
      use Curses;
      curr_x : X_Pos := calculate_camera_x(player_x);
      curr_y : Y_Pos := calculate_camera_y(player_y);
      -- Draw as much of the grid as possible onto the screen
      screen_width : constant Column_Position := Column_Position'Min(Columns - 1, Map_Width);
      screen_height : constant Line_Position := Line_Position'Min(Lines - 1, Map_Height);
   begin
      screen.corner_x := curr_x;
      screen.corner_y := curr_y;

      for row in 0 .. screen_height - 1 loop
         for column in 0 .. screen_width - 1 loop
            put(column, row, map(row + screen.corner_y, column + screen.corner_x).icon);
         end loop;
      end loop;
   end draw;
   
   function add_padding(message : String) return Log_String is
   begin
      return Ada.Strings.Fixed.Head(message, Log_String'Length);
   end add_padding;
   
   procedure log(screen : in out Manager; message : String) is
   begin
      if screen.log_insert = screen.log'Last then
         screen.log(screen.log'First .. screen.log'Last - 1) := screen.log(screen.log'First + 1 .. screen.log'Last);
         screen.log(screen.log_insert) := add_padding(message);
      else
         screen.log(screen.log_insert) := add_padding(message);
         screen.log_insert := screen.log_insert + 1;
      end if;
   end log;
   
   procedure get_upper_left(screen : Manager; x : out X_Pos; y : out Y_Pos) is
   begin
      x := screen.corner_x;
      y := screen.corner_y;
   end get_upper_left;
end Display;
