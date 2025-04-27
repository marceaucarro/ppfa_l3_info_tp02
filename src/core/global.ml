open Component_defs

type t = {
  window : Gfx.window ;
  ctx : Gfx.context ;
  current_level : int ;
  player1 : player ;
  _enemies : enemy list ;
  _walls : wall list ;
  _buttons : button list ;
  _tiles : tile array array array ;
  decor : decor
}

let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s
