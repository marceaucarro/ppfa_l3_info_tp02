open Component_defs
(* A module to initialize and retrieve the global state *)
type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player1 : player;
  player2 : player;
  ball : ball;
  mutable waiting : int;
}

val get : unit -> t
val set : t -> unit
