with Ada.Finalization;
with Terminal_Interface.Curses;
with Item;

package Display is
   
   -- Acts as Scope Guard; sets-up/cleans-up ncurses, and caches some state
   -- about the screen
   type Manager is new Ada.Finalization.Controlled with private;
   
   Map_Width : constant := 30; -- in cells
   Map_Height : constant := 30;
   type X_Pos is new Terminal_Interface.Curses.Column_Position range 0 .. Map_Width;
   type Y_Pos is new Terminal_Interface.Curses.Line_Position range 0 .. Map_Height;
   
   type Cell is record
      -- The ASCII character displayed on the terminal grid.
      icon : Character := '.';
      -- Holds an actor or some type of item
      entity : Item.Entity_Id := Item.No_Entity;
   end record;
   
   procedure clear;
   procedure present;
   procedure print(column : X_Pos; row : Y_Pos; text : String);
   function is_large_enough return Boolean;
private
   type Manager is new Ada.Finalization.Controlled with record
      corner_x : X_Pos := 0;
      corner_y : Y_Pos := 0;
   end record;
   -- Setup ncurses
   overriding procedure Initialize(self : in out Manager);
   -- Cleanup ncurses so that terminal emulator goes back to normal
   overriding procedure Finalize(self : in out Manager);
end Display;
