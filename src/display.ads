with Ada.Finalization;
with Terminal_Interface.Curses;
with Item;

package Display is
   package Curses renames Terminal_Interface.Curses;
   
   -- Acts as Scope Guard; sets-up/cleans-up ncurses, and caches some state
   -- about the screen
   type Manager is new Ada.Finalization.Controlled with private;
   
   Map_Width : constant := 30; -- in cells
   Map_Height : constant := 30;
   type X_Pos is new Terminal_Interface.Curses.Column_Position range 0 .. Map_Width;
   type Y_Pos is new Terminal_Interface.Curses.Line_Position range 0 .. Map_Height;
   
   subtype Log_String is String(1 .. 16);
   
   type Cell is record
      -- The ASCII character displayed on the terminal grid
      icon : Character := Item.Floor_Icon;
      -- Holds an actor or some type of item
      entity : Item.Entity_Id := Item.No_Entity;
   end record;
   type Grid is array(Y_Pos, X_Pos) of Cell;
   
   procedure clear;
   procedure present;
   procedure print(column : Curses.Column_Position; row : Curses.Line_Position;
                   text : String);
   
   procedure show_cursor;
   procedure hide_cursor;
   function has_cursor return Boolean;
   procedure move_cursor(column : Curses.Column_Position;
                         row : Curses.Line_Position);
   procedure translate_cursor(dx : Curses.Column_Position;
                              dy : Curses.Line_Position);
   
   function is_large_enough return Boolean;
   procedure log(message : Log_String);
   function get_input return Curses.Real_Key_Code;
private
   Max_Log_Size : constant := 4; -- in number of messages
   type Log_Array is array(0 .. Max_Log_Size - 1) of Log_String;
   
   type Manager is new Ada.Finalization.Controlled with record
      corner_x : X_Pos := 0;
      corner_y : Y_Pos := 0;
      
      log : Log_Array;
   end record;
   -- Setup ncurses
   overriding procedure Initialize(self : in out Manager);
   -- Cleanup ncurses so that terminal emulator goes back to normal
   overriding procedure Finalize(self : in out Manager);
end Display;
