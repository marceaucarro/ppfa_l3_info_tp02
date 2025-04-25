open Component_defs
open System_defs

let button (id, x, y, width, height, func) =
  let e = new button () in
  e#id#set id ;
  e#tag#set ( Button (e) ) ;
  e#position#set Vector.{ x = float x ; y = float y } ;
  e#velocity#set Vector.zero ;
  e#box#set Rect.{ width ; height } ;
  e#texture#set (Array.init 3 (fun _ -> Array.make 1 Texture.transparent) );
  e#current_sprite_set#set 0 ;
  e#current_sprite#set 0 ;
  e#last_dt#set 0. ;
  e#action#set func ;
  e#hovered_over#set false ;
  e#clicked#set false ;
  Draw_system.(register (e :> t)) ;
  e

let buttons () = 
  let tuto = button (1, 300, 250, 200, 100, (fun () -> Gfx.debug "\n\n\nTUTO\n\n\n%!")) in
  [tuto]
 

let load_spriteset button ctx filename =
  let sprites_filenames = Gfx.load_file ("resources/files/buttons/" ^ filename) in
  Gfx.main_loop
    ( fun _dt -> Gfx.get_resource_opt sprites_filenames)
    ( fun txt ->
      let sprite_set =
        txt
        |> String.split_on_char '\n'
        |> List.filter (fun s -> s <> "")
        |> List.map (fun s -> Gfx.load_image ctx ("resources/images/buttons_sprites/" ^ s))
      in
      Gfx.main_loop
      ( fun _dt ->
        if ( List.for_all Gfx.resource_ready sprite_set ) then
          Some (List.map Gfx.get_resource sprite_set)
        else
          None
      )
      ( fun sprite_set ->
        let player_textures = button#texture#get in
        List.iteri ( fun i img -> 
          player_textures.(i) <- Array.make 1 (Texture.Image img)
        ) sprite_set ;
        button#texture#set player_textures
      )
    )

let load_textures ctx =
  let Global.{ _buttons ; _ } = Global.get () in
  
  _buttons
  |> List.map ( fun b ->
      let button_id = b#id#get in
      let _, filename = List.find ( fun (id, _) -> button_id = id ) Cst.buttons_sprites in
      (b, filename)
     )
  |> List.iter ( fun (b, filename) -> load_spriteset b ctx filename )
