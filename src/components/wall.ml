open Component_defs
open System_defs

(*type tag += Wall*)

let wall (x, y, txt, width, height, mass, elasticity) =
  let e = new wall () in
  e#texture#set txt;
  e#position#set Vector.{x = float x; y = float y};
  e#velocity#set Vector.zero;
  e#tag#set Wall;
  e#box#set Rect.{width; height};
  e#mass#set mass;
  e#elasticity#set elasticity;
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  Force_system.(register (e :> t));
  e

let walls () = 
  List.map wall
    Cst.[ 
      (hwall1_x, hwall1_y, hwall_color, hwall_width, hwall_height, infinity, 0.0);
      (hwall2_x, hwall2_y, hwall_color, hwall_width, hwall_height, infinity, 0.0);
      (vwall1_x, vwall1_y, vwall_color, vwall_width, vwall_height, infinity, 0.0);
      (vwall2_x, vwall2_y, vwall_color, vwall_width, vwall_height, infinity, 0.0);
    ]
