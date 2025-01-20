open Component_defs

type t = {
  window : Gfx.window;
  ctx : Gfx.context;
  player1 : player;
  player2 : player;
  ball : ball;
  mutable waiting : int;
}

let state = ref None

let get () : t =
  match !state with
    None -> failwith "Uninitialized global state"
  | Some s -> s

let set s = state := Some s
