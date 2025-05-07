open Component_defs
(* A module to initialize and retrieve the global state *)
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


val get : unit -> t
val set : t -> unit
