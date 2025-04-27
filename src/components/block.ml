open Ecs
open Component_defs
open System_defs


let create (x, y, v, txt, width, height, mass) =
  let e = new block () in
  e#position#set Vector.{ x=float x ; y = float y } ;
  e#velocity#set v ;
  e#mass#set mass ;
  e#box#set Rect.{ width ; height } ;
  let textures = e#texture#get in (* À dégager ensuite *)
  textures.(0).(0) <- txt ;
  e#texture#set textures ;
  Collision_system.(register (e:>t)) ;
  Draw_system.(register (e:>t)) ;
  Move_system.(register (e:>t)) ;
  e


let create_random () =
  let x = Cst.window_width / 2 in
  let y = Cst.window_height / 2 in
  let vx = Random.float 5. in
  let vy = Random.float 5. in
  let txt = Texture.black in 
  let width = 20 in
  let height = 20 in
  let mass = 1.0 +. (Random.float 99.0) in
  create (x, y, Vector.{ x = vx ; y = vy }, txt, width, height, mass)


let walls () =
  List.map create
    Cst.[ 
      (hwall1_x, hwall1_y, Vector.zero, Texture.blue, hwall_width, hwall_height, infinity) ;
      (hwall2_x, hwall2_y, Vector.zero, Texture.blue, hwall_width, hwall_height, infinity) ;
      (vwall1_x, vwall1_y, Vector.zero, Texture.green, vwall_width, vwall_height, infinity) ;
      (vwall2_x, vwall2_y, Vector.zero, Texture.green, vwall_width, vwall_height, infinity)
    ]
