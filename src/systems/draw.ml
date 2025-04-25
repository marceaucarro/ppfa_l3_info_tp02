open Ecs
open Component_defs


type t = drawable

let init _ = ()

let white = Gfx.color 255 255 255 255

(**Displays the tiles of the current level as indicated in [Cst.lvl_patterns]*)
let display_background ctx surface =
  let Global.{decor;_} = Global.get () in
  let tile_set = decor#current_sprite_set#get in
  let txt = decor#texture#get in
  (*With Draw.update's tendency to start before texture component is fully set, we do not want an "index out of bounds" exception*)
  match txt.(0).(0) with
    Texture.Color (_) -> ()
  | Texture.Image (_) ->
    begin
      let x = ref 0. in (*The x of the coordinates to which the tile should be displayed.*)
      List.iter (fun (tile_index, w, h, flipped) ->
        if (flipped) then begin Gfx.set_transform ctx 0. true false end;
        let pos = Vector.{x = !x; y = 0.} in
        let box = Rect.{width = w; height = h} in
        if (tile_index >= Array.length txt.(tile_set)) then
          Texture.draw ctx surface pos box txt.(0).(0)
        else
          Texture.draw ctx surface pos box txt.(tile_set).(tile_index);
        Gfx.reset_transform ctx;
        x := !x +. (float_of_int box.width)
      ) Cst.lvl_patterns.(tile_set); (*We iterate on the tile pattern of level n°"tileset"*)
    end

(**Updates the sprite of the human entity [e] depending on the condition it is in.
It is considered that [e] has four different animations, in this order: Standing, walking, running, jumping.*)
let update_human _dt ctx surface e =
  let txt = e#texture#get in
  (*We perform the same veryfication than display_background.*)
  match txt.(0).(0) with
    Texture.Color (_) -> ()
  | Texture.Image (_) ->
    begin
      let vel : Vector.t = e#velocity#get in
      let old_spr_set = e#current_sprite_set#get in
      
      if (vel.x < 0.0) then Gfx.set_transform ctx 0. true false; (*The sprite is facing right by default: it gets mirrored when moving left.*)
      
      (*Setting up the right sprite set depending on the player's situation:*)
      if (e#is_airborne#get) then (*Jumping.*)
        e#current_sprite_set#set 3
      else
        begin
        let vel_x_abs = Float.abs vel.x in
        if (vel_x_abs < 0.05) then
          e#current_sprite_set#set 0 (*Standing.*)
        else if (vel_x_abs < 0.3) then
          e#current_sprite_set#set 1 (*Walking.*)
        else
          e#current_sprite_set#set 2 (*Running.*)
        end;
      if (e#current_sprite_set#get <> old_spr_set) then e#current_sprite#set 0;

      let pos = e#position#get in
      let box = e#box#get in
      let txt = e#texture#get in
      Texture.draw ctx surface pos box txt.(e#current_sprite_set#get).(e#current_sprite#get);
      Gfx.reset_transform ctx;

      if (_dt -. e#last_dt#get > (1000. /. Cst.fps)) then (*Setting up the next sprite of the current animation loop*)
        let next_sprite = 
          if (e#current_sprite_set#get <> 3) then (*If we're in a looping animation (= not jumping)*)
            ((e#current_sprite#get + 1) mod (Array.length txt.(e#current_sprite_set#get)))
          else
            min (e#current_sprite#get + 1) ((Array.length txt.(e#current_sprite_set#get)) - 1) in
          e#current_sprite#set next_sprite;
          e#last_dt#set _dt
    end

let update _dt el =
  let Global.{window;ctx;_} = Global.get () in
  let surface = Gfx.get_surface window in
  let ww, wh = Gfx.get_context_logical_size ctx in
  Gfx.set_color ctx white;
  Gfx.fill_rect ctx surface 0 0 ww wh;
  display_background ctx surface;
  Seq.iter (fun (e:t) ->
    match e#tag#get with
        Player (e) | Enemy (e) -> update_human _dt ctx surface e
      | Decor (e) -> () (*Decor should be drawn before anything else, and ignored here to not appear over other entities.*)
      | _ ->
        let pos = e#position#get in
        let box = e#box#get in
        let txt = e#texture#get in
        Format.eprintf "%a\n%!" Vector.pp pos;
        Texture.draw ctx surface pos box txt.(0).(0)
    ) el;
  Gfx.commit ctx