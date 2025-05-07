open Component_defs
open System_defs


let tile (id, id_level, x, y) =
  let e = new tile () in
  e#id#set id ;
  e#id_level#set id_level ;
  e#tag#set Tile ;
  e#position#set Vector.{ x = float x ; y = float y } ; 
  e#velocity#set Vector.zero ;
  e#box#set Rect.{ width = Cst.tile_width ; height = Cst.tile_height } ;
  e#texture#set (Array.make 1 (Array.make 1 Texture.transparent)) ;
  e#current_sprite_set#set 0 ;
  e#current_sprite#set 0 ;
  e#last_dt#set 0.0 ;
  Draw_system.(register (e :> t)) ;
  e


let tiles () =
  let tiles_set = Array.make (Cst.nb_levels) ([||] :> tile list array) in
  let tile_tmp = new tile () in
  tile_tmp#id#set 0 ;

  List.iter ( fun (id_level, filename) ->
    let level_filename = Gfx.load_file ("resources/files/levels/" ^ filename) in
    Gfx.main_loop
    ( fun _dt -> Gfx.get_resource_opt level_filename )
    ( fun txt ->
      let plans_filenames =
        txt
        |> String.split_on_char '\n'
        |> List.filter ( fun s -> s <> "")
        |> List.mapi ( fun i s -> Gfx.load_file ("resources/levels/" ^ s))
      in
      Gfx.main_loop
      ( fun _dt ->
        if ( List.for_all (Gfx.resource_ready) plans_filenames ) then
          Some (List.map (Gfx.get_resource) plans_filenames)
        else
          begin
          None
          end
      )
      ( fun plans_def -> (* Liste avec pour élément i une chaîne de caractères représentant le plan i *)
          let plans_set = List.map ( fun plan -> (* plan : Chaîne de caractère représentant un plan *)
            plan
            |> String.split_on_char '\n' (* Liste avec pour élément i une chaîne de caractères réprésentant une ligne *)
            |> List.filter ( fun s -> s <> "")
            |> List.mapi ( fun y ligne -> (* ligne : Chaîne de caractère représentant la ligne y d'un plan *) 
                 ligne
                 |> String.split_on_char ' ' (* Liste avec pour élément i une tuile d'une ligne *)
                 |> List.filter ( fun s -> s <> "")
                 |> List.mapi ( fun x t ->
                      if ( t = "0" ) then
                        tile_tmp
                      else
                        tile ((int_of_string t), id_level, (x * (Cst.tile_width)), (y * (Cst.tile_height)))
                    )
               )
            |> List.flatten
            |> List.filter ( fun t -> t#id#get > 0 )
          ) plans_def in
          tiles_set.(id_level) <- Array.of_list plans_set
      )
    )
  ) Cst.def_levels ;
  
  tiles_set


let load_textures ctx =
  let tiles_textures = Hashtbl.create 256 in
  let tiles_filenames = Gfx.load_file "resources/files/tiles/tiles.txt" in
  Gfx.main_loop
  ( fun _dt -> Gfx.get_resource_opt tiles_filenames )
  ( fun txt ->
    let tiles_resources_set =
      txt
      |> String.split_on_char '\n'
      |> List.filter ( fun s -> s <> "" )
      |> List.mapi ( fun i s -> (i, s) )
      |> List.map ( fun (id, s) -> (id, Gfx.load_image ctx ("resources/images/" ^ s)) )
    in
    Gfx.main_loop
    ( fun _dt ->
      if ( List.for_all ( fun (_, r) -> Gfx.resource_ready r ) tiles_resources_set ) then
        Some (List.map ( fun (id, r) -> (id, Gfx.get_resource r) ) tiles_resources_set)
      else
        None
    )
    ( fun tiles_img_set ->
      List.iter ( fun (id, img) -> Hashtbl.add tiles_textures id (Texture.Image(img)) ) tiles_img_set ;

      let Global.{ _tiles ; _ } = Global.get () in

      Array.iter ( fun level ->
        Array.iter ( fun plan ->
          List.iter ( fun t ->
            let tile_texture = t#texture#get in
            tile_texture.(0) <- Array.make 1 (Hashtbl.find tiles_textures (t#id#get)) ; 
            t#texture#set tile_texture
          ) plan
        ) level
      ) _tiles
    )
  )  
