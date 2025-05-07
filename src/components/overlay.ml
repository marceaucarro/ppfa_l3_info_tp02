open Component_defs
open System_defs


let overlay (id, id_level, x, y, width, height) =
  let e = new overlay () in
  e#id#set id ;
  e#id_level#set id_level ;
  e#tag#set Overlay ;
  e#position#set Vector.{ x = float x ; y = float y } ;
  e#velocity#set Vector.zero ;
  e#box#set Rect.{ width = width ; height = height } ;
  e#texture#set (Array.make 1 (Array.make 1 Texture.transparent)) ;
  e#current_sprite_set#set 0 ;
  e#current_sprite#set 0 ;
  e#last_dt#set 0.0 ;
  Draw_system.(register (e :> t)) ;
  e


let overlays () =
  let tmp = new overlay () in
  let rf_overlays = Array.make (Cst.nb_overlays) (tmp) in
  let overlays_base = Gfx.load_file "resources/files/overlays/overlays.txt" in
  Gfx.main_loop
  ( fun _dt -> Gfx.get_resource_opt overlays_base )
  ( fun overlays_resources ->
    overlays_resources
    |> String.split_on_char '\n'
    |> List.filter ( fun s -> s <> "")
    |> List.iteri ( fun i s -> 
         let o = Array.of_list (List.map (int_of_string) (String.split_on_char ' ' s)) in
         rf_overlays.(i) <- overlay(o.(0), o.(1), o.(2), o.(3), o.(4), o.(5))
       )
  ) ;
  rf_overlays


let load_textures ctx =
  let overlays_textures = Hashtbl.create 64 in
  let overlays_resources = List.mapi ( fun i s -> (i, Gfx.load_image ctx ("resources/images/overlays_sprites/"^s)) ) Cst.overlays_sprites_filenames in
  
  Gfx.main_loop
  ( fun _dt ->
    if ( List.for_all ( fun (_, r) -> Gfx.resource_ready r) overlays_resources ) then
      Some(List.map ( fun (id, r) -> (id, Gfx.get_resource r) ) overlays_resources)
    else
      None
  )
  ( fun overlays_surfaces ->
    List.iter ( fun (id, img) -> Hashtbl.add overlays_textures id (Texture.Image(img)) ) overlays_surfaces ;

    let Global.{ _overlays ; _ } = Global.get () in

    Array.iter ( fun o ->
      let overlay_texture = o#texture#get in
      overlay_texture.(0) <- Array.make 1 (Hashtbl.find overlays_textures (o#id#get)) ;
      o#texture#set overlay_texture
    ) _overlays
  )
