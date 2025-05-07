open Component_defs
open System_defs

let wall (id_level, x, y) =
  let e = new wall () in
  e#id_level#set id_level ;
  e#tag#set Wall ;
  e#position#set Vector.{ x = float x ; y = float y } ;
  e#velocity#set Vector.zero ;
  e#mass#set infinity ;
  e#elasticity#set 0.0 ;
  e#sum_forces#set Vector.zero ;
  e#box#set Rect.{ width = Cst.tile_width ; height = Cst.tile_height } ;
  Collision_system.(register (e :> t)) ;
  Force_system.(register (e :> t)) ; 
  e 

let walls () =
  let walls_set = Array.make (Cst.nb_levels) ([] :> wall list) in
  let wall_tmp = new wall () in
  wall_tmp#id_level#set (-1) ;

  List.iter ( fun (id_level, filename) ->
    let tmp = List.hd (String.split_on_char '.' filename) in 
    let walls_resources = Gfx.load_file ("resources/levels/"^tmp^"/"^tmp^"_walls.txt") in
    Gfx.main_loop
    ( fun _dt -> Gfx.get_resource_opt walls_resources )
    ( fun walls_def ->
      let walls_set_tmp =
        walls_def
        |> String.split_on_char '\n'
        |> List.mapi ( fun y ligne -> 
           ligne
           |> String.split_on_char ' '
           |> List.mapi ( fun x w ->
                if ( w = "0" ) then
                  wall_tmp
                else
                  wall (id_level, (x * (Cst.tile_width)), (y * (Cst.tile_height)))
              )
           )
        |> List.flatten
        |> List.filter ( fun w -> w#id_level#get >= 0 )
      in

      walls_set.(id_level) <- walls_set_tmp ;
    )
  ) Cst.def_levels ;

  walls_set
