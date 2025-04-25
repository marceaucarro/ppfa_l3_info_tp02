open System_defs
open Component_defs
open Ecs


let init dt =
  Ecs.System.init_all dt;
  Some ()

let load_ressources ctx =
  Decor.load_textures ctx 0;
  Player.load_textures ctx;
  Enemy.load_textures ctx
  (*Wall.load_textures ctx...*)

let update dt =
  let () = Input.handle_input () in
  Force_system.update dt;
  Move_system.update dt;
  Collision_system.update dt;
  Draw_system.update dt;
  None

let (let@) f k = f k


let run () =
  let window_spec = 
    Format.sprintf "game_canvas:%dx%d:"
      Cst.window_width Cst.window_height
  in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in
  let () = Gfx.set_context_logical_size ctx Cst.logical_width Cst.logical_height in
  let _walls = Wall.walls () in
  let _enemies = Enemy.enemies () in
  let decor = Decor.decors () in
  let player1, player2 = Player.players () in
  let global = Global.{ window; ctx; player1; player2; _enemies; _walls; decor} in
  Global.set global;
  let@ () = Gfx.main_loop ~limit:false init in
  load_ressources ctx;
  let@ () = Gfx.main_loop update in ()