package body Item is
   function add_padding(name : String) return Name_String is
      result : Name_String := Ada.Strings.Fixed.Head(name, Name_String'Length);
   begin
      return result;
   end add_padding;


end Item;
