open Ecs
open Component_defs

type t = collidable

let init _ = ()

let rec iter_pairs f s =
  match s () with
  | Seq.Nil -> ()
  | Seq.Cons(e, s') ->
    Seq.iter (fun e' -> f e e') s' ;
    iter_pairs f s'


let update _dt el =
  el
  |> iter_pairs (fun (e1:t) (e2:t) ->
      let m1 = e1#mass#get in
      let m2 = e2#mass#get in

      if ( Float.is_finite m1 || Float.is_finite m2 ) then 
        begin
          let pos1 = e1#position#get in
          let box1 = e1#box#get in
          let pos2 = e2#position#get in
          let box2 = e2#box#get in
          let v1 = e1#velocity#get in
          let v2 = e2#velocity#get in
          let s_pos, s_rect = Rect.mdiff pos2 box2 pos1 box1 in

          if ( (Rect.has_origin s_pos s_rect)
                && (not (Vector.is_zero v1 && Vector.is_zero v2)) ) then 
            begin
              (* [3] le plus petit des vecteurs a b c d *)
          
              let a = Vector.{ x = s_pos.x ; y = 0.0 } in
              let b = Vector.{ x = float s_rect.width +. s_pos.x ; y = 0.0 } in
              let c = Vector.{ x = 0.0 ; y = s_pos.y } in
              let d = Vector.{ x = 0.0 ; y = float s_rect.height +. s_pos.y } in
              let n = List.fold_left ( fun min_v v ->
                if ( Vector.norm v <= Vector.norm min_v ) then v else min_v)
                d [ a; b; c ]
              in

              if ( n = c ) then (*Colision venant d'au dessus.*)
                begin
                  match e1#tag#get, e2#tag#get with
                    | Player(p), _ -> p#is_airborne#set false ;
                    | _ -> ()
                end
              else if ( n = d ) then  (*Colision venant d'en dessous.*)
                begin
                  match e1#tag#get, e2#tag#get with
                    | _, Player (p) -> p#is_airborne#set false ;
                    | _ -> ()
                end ;
              
              (*  [4] rapport des vitesses et déplacement des objets *)
              let n_v1 = Vector.norm v1 in
              let n_v2 = Vector.norm v2 in
              let s = 1.01 /. (n_v1 +. n_v2) in
              let n1 = n_v1 *. s in
              let n2 = n_v2 *. s in
              let delta_pos1 = Vector.mult n1 n in
              let delta_pos2 = Vector.mult (-.n2) n in
              let pos1 = Vector.add pos1 delta_pos1 in
              let pos2 = Vector.add pos2 delta_pos2 in
              let s_pos, s_rect = Rect.mdiff pos2 box2 pos1 box1 in
          
              if ( Rect.has_origin s_pos s_rect ) then
                  Gfx.debug "%f, %f, %d x %d\n%!" s_pos.Vector.x s_pos.Vector.y
                  s_rect.Rect.width s_rect.Rect.height ;
              e1#position#set pos1 ;
              e2#position#set pos2 ;

              (* [5] On normalise n (on calcule un vecteur de même direction mais de norme 1) *)
              let n = Vector.normalize n in
          
              (* [6] Vitesse relative entre v2 et v1 *)
              let v = Vector.sub v1 v2 in

              (* Préparation au calcul de l'impulsion *)
              (* Elasticité fixe. En pratique, l'elasticité peut être stockée dans
              les objets comme un composant : 1 pour la balle et les murs, 0.5 pour
              des obstacles absorbants, 1.2 pour des obstacles rebondissant, … *)
              let e = (e1#elasticity#get +. e2#elasticity#get) /. 2. in
          
              (* normalisation des masses *)
              let m1, m2 =
                if ( (Float.is_infinite m1) && (Float.is_infinite m2) ) then
                  if ( n_v1 = 0.0 ) then (m1, 1.0)
                  else if ( n_v2 = 0.0 ) then (1.0, m2)
                  else (0.0, 0.0)
                else (m1, m2)
              in

              (* [7] calcul de l'impulsion *)
              (*
              let jbase = -.(1.0 +. e) *. Vector.dot v n in
              let m1divm2 = m1 /. m2 in
              let m2divm1 = m2 /. m1 in
              let j1 = jbase /. (1.0 +. m1divm2) in
              let j2 = jbase /. (1.0 +. m2divm1) in
              *)
              let j = -.(1.0 +. e) *. Vector.dot v n /. ((1. /. m1) +. (1. /. m2)) in
          
              (* [8] calcul des nouvelles vitesses *)
              let new_v1 = Vector.add v1 (Vector.mult (j/. m1) n) in
              let new_v2 = Vector.sub v2 (Vector.mult (j/. m2) n) in
          
              (* [9] mise à jour des vitesses *)
              e1#velocity#set new_v1 ;
              e2#velocity#set new_v2
            end
        end)

let update _dt el =
  for i = 0 to 3 do
    update _dt el
  done
