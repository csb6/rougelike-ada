package body Display is
   package Curses renames Terminal_Interface.Curses;
   
   Min_Display_Width : constant := 30; -- in cells
   Min_Display_Height : constant := 16;
   GUI_Width : constant := 10; -- in cells
   GUI_Height : constant := 10;
   Input_Timeout : constant := 10; -- in ms
   Max_Log_Size : constant := 4; -- in number of messages
   
   -- NCurses global variables
   Cursor_Visibility : Curses.Cursor_Visibility := Curses.Invisible;
   
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
      Curses.Set_Cursor_Visibility(Cursor_Visibility);
   end Initialize;
   
   procedure Finalize(self : in out Manager) is
   begin
      Curses.End_Windows;
   end Finalize;

   
   procedure clear is
   begin
      Curses.Clear;
   end clear;

   procedure present is
   begin
      Curses.Refresh;
   end present;
   
   procedure print(column : X_Pos; row : Y_Pos; text : String) is
   begin
      Curses.Add(Column => Curses.Column_Position(column), 
                 Line => Curses.Line_Position(row),
                 Str => text);
   end print;
   
   procedure put(column : X_Pos; row : Y_Pos; letter : Character) is
   begin
      Curses.add(Column => Curses.Column_Position(column),
                 Line => Curses.Line_Position(row),
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
end Display;
