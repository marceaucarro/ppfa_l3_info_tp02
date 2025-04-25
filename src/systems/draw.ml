open Ecs
open Component_defs


type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255

let update_player _dt ctx surface p =
  let vel : Vector.t = p#velocity#get in
  let old_spr_set = p#current_sprite_set#get in
  
  if ( vel.x < 0.0 ) then (*The sprite is facing right by default: it gets mirrored when moving left.*)
    Gfx.set_transform ctx 0. true false ;
  
  (*Setting up the right sprite set depending on the player's situation:*)
  if ( p#is_airborne#get ) then (*Jumping.*)
    p#current_sprite_set#set 3
  else
    begin
      let vel_x_abs = Float.abs vel.x in
      if ( vel_x_abs < 0.05 ) then
        p#current_sprite_set#set 0 (*Standing.*)
      else if ( vel_x_abs < 0.3 ) then
        p#current_sprite_set#set 1 (*Walking.*)
      else
        p#current_sprite_set#set 2 (*Running.*)
    end ;
  if ( p#current_sprite_set#get <> old_spr_set ) then
    p#current_sprite#set 0 ;

  let pos = p#position#get in
  let box = p#box#get in
  let txt = p#texture#get in
  Texture.draw ctx surface pos box txt.(p#current_sprite_set#get).(p#current_sprite#get) ;
  Gfx.reset_transform ctx ;

  if ( (_dt -. p#last_dt#get) > (1000. /. Cst.fps) ) then (*Setting up the next sprite of the current animation loop*)
    let next_sprite = 
      if ( p#current_sprite_set#get <> 3 ) then (*If we're in a looping animation (= not jumping)*)
        ((p#current_sprite#get + 1) mod (Array.length txt.(p#current_sprite_set#get)))
      else
        min (p#current_sprite#get + 1) ((Array.length txt.(p#current_sprite_set#get)) - 1)
    in
    p#current_sprite#set next_sprite ;
    p#last_dt#set _dt

let update_button _dt ctx surface b =
    let pos = b#position#get in
    let box = b#box#get in
    let txt = b#texture#get in

    if ( b#clicked#get ) then
        b#current_sprite_set#set 2
    else if ( b#hovered_over#get ) then
        b#current_sprite_set#set 1
    else
        b#current_sprite_set#set 0 ;
    
    
    Texture.draw ctx surface pos box txt.(b#current_sprite_set#get).(b#current_sprite#get) ;
    Gfx.reset_transform ctx

let update _dt el =
  let Global.{ window ; ctx ; _ } = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in
  Gfx.set_color ctx white ;
  Gfx.fill_rect ctx surface 0 0 ww wh ;
  Seq.iter ( fun (e:t) ->
    match e#tag#get with
      | Player p -> update_player _dt ctx surface p
      | Button b -> update_button _dt ctx surface b
      | _ ->
        let pos = e#position#get in
        let box = e#box#get in
        let txt = e#texture#get in
        Format.eprintf "%a\n%!" Vector.pp pos ;
        Texture.draw ctx surface pos box txt.(0).(0) ;
        Gfx.reset_transform ctx ;
  ) el ;
  Gfx.commit ctx
