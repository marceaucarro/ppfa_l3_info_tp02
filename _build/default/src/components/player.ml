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
  (* Rajouter velocity question 7.5 *)
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  (* Question 7.5 enregistrer auprès du Move_system *)
  e

let players () =  
  player  Cst.("player1", paddle1_x, paddle1_y, paddle_color, paddle_width, paddle_height),
  player  Cst.("player2", paddle2_x, paddle2_y, paddle_color, paddle_width, paddle_height)


let player1 () = 
  let Global.{player1; _ } = Global.get () in
  player1

let player2 () =
  let Global.{player2; _ } = Global.get () in
  player2

let stop_players () = 
  let Global.{player1; player2; _ } = Global.get () in
  () (* À remplacer en question 7.5, mettre la vitesse
        à 0 *)

let move_player player v =
  () (* À remplacer en question 7.5, mettre la vitesse
        du joueur à v *)
  