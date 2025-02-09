open Ecs
open Component_defs
open System_defs

type tag += Player

let player (name, x, y, txt, width, height) =
  let e = new player name in
  e#texture#set txt;
  e#tag#set Player;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#resolve#set (fun _ t ->
    match t#tag#get with
      Wall.HWall (w) ->
        let v = w#position#get in
        let () =
          (if v.y = 0. then
            e#position#set Vector.{x = e#position#get.x; y = float_of_int Cst.hwall_height}
          else
            e#position#set Vector.{x = e#position#get.x; y = w#position#get.y -. float_of_int Cst.player_height}) in
        e#velocity#set Vector.zero
    | _ -> ()
  );
  
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  e

let players () =  
  player  Cst.("player1", player1_x, player1_y, player_color, player_width, player_height),
  player  Cst.("player2", player2_x, player2_y, player_color, player_width, player_height)


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

let move_player player v =
  player#velocity#set v;
  