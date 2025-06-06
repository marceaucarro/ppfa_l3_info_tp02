open Ecs
open Component_defs
open System_defs


let player (name, width, height, mass, elasticity) =
  let e = new player name in
  e#id_level#set 0 ;
  e#tag#set ( Player (e) ) ;
  e#position#set Vector.{ x = 0.0 ; y = 0.0 } ;
  e#velocity#set Vector.zero ;
  e#mass#set mass ;
  e#elasticity#set elasticity ;
  e#sum_forces#set Vector.zero ;
  e#box#set Rect.{ width ; height } ;
  e#texture#set (Array.init (List.length Cst.player_sprites) (fun i -> Array.make 1 Texture.transparent)) ;
  e#current_sprite_set#set 0 ;
  e#current_sprite#set 0 ;
  e#last_dt#set 0.0 ;
  e#is_airborne#set false ;
  Collision_system.(register (e :> t)) ;
  Draw_system.(register (e :> t)) ;
  Move_system.(register (e :> t)) ;
  Force_system.(register (e :> t)) ;
  e


let players () =
  player  Cst.("player1", player_width, player_height, player_mass, player_elasticity)


let stop_players () = 
  let Global.{ _player ; _ } = Global.get () in
  _player#velocity#set Vector.zero


let move_player v =
  let Global.{ _player ; _ } = Global.get () in 
  _player#velocity#set v


(**Loads one of the player's sprite sets into component texture at index i.*)
let load_spriteset player ctx i filename =
  let sprites_filenames = Gfx.load_file ("resources/files/player/" ^ filename) in
  Gfx.main_loop
    ( fun _dt -> Gfx.get_resource_opt sprites_filenames)
    ( fun txt ->
      let sprite_set =
        txt
        |> String.split_on_char '\n'
        |> List.filter ( fun s -> s <> "") (* retire les lignes vides *)
        |> List.map ( fun s -> Gfx.load_image ctx ("resources/images/player_sprites/" ^ s))
      in
      Gfx.main_loop
      ( fun _dt ->
        if ( List.for_all Gfx.resource_ready sprite_set ) then
          Some (List.map Gfx.get_resource sprite_set)
        else
        None
      )
      ( fun sprite_set ->
        let player_textures = player#texture#get in
        player_textures.(i) <-
          (sprite_set
          |> List.map (fun img -> Texture.Image img)
          |> Array.of_list) ;
          player#texture#set player_textures)
      )


(**Sets all player sprite sets (one sprite set for each animation)
into the player's texture component.*)
let load_textures ctx =
  let Global.{ _player ; _ } = Global.get () in
  List.iteri ( fun i filename -> load_spriteset _player ctx i filename ) Cst.player_sprites
