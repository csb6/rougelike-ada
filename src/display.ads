with Ada.Finalization;
with Terminal_Interface.Curses;
with Item;

package Display is
   
   -- Acts as Scope Guard; sets-up/cleans-up ncurses
   type Manager is new Ada.Finalization.Controlled with private;
   
   Map_Width : constant := 30; -- in cells
   Map_Height : constant := 30;
   subtype X_Pos is Terminal_Interface.Curses.Column_Position range 0 .. Map_Width;
   subtype Y_Pos is Terminal_Interface.Curses.Line_Position range 0 .. Map_Height;
   
   type Cell is record
      -- The ASCII character displayed on the terminal grid.
      icon : Character := '.';
      -- Holds an actor or some type of item
      entity : Item.Entity_Id := Item.No_Entity;
   end record;
   
   procedure clear;
   procedure present;
   procedure print(column : X_Pos; row : Y_Pos; text : String);
private
   type Manager is new Ada.Finalization.Controlled with null record;
   -- Setup ncurses
   overriding procedure Initialize(self : in out Manager);
   -- Cleanup ncurses so that terminal emulator goes back to normal
   overriding procedure Finalize(self : in out Manager);
end Display;
