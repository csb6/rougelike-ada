with Ada.Finalization;
with Terminal_Interface.Curses;
with Item;

--TODO:
--Consider breaking Grid into SoA (for icon and for Entity)
--since characters in Grid could be a 2D array of chars, making cache usage
--better. Also the icon and Entity are not going to be accessed often together 

package Display is
   package Curses renames Terminal_Interface.Curses;
   
   -- Acts as Scope Guard; sets-up/cleans-up ncurses, and caches some state
   -- about the screen
   type Manager is new Ada.Finalization.Controlled with private;
   
   Map_Width : constant := 30; -- in cells
   Map_Height : constant := 30;
   use all type Curses.Column_Position, Curses.Line_Position;
   subtype X_Offset is Curses.Column_Position range -Map_Width .. Map_Width;
   subtype Y_Offset is Curses.Line_Position range -Map_Height .. Map_Height;
   subtype X_Pos is X_Offset range 0 .. X_Offset'Last;
   subtype Y_Pos is Y_Offset range 0 .. Y_Offset'Last;
   
   subtype Log_String is String(1 .. 16);
   
   -- Some keycodes that NCurses doesn't define
   -- Probably not portable on every terminal
   -- Obtain ctrl keys by calculating `[character's ASCII code] & 0x1F`
   Key_Ctrl_X : constant := 24;
   Key_Ctrl_C : constant := 3;
   Key_Backspace_2 : constant := 127; -- for macOS
   Key_Escape : constant := 27;
   
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
   function width return Positive;
   function height return Positive;
   function get_input return Curses.Real_Key_Code;
   
   procedure draw(screen : in out Manager; map : in out Grid;
                  player_x : X_Pos; player_y : Y_Pos);
   procedure log(screen : in out Manager; message : String);
private
   Max_Log_Size : constant := 4; -- in number of messages
   type Log_Index is range 0 .. Max_Log_Size - 1;
   type Log_Array is array(Log_Index) of Log_String;
   
   type Manager is new Ada.Finalization.Controlled with record
      corner_x : X_Pos := 0;
      corner_y : Y_Pos := 0;
      
      log : Log_Array;
      log_insert : Log_Index := Log_Index'First;
   end record;
   -- Setup ncurses
   overriding procedure Initialize(self : in out Manager);
   -- Cleanup ncurses so that terminal emulator goes back to normal
   overriding procedure Finalize(self : in out Manager);
end Display;
