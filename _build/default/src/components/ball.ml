open Ecs
open Component_defs
open System_defs

let ball ctx font =
  let e = new ball () in
  let y_orig = float Cst.ball_v_offset in
  e#texture#set Cst.ball_color;
  e#position#set Vector.{x = float Cst.ball_left_x; y = y_orig};
  e#box#set Rect.{width = Cst.ball_size; height = Cst.ball_size};
  e#velocity#set Vector.zero;
  e#resolve#set (fun n t ->
    match t#tag#get with
      Wall.HWall _ | Player .Player ->
        let v = e#velocity#get in
        e#velocity#set Vector.{x = n.x *. v.x; y = n.y *. v.y}
    | Wall.VWall (i, _) ->
        e#velocity#set Vector.zero;
        if i = 1 then
          e#position#set Vector.{x = float_of_int (Cst.paddle1_x + Cst.paddle_width + Cst.ball_size);
          y = (float_of_int Cst.window_height)/.2.}
        else
          e#position#set Vector.{x = float_of_int (Cst.paddle2_x - Cst.paddle_width - Cst.ball_size);
          y = (float_of_int Cst.window_height)/.2.};
        let global = Global.get () in
        global.waiting <- i
    | _ -> ()
    );

  Draw_system.(register (e :>t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  e

let random_v b =
  let a = Random.float (Float.pi/.2.0) -. (Float.pi /. 4.0) in
  let v = Vector.{x = cos a; y = sin a} in
  let v = Vector.mult 5.0 (Vector.normalize v) in
  if b then v else Vector.{ v with x = -. v.x }

let restart () =
  let global = Global.get () in
  if global.waiting <> 0 then begin
    let v = random_v (global.waiting = 1) in
    global.waiting <- 0;
    global.ball#velocity#set v;
  end