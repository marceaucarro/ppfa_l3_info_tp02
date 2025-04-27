open Ecs
open Component_defs
open System_defs

let (let@) f k = f k

let init dt =
  Ecs.System.init_all dt ;
  Some ()

let load_ressources ctx =
  Decor.load_textures ctx 0 ;
  Player.load_textures ctx ;
  Enemy.load_textures ctx
  (*Wall.load_textures ctx...*)

let update dt =
  let () = Input.handle_input () in
  Force_system.update dt ;
  Move_system.update dt ;
  Collision_system.update dt ;
  Draw_system.update dt ;
  None



let run () =
  let window_spec = Format.sprintf "game_canvas:%dx%d:" Cst.window_width Cst.window_height in
  let window = Gfx.create  window_spec in
  let ctx = Gfx.get_context window in
  let () = Gfx.set_context_logical_size ctx Cst.logical_width Cst.logical_height in
  let _walls = Wall.walls () in
  let _enemies = Enemy.enemies () in
  let _buttons = Button.buttons () in
  let player1, _ = Player.players () in
  let current_level = Component.init 0 in
  let _tiles = Tile.tiles () in
  let decor = Decor.decors () in
  let global = Global.{ window ; ctx ; current_level ; player1 ; _enemies ; _walls ; _buttons ; _tiles ; decor } in
  Global.set global ;
  let@ () = Gfx.main_loop ~limit:false init in
  load_ressources ctx ;
  let@ () = Gfx.main_loop update in
  ()