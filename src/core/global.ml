open Component_defs

type t = {
  window : Gfx.window ;
  ctx : Gfx.context ;
  current_level : < get : int ; set : int -> unit > ;
  _screen : screen ;
  _player : player ;
  _enemies : enemy array ;
  _buttons : button list ;
  _walls : wall list array ;
  _tiles : tile list array array ;
  _overlays : overlay array ;
}

let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s
