open Ecs
open Component_defs

type t = collidable

let init _ = ()

let rec iter_pairs f s =
  match s () with
    Seq.Nil -> ()
  | Seq.Cons(e, s') ->
    Seq.iter (fun e' -> f e e') s';
    iter_pairs f s'


let update _ el =
  el
  |> iter_pairs (fun (e1:t) (e2:t) ->

      let pos1 = e1#position#get in
      let pos2 = e2#position#get in
      let box1 = e1#box#get in
      let box2 = e2#box#get in
      match Rect.rebound pos1 box1 pos2 box2 with
        None -> ()
      | Some v ->
        e1#resolve#get v (e2 :> tagged);
        e2#resolve#get v (e1 :> tagged)
    )
