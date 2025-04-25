open Component_defs
open System_defs

(*type tag += Wall*)

let wall (x, y, txt, width, height, mass, elasticity) =
  let e = new wall () in
  e#tag#set Wall;
  e#position#set Vector.{x = float x; y = float y};
  e#box#set Rect.{width; height};
  e#velocity#set Vector.zero;
  let textures = e#texture#get in(*Dégager cette ligne et les 2 suivantes ensuite*)
  textures.(0).(0) <- txt;
  e#texture#set textures;
  e#mass#set mass;
  e#elasticity#set elasticity;
  Draw_system.(register (e :> t));
  Collision_system.(register (e :> t));
  Move_system.(register (e :> t));
  Force_system.(register (e :> t));
  e

let walls () = 
  List.map wall
    Cst.[ 
      (hwall1_x, hwall1_y, Texture.transparent, hwall_width, hwall_height, infinity, 0.0);
      (hwall2_x, hwall2_y, Texture.transparent, hwall_width, hwall_height, infinity, 0.0);
      (vwall1_x, vwall1_y, Texture.transparent, vwall_width, vwall_height, infinity, 0.0);
      (vwall2_x, vwall2_y, Texture.transparent, vwall_width, vwall_height, infinity, 0.0);
    ]

(**Loads one of the wall's sprite sets into component texture at index i.*)
(*let load_spriteset wall ctx i filename =
   let sprites_filenames = Gfx.load_file ("resources/files/wall/" ^ filename) in
  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt sprites_filenames)
    (fun txt ->
       let sprite_set =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "") (* retire les lignes vides *)
         |> List.map (fun s -> Gfx.load_image ctx ("resources/images/wall_sprites/" ^ s))
       in
       Gfx.main_loop (fun _dt ->
           if List.for_all Gfx.resource_ready sprite_set then
             Some (List.map Gfx.get_resource sprite_set)
           else None
         )
         (fun sprite_set ->
          let player_textures = player#texture#get in
            player_textures.(i) <- (sprite_set
                         |> List.map (fun img -> Texture.Image img)
                         |> Array.of_list);
          player#texture#set player_textures
        )
    ) *)


(**Sets all wall textures into their texture component.*)
(*let load_textures ctx =
  let Global.{_walls; _ } = Global.get () in
  List.iteri (fun i filename -> load_spriteset player1 ctx i filename) Cst.player_sprites;*)