open Ecs
open Component_defs
open System_defs

type tag += Enemy

(*L'ennemi va de gache à droite jusqu'à une certaine distance de son spwn, puis revient. S'il y a un obstacle,
il se retourne plus tôt. (il ne se jette pas dans le vide).*)
let enemy (x, y, txt, width, height) =
  let e = new enemy in
  e#texture#set txt;
  e#tag#set Enemy;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#resolve#set (fun _ t ->
    match t#tag#get with
      Wall.HWall (w) ->
        let vW = w#position#get in
        let bW = w#box#get in
        (match (Rect.replace e#position#get e#box#get vW bW) with
          Some v ->
            e#position#set Vector.{x = v.x; y = v.y};
          |None -> ()
        ;
        match (Rect.rebound e#position#get e#box#get vW bW) with
          Some (v) ->
            e#velocity#set Vector.{x = v.x; y = v.y};
          |None -> ())
    | _ -> ()
  );
  
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  e

(*La liste de tous les ennemis*) 
  let enemies () = 
    List.map enemy
      Cst.[ 
        (player1_x + 50, player1_y, hwall_color, player_width, player_height);
      ]
let stop_players () = 
  let Global.{player1; player2; _ } = Global.get () in
  player1#velocity#set Vector.zero;
  player2#velocity#set Vector.zero

let move_enemy enemy v =
  enemy#velocity#set v;
  