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
      Curses.Add(Column => Curses.Column_Count(column), 
                 Line => Curses.Line_Count(row),
                 Str => text);
   end print;
end Display;
