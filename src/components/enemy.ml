open Ecs
open Component_defs
open System_defs

let enemy (id, x, y, txt, width, height, mass, elasticity) =
  let e = new enemy in
  e#id#set id;
  e#texture#set txt;
  e#tag#set (Enemy (e));
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#mass#set mass;
  e#elasticity#set elasticity;
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  Force_system.(register (e :> t));
  e

let enemies () =  
  enemy Cst.(1, enemy_x, enemy_y, enemy_color, enemy_width, enemy_height, enemy_mass, enemy_elasticity)

let player1 () = 
  let Global.{player1; _ } = Global.get () in
  player1

let player2 () =
  let Global.{player2; _ } = Global.get () in
  player2

let stop_players () = 
  let Global.{player1; player2; _ } = Global.get () in
  player1#velocity#set Vector.zero;
  player2#velocity#set Vector.zero

let move_enemy enemy v =
  enemy#velocity#set v;
  