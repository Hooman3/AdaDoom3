
--                                                                                                                                      --
--                                                         N E O  E N G I N E                                                           --
--                                                                                                                                      --
--                                                 Copyright (C) 2016 Justin Squirek                                                    --
--                                                                                                                                      --
-- Neo is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the --
-- Free Software Foundation, either version 3 of the License, or (at your option) any later version.                                    --
--                                                                                                                                      --
-- Neo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of                --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.                            --
--                                                                                                                                      --
-- You should have received a copy of the GNU General Public License along with Neo. If not, see gnu.org/licenses                       --
--                                                                                                                                      --

-- Isolate parsers for different model formats into separate packages and consolidate them here
package body Neo.Data.Model is

  -----------------
  -- Conversions --
  -----------------

  function To_Joint_Name (Val : Str_Unbound) return Str_8 is
    Name : Str_8 (1..32) := (others => NULL_CHAR_8);
    begin
      Debug_Assert (Length (Val) <= 32);    
      for I in Name'First..Length (Val) loop Name (I) := To_Char_8 (Element (Val, I)); end loop;
      return Name;
    end;
  function To_Triangles (Polygon : Vector_Int_32_Natural.Unsafe.Vector) return Vector_Int_32_Unsigned.Unsafe.Vector is
    Result : Vector_Int_32_Unsigned.Unsafe.Vector;
    begin
      --return Result; -- 0 (i) (i + 1)  [for i in 1..(n - 2)] --0 1 2 --0 2 3
      --for I in 0..Patch_Height loop
      --  for J in 1..Patch_Width loop
      --    Triangle := (if J mod 2 = 0 then (I * Patch_Width + J - 1, I * Patch_Width + J, (I + 1) * Patch_Width + J - 1)
      --                 else (I * Patch_Width + J - 1, (I + 1) * Patch_Width + J - 2, (I + 1) * Patch_Width + J - 1));
      --  end loop;
      --end loop;
      return Result;
    end;

  --------------
  -- Bounding --
  --------------

  procedure Adjust_Bounding (Point : Point_3D; Bounding : in out Bounding_State) is
    begin
      if Point.X > Bounding.A.X then Bounding.A.X := Point.X; end if;
      if Point.X < Bounding.B.X then Bounding.B.X := Point.X; end if;
      if Point.Y > Bounding.A.Y then Bounding.A.Y := Point.Y; end if;
      if Point.Y < Bounding.B.Y then Bounding.B.Y := Point.Y; end if;
      if Point.Z > Bounding.A.Z then Bounding.A.Z := Point.Z; end if;
      if Point.Z < Bounding.B.Z then Bounding.B.Z := Point.Z; end if;
    end;

  function Build_Bounding (Joints : Vector_Joint.Unsafe.Vector) return Bounding_State is
    Bounding : Bounding_State := (others => <>);
    begin
      for Joint of Joints loop Adjust_Bounding (Joint.Point, Bounding); end loop;
      return Bounding;
    end;

  -------------
  -- Loading --
  -------------

  -- Separate packages (one for each Model.Format_Kind)
  package Wavefront is function Load (Path : Str) return Mesh_State; end;
  package body Wavefront is separate;
  
  package Doom3 is
      function Load (Path : Str) return Mesh_State;
      function Load (Path : Str) return Map_State;
      function Load (Path : Str) return Camera_State;
      function Load (Path : Str) return Animation_State;
      function Load (Path : Str) return Hashed_Material.Unsafe.Map;
    end; package body Doom3 is separate;

  -- Create the loaders
  package Map       is new Handler (Format_Kind, Map_State);
  package Mesh      is new Handler (Format_Kind, Mesh_State);
  package Camera    is new Handler (Format_Kind, Camera_State);
  package Animation is new Handler (Format_Kind, Animation_State);
  package Material  is new Handler (Format_Kind, Hashed_Material.Unsafe.Map);

  -- Register the formats in the loaders
  package Wavefront_Mesh  is new Mesh.Format      (Wavefront_Format, Wavefront.Load, "obj");
  package Doom3_Level     is new Map.Format       (Doom3_Format,     Doom3.Load,     "proc,cm,map,aas48");
  package Doom3_Mesh      is new Mesh.Format      (Doom3_Format,     Doom3.Load,     "md5mesh");
  package Doom3_Camera    is new Camera.Format    (Doom3_Format,     Doom3.Load,     "md5camera");
  package Doom3_Material  is new Material.Format  (Doom3_Format,     Doom3.Load,     "mtr");
  package Doom3_Animation is new Animation.Format (Doom3_Format,     Doom3.Load,     "md5anim");

  -- Redirect internal handlers to public load functions
  function Load (Path : Str) return Map_State                  renames Map.Load;
  function Load (Path : Str) return Mesh_State                 renames Mesh.Load;
  function Load (Path : Str) return Camera_State               renames Camera.Load;
  function Load (Path : Str) return Animation_State            renames Animation.Load;
  function Load (Path : Str) return Hashed_Material.Unsafe.Map renames Material.Load;
end;
