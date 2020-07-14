package body Display is

   Min_Display_Width : constant := 30; -- in cells
   Min_Display_Height : constant := 16;
   GUI_Width : constant := 10; -- in cells
   GUI_Height : constant := 10;
   Input_Timeout : constant := 10; -- in ms
   
   -- NCurses global variables
   Current_Cursor_Visibility : Curses.Cursor_Visibility := Curses.Invisible;
   
   procedure Initialize(self : in out Manager) is
   begin
      Curses.Init_Screen;
      Curses.Set_Raw_Mode(True);
      Curses.Set_Echo_Mode(False);
      Curses.Set_KeyPad_Mode(SwitchOn => True);
      
      if (not Curses.Has_Colors) then
         raise Constraint_Error with "Terminal does not support color";
      end if;
      
      Curses.Move_Cursor(Line => 0, Column => 0);
      Curses.Set_Cursor_Visibility(Current_Cursor_Visibility);
   end Initialize;
   
   procedure Finalize(self : in out Manager) is
   begin
      Curses.End_Windows;
   end Finalize;

   procedure clear_char(column : Curses.Column_Position;
                        row : Curses.Line_Position) is
   begin
      Curses.add(Column => column,
                 Line => row,
                 Ch => Item.Floor_Icon);
   end clear_char;
   
   procedure clear is
   begin
      Curses.Clear;
   end clear;

   procedure present is
   begin
      Curses.Refresh;
   end present;
   
   procedure print(column : Curses.Column_Position; row : Curses.Line_Position;
                   text : String) is
   begin
      Curses.Add(Column => column, 
                 Line => row,
                 Str => text);
   end print;
   
   procedure show_cursor is
   begin
      Current_Cursor_Visibility := Curses.Normal;
      Curses.Set_Cursor_Visibility(Current_Cursor_Visibility);
   end show_cursor;
   
   procedure hide_cursor is
   begin
      Current_Cursor_Visibility := Curses.Invisible;
      Curses.Set_Cursor_Visibility(Current_Cursor_Visibility);
   end hide_cursor;
   
   function has_cursor return Boolean is
      use Curses;
   begin
      return Current_Cursor_Visibility = Curses.Normal;
   end has_cursor;
   
   procedure move_cursor(column : Curses.Column_Position;
                         row : Curses.Line_Position) is
   begin
      Curses.Move_Cursor(Line   => row,
                         Column => column);
   end move_cursor;
   
   procedure translate_cursor(dx : Curses.Column_Position;
                              dy : Curses.Line_Position) is
      use Curses;
      current_x : Curses.Column_Position := 0;
      current_y : Curses.Line_Position := 0;
   begin
      Curses.Get_Cursor_Position(Line => current_y,
                                 Column => current_x);
      Curses.Move_Cursor(Line   => current_y + dy,
                         Column => current_x + dx);
   end translate_cursor;
   
   procedure put(column : Curses.Column_Position; row : Curses.Line_Position;
                 letter : Character) is
   begin
      Curses.add(Column => column,
                 Line => row,
                 Ch => letter);
   end put;
   
   function is_large_enough return Boolean is
      use Curses; -- To make operators visible for Columns/Lines
   begin
      return Curses.Columns >= Min_Display_Width
        and then Curses.Lines >= Min_Display_Height;
   end is_large_enough;
   
-- Find map x-coordinate to place in the top-left corner of the screen
   function calculate_camera_x(player_x : X_Pos) return X_Pos is
      use Curses;
      -- The amount of width that can be used to show the map (with Map_Width as its max)
      visible_width : Column_Position := Column_Position'Min(Map_Width, Curses.Columns);
   begin
      if (Column_Position(player_x) < visible_width / 2) then
         -- If player is near left edge of map, lock the camera
         return 0;
      elsif (Column_Position(player_x) >= Map_Width - visible_width / 2) then
         -- If player is near right edge of map, lock the camera
         return X_Pos(Map_Width - visible_width);
      else
         -- Else, keep player in the middle of the displayed area
         return X_Pos(Column_Position(player_x) - visible_width / 2);
      end if;
   end calculate_camera_x;
   
-- Find map y-coordinate to place in the top-left corner of the screen
   function calculate_camera_y(player_y : Y_Pos) return Y_Pos is
      use Curses;
      -- The amount of height that can be used to show the map (with Map_Height as its max)
      visible_height : Line_Position := Line_Position'Min(Map_Height, Curses.Lines);
   begin
      if (Line_Position(player_y) < visible_height / 2) then
         -- If player is near top edge of map, lock the camera
         return 0;
      elsif (Line_Position(player_y) >= Map_Width - visible_height / 2) then
         -- If player is near bottom edge of map, lock the camera
         return Y_Pos(Map_Width - visible_height);
      else
         -- Else, keep player in the middle of the displayed area
         return Y_Pos(Line_Position(player_y) - visible_height / 2);
      end if;
   end calculate_camera_y;
   
   procedure log(message : Log_String) is
   begin
      print(0, 0, message);
   end log;
   
   function get_input return Curses.Real_Key_Code is
   begin
      return Curses.Get_Keystroke;
   end get_input;
end Display;
