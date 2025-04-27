open Component_defs
open System_defs

let tile (id, id_level, id_plan, x, y) =
  let e = new tile () in
  e#id#set id ;
  e#id_level#set id_level ;
  e#id_plan#set id_plan ;
  e#tag#set Tile ;
  e#position#set Vector.{ x = float x ; y = float y } ;
  e#velocity#set Vector.zero ;
  e#box#set Rect.{ width = Cst.tile_width ; height = Cst.tile_height } ;
  e#texture#set (Array.make 1 (Array.make 1 Texture.transparent)) ;
  e#current_sprite_set#set 0 ;
  e#current_sprite#set 0 ;
  e#last_dt#set 0 ;
  Draw_system.(register (e :> t)) ;
  Move_system.(register (e :> t)) ;
  e

let tiles () =
  let tiles_set : tile list array array = Component.init [[[]]] in
    List.iter
    ( fun id_level filenames ->
      let def_filenames = Gfx.load_file ("resources/files/levels" ^ filename) in
      Gfx.main_loop
      ( fun _dt -> Gfx.get_resource_opt def_filenames)
      ( fun txt ->
        let def_plans =
          txt
          |> String.split_on_char '\n' txt
          |> List.filter (fun s -> s <> "")
          |> List.map (fun s -> Gfx.load_file ("resources/levels/" ^ s))
        in (* Liste de resources (plan) *)
        Gfx.main_loop
        ( fun _dt ->
          if ( List.for_all (Gfx.resource_ready) def_plans ) then
            Some (List.map (Gfx.get_resource) def_plans)
          else
            None
        )
        (fun def_plans -> (* Liste de string (plan) *)
          tiles_set#set 
          (def_plans
          |> List.map ( fun s ->
              String.split_on_char '\n' s) (* Liste de Liste(plan) de string(ligne) *)
          |> List.map ( fun p ->
              List.map (fun s -> String.split_on_char ' ' s)
             ) (* Liste de Liste(plan) de Liste(ligne) de string(tile) *)
          |> List.mapi ( fun id_plan p ->
              List.mapi ( fun y l ->
                List.mapi (fun x id ->
                  tile ((int_of_string id), id_level, id_plan, (x * Cst.tile_width), (y * Cst.tile_height)))))
          |> List.map ( fun p -> List.flatten p ))
        )
      )
    )



          
  in


  
