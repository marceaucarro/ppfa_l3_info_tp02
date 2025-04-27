open Ecs
open Component_defs
open System_defs

(**The decor of the levels. Works similar to a stamp: after loading the tiles, we use the function [display background] in draw.ml and the 
tile pattern of the current level in Cst.ml to apply the right tiles at the right places.*)
let decor () =
  let e = new decor () in
  e#tag#set (Decor (e));
  e#position#set Vector.{x = 0.; y = 0.};
  e#box#set Rect.{width = 0; height = 0};
  e#texture#set (Array.init (List.length Cst.decor_tilesets) (fun i -> Array.make 1 Texture.blue));
  e#current_sprite_set#set 0;
  e#current_sprite#set 0;
  Draw_system.(register (e :> t));
  e

let decors () =  
  decor ()


let get_decor () = 
  let Global.{decor; _ } = Global.get () in
  decor

(**Loads one of the level images into the decor's texture component at index i (it then contains images for level n°i).*)
let load_tile_set decor ctx i filename =
  let tiles_filenames = Gfx.load_file ("resources/files/decor/" ^ filename) in
  Gfx.main_loop
    (fun _dt -> Gfx.get_resource_opt tiles_filenames)
    (fun txt ->
       let tile_set =
         txt
         |> String.split_on_char '\n'
         |> List.filter (fun s -> s <> "") (* retire les lignes vides *)
         |> List.map (fun s -> Gfx.load_image ctx ("resources/images/decor_tilesets/level_" ^ (string_of_int i) ^ "/" ^ s))
       in
       Gfx.main_loop (fun _dt ->
           if List.for_all Gfx.resource_ready tile_set then
             Some (List.map Gfx.get_resource tile_set)
           else None
         )
        (fun tile_set ->
          let decor_tilesets = decor#texture#get in
            decor_tilesets.(i) <- (tile_set
                         |> List.map (fun img -> Texture.Image img)
                         |> Array.of_list);
          decor#texture#set decor_tilesets
        )
    )

(**Sets all decor texture sets (one set for each level)
into the decor's texture component, then sets the given level value into decor's current_sprite_set.*)
let load_textures ctx level =
  let Global.{decor; _ } = Global.get () in
  decor#current_sprite_set#set level;
  List.iteri (fun i filename -> load_tile_set decor ctx i filename) Cst.decor_tilesets