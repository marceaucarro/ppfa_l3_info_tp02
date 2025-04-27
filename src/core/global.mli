open Component_defs
(* A module to initialize and retrieve the global state *)
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

val get : unit -> t
val set : t -> unit
