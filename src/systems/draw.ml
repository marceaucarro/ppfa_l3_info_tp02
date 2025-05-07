open Ecs
open Component_defs


type t = drawable


let init _ = ()


let update_button _dt ctx surface b =
  let pos = b#position#get in
  let box = b#box#get in
  let txt = b#texture#get in
  
  match txt.(0).(0) with
  | Texture.Color (_) -> ()
  | Texture.Image (_) ->
      begin
        if ( b#clicked#get ) then
          b#current_sprite_set#set 2
        else if ( b#hovered_over#get ) then
          b#current_sprite_set#set 1
        else
          b#current_sprite_set#set 0 ;
          
        Texture.draw ctx surface pos box txt.(b#current_sprite_set#get).(b#current_sprite#get) ;
        Gfx.reset_transform ctx
      end


(**Displays the tiles of the current level as indicated in [Cst.lvl_patterns]*)
let display_tiles ctx surface plan =
  let to_match =
    if ( List.length plan = 0 ) then
      Texture.transparent
    else
      (List.hd plan)#texture#get.(0).(0) in

  match to_match with
  | Texture.Color (_) ->
    ()
  | Texture.Image (_) ->
    begin
      let Global.{ _screen ; _ } = Global.get () in
      let Vector.{ x ; y } = _screen#position#get in
      let x_global_screen = int_of_float x in
      let y_global_screen = int_of_float y in
      List.iter (fun t ->
        let Vector.{ x ; y } = t#position#get in
        let x_global_tile = int_of_float x in
        let y_global_tile = int_of_float y in
        if ( (x_global_screen < x_global_tile+Cst.tile_width)
          && (x_global_tile <= x_global_screen+Cst.window_width)
          && (y_global_screen < y_global_tile+Cst.tile_height)
          && (y_global_tile <= y_global_screen+Cst.window_height)
          ) then
          begin
            let x_local_tile = x_global_tile - x_global_screen in
            let y_local_tile = y_global_tile - y_global_screen in
            let box = t#box#get in
            let txt = t#texture#get in
            Texture.draw ctx surface (Vector.{ x = float x_local_tile ; y = float y_local_tile }) box txt.(t#current_sprite_set#get).(t#current_sprite#get) ;
            Gfx.reset_transform ctx
          end 
      ) plan
    end


let display_overlays ctx surface _overlays =
  let Global.{ current_level ; _ } = Global.get () in
  let to_match =
    if ( Array.length _overlays = 0 ) then
      Texture.transparent
    else
      _overlays.(0)#texture#get.(0).(0) in

  match to_match with
  | Texture.Color(_) -> ()
  | Texture.Image(_) ->
    Array.iter ( fun o ->
      if ( o#id_level#get = current_level#get ) then
        begin
          let pos_overlay = o#position#get in
          let box_overlay = o#box#get in
          let txt_overlay = o#texture#get in
          let css_overlay = o#current_sprite_set#get in
          let cs_overlay = o#current_sprite#get in
          
          Texture.draw ctx surface pos_overlay box_overlay txt_overlay.(css_overlay).(cs_overlay) ;
          
          Gfx.reset_transform ctx 
        end
    ) _overlays


(**Updates the sprite of the human entity [e] depending on the condition it is in.
It is considered that [e] has four different animations, in this order: Standing, walking, running, jumping.*)
let update_human _dt ctx surface e =
  let txt = e#texture#get in
  (*We perform the same veryfication than display_background.*)
  match txt.(0).(0) with
  | Texture.Color (_) -> ()
  | Texture.Image (_) ->
    begin
      let vel : Vector.t = e#velocity#get in
      let old_spr_set = e#current_sprite_set#get in
      
      if ( vel.x < 0.0 ) then
        Gfx.set_transform ctx 0. true false ; (*The sprite is facing right by default: it gets mirrored when moving left.*)
      
      (*Setting up the right sprite set depending on the player's situation:*)
      if ( e#is_airborne#get ) then (*Jumping.*)
        e#current_sprite_set#set 3
      else
        begin
          let vel_x_abs = Float.abs vel.x in
          if ( vel_x_abs < 0.05 ) then
            e#current_sprite_set#set 0 (*Standing.*)
          else if ( vel_x_abs < 0.3 ) then
            e#current_sprite_set#set 1 (*Walking.*)
          else
            e#current_sprite_set#set 2 (*Running.*)
        end ;
      if ( e#current_sprite_set#get <> old_spr_set ) then
        e#current_sprite#set 0 ;
      
      let Global.{ _screen ; _ } = Global.get () in
      let Vector.{ x ; y } = _screen#position#get in
      let x_global_screen = x in
      let y_global_screen = y in
      let Vector.{ x ; y } = e#position#get in
      let x_global_human = x in
      let y_global_human = y in
      let x_local_human = x_global_human -. x_global_screen in
      let y_local_human = y_global_human -. y_global_screen in
      let pos_local_human = Vector.{ x = x_local_human ; y = y_local_human } in
      let box = e#box#get in
      let txt = e#texture#get in
      
      Texture.draw ctx surface pos_local_human box txt.(e#current_sprite_set#get).(e#current_sprite#get) ;
      Gfx.reset_transform ctx ;

      if ( _dt -. e#last_dt#get > (1000. /. Cst.fps) ) then (*Setting up the next sprite of the current animation loop*)
        let next_sprite = 
          if ( e#current_sprite_set#get <> 3 ) then (*If we're in a looping animation (= not jumping)*)
            ((e#current_sprite#get + 1) mod (Array.length txt.(e#current_sprite_set#get)))
          else
            min (e#current_sprite#get + 1) ((Array.length txt.(e#current_sprite_set#get)) - 1) in
          e#current_sprite#set next_sprite ;
          e#last_dt#set _dt
    end


let white = Gfx.color 255 255 255 255


let update _dt el =
  let Global.{ window ; ctx ; current_level ; _tiles ; _overlays ; _ } = Global.get () in
  let surface = Gfx.get_surface window in
  Gfx.set_color ctx white ;
  Gfx.fill_rect ctx surface 0 0 Cst.window_width Cst.window_height ;
  if ( ( Array.length _tiles.(0) = 0 )
    || ( List.length _tiles.(0).(0) = 0 )
    || ( Array.length _overlays = 0 ) ) then
    ()
  else
    begin
      display_tiles ctx surface _tiles.(current_level#get).(0) ;
      display_tiles ctx surface _tiles.(current_level#get).(1) ;
      display_overlays ctx surface _overlays ;
      Seq.iter ( fun (e:t) ->
        match e#tag#get with
        | Player (h) -> 
          if ( current_level#get > 0 ) then
            update_human _dt ctx surface h 
        | Enemy (h) ->
          if ( e#id_level#get = current_level#get ) then
            update_human _dt ctx surface h
        | Button b -> 
          if ( e#id_level#get = current_level#get ) then
            update_button _dt ctx surface b
        | Tile | Overlay -> ()
        | _ ->
          if ( e#id_level#get = current_level#get ) then
            begin
              let pos = e#position#get in
              let box = e#box#get in
              let txt = e#texture#get in
              Format.eprintf "%a\n%!" Vector.pp pos ;
              Texture.draw ctx surface pos box txt.(0).(0)
            end
      ) el ;
      display_tiles ctx surface _tiles.(current_level#get).(2) ;
      Gfx.commit ctx
    end
