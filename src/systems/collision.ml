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
        if (Float.is_finite e1#mass#get || Float.is_finite e1#mass#get) then
          
          let v1n = Vector.norm e1#velocity#get in
          let v2n = Vector.norm e2#velocity#get in
          let n1, n2 =
            if v1n != 0.0 || v2n != 0.0 then
              begin
                if not (Float.is_finite e1#mass#get) then 0.0, 1.0
                else if not (Float.is_finite e1#mass#get) then 1.0, 0.0
                else v1n /. (v1n +. v2n), (v2n /. (v1n +. v2n))
              end
            else
              
          in
          e1#resolve#get v (e2 :> tagged);
          e2#resolve#get v (e1 :> tagged)
    )
