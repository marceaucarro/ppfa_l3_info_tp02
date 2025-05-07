open Component_defs
open System_defs


let button (id, id_level, x, y, width, height, func) =
  let e = new button () in
  e#id#set id ;
  e#id_level#set id_level ;
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
  let fun_lvl1 () =
    let Global.{ current_level ; _player ; _ } = Global.get () in
    _player#position#set Vector.{ x = 576.0 ; y = 400.0 } ;
    _player#velocity#set Vector.zero ;
    _player#id_level#set 1 ;
    current_level#set 1
  in
  let play = button (1, 0, 300, 150, 200, 100, fun_lvl1) in
  let quit = button (2, 0, 300, 275, 200, 100, (fun () -> exit 0)) in
  [play;quit]
 

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
        let button_textures = button#texture#get in
        List.iteri ( fun i img -> 
          button_textures.(i) <- Array.make 1 (Texture.Image img)
        ) sprite_set ;
        button#texture#set button_textures
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
