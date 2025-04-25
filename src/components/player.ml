open Ecs
open Component_defs
open System_defs

let player (name, x, y, width, height, mass, elasticity) =
  let e = new player name in
  e#tag#set (Player (e));
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  e#texture#set (Array.init 4 (fun _ -> Array.make 1 Texture.black));
  e#current_sprite_set#set 0;
  e#current_sprite#set 0;
  e#mass#set mass;
  e#elasticity#set elasticity;
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  Force_system.(register (e :> t));
  e

let players () =  
  player  Cst.("player1", player1_x, player1_y, player_width, player_height, player_mass, player_elasticity),
  player  Cst.("player2", player2_x, player2_y, player_width, player_height, player_mass, player_elasticity)


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
  player#velocity#set v

(**Loads one of the player's sprite sets into component texture at index i.*)
let load_spriteset player ctx i filename =
  let sprites_filenames = Gfx.load_file ("resources/files/player/" ^ filename) in
  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt sprites_filenames)
    (fun txt ->
       let sprite_set =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "") (* retire les lignes vides *)
         |> List.map (fun s -> Gfx.load_image ctx ("resources/images/player_sprites/" ^ s))
       in
       Gfx.main_loop (fun _dt ->
           if List.for_all Gfx.resource_ready sprite_set then
             Some (List.map Gfx.get_resource sprite_set)
           else None
         )
         (fun sprite_set ->
          let player_textures = player#texture#get in
            player_textures.(i) <- (sprite_set
                         |> List.map (fun img -> Texture.Image img)
                         |> Array.of_list);
          player#texture#set player_textures
        )
    )


(**Sets all player sprite sets (one sprite set for each animation)
into the player's texture component.*)
let load_textures ctx =
  let Global.{player1; player2; _ } = Global.get () in
  List.iteri (fun i filename -> load_spriteset player1 ctx i filename) Cst.player_sprites;
  List.iteri (fun i filename -> load_spriteset player2 ctx i filename) Cst.player_sprites
