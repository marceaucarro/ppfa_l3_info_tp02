open Ecs
open Component_defs
open System_defs

let enemy (x, y, width, height, mass, elasticity) =
  let e = new enemy in
  e#tag#set (Enemy (e));
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#texture#set (Array.init (List.length Cst.enemy_sprites) (fun i -> Array.make 1 Texture.red));
  e#mass#set mass;
  e#elasticity#set elasticity;
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  Force_system.(register (e :> t));
  e

(*Creates a list of enemies for Global*)
let enemies () =  
  [enemy Cst.(enemy_x, enemy_y, enemy_width, enemy_height, enemy_mass, enemy_elasticity);
  enemy Cst.(enemy_x + 30, enemy_y, enemy_width, enemy_height, enemy_mass, enemy_elasticity)]


(*Gets all created enemies*)
let get_enemies () =
  let Global.{_enemies; _ } = Global.get () in
  _enemies

let move_enemy enemy v =
  enemy#velocity#set v

(**Loads one of the enemy's sprite sets into the given array at index i.*)
let load_sprite_set arr ctx i filename =
  let sprites_filenames = Gfx.load_file ("resources/files/enemy/" ^ filename) in
  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt sprites_filenames)
    (fun txt ->
       let sprite_set =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "") (* retire les lignes vides *)
         |> List.map (fun s -> Gfx.load_image ctx ("resources/images/enemy_sprites/" ^ s))
       in
       Gfx.main_loop (fun _dt ->
           if List.for_all Gfx.resource_ready sprite_set then
             Some (List.map Gfx.get_resource sprite_set)
           else None
         )
         (fun sprite_set ->
            arr.(i) <- (sprite_set
                         |> List.map (fun img -> Texture.Image img)
                         |> Array.of_list)
        )
    )

(**Fetches all enemy sprites into an array and sets it into every enemy's texture component.
  All enemies share the same texture Array to save space, as from there only the getter is used.*)
let load_textures ctx =
  let Global.{_enemies; _ } = Global.get () in
  let textures = Array.init (List.length Cst.enemy_sprites) (fun i -> Array.make 1 Texture.black) in
  List.iteri (fun i filename -> load_sprite_set textures ctx i filename) Cst.enemy_sprites;
  List.iter (fun enemy -> enemy#texture#set textures) _enemies