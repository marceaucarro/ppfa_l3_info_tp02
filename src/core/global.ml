open Component_defs

type t = {
  window : Gfx.window ;
  ctx : Gfx.context ;
  player1 : player ;
  _enemies : enemy list ;
  _walls : wall list ;
  _buttons : button list ;
  current_level : int ;
  _tiles : tile array array array ;
}

let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s
