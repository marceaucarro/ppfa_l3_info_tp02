open Vector

type t = { width : int; height : int }


(* We use the Minkowski difference of Box1 and Box2:
   https://en.wikipedia.org/wiki/Minkowski_addition#Collision_detection
*)

let mdiff v1 r1 v2 r2 =
  let x = v1.x -. v2.x -. float r2.width in
  let y = v1.y -. v2.y -. float r2.height in
  let h = r1.height + r2.height in
  let w = r1.width + r2.width in
  ({ x; y }, { width = w; height = h })


let min_norm v1 v2 =
  if Vector.norm v1 <= Vector.norm v2 then v1 else v2

let has_origin v r =
  v.x < 0.0
  && v.x +. float r.width > 0.0
  && v.y < 0.0
  && v.y +. float r.height > 0.0

let intersect v1 r1 v2 r2 =
  let s_pos, s_rect = mdiff v1 r1 v2 r2 in
  has_origin s_pos s_rect

let is_zero f = f = 0.0 || f = -0.0

(*
  Given the Mdiff of two boxes, if they intersect,
  returns the penetration vector, that is the smallest
  vector one should move the boxes away from to separate them:


  -------------------
  |                 |
  |    --------     |   -
  |    |      |     |   |  <- penetration vector can separate the boxes
  |----+------+------   v
       |      |
       |      |
       --------

*)
let penetration_vector s_pos s_rect =
  let n0 = Vector.{ x = 0.0; y = s_pos.y } in
  let n1 = min_norm n0 Vector.{ x = 0.0; y = float s_rect.height +. s_pos.y } in
  let n2 = min_norm n1 Vector.{ x = s_pos.x; y = 0.0 } in
  min_norm n2 Vector.{ x = float s_rect.width +. s_pos.x; y = 0.0 }

(* Returns None if the two boxes don't intersect and Some v
   if they do, where v is the rebound to apply, assuming one
    of the object is fixed.
*)
let rebound v1 r1 v2 r2 = 
  let s_pos, s_rect = mdiff v1 r1 v2 r2 in
  if has_origin s_pos s_rect then
    let n = penetration_vector s_pos s_rect in
    Some (if is_zero n.x then Vector.{ x = 1.0; y = -1.0 } else
            Vector.{x = -1.0; y = 1.0 })
  else None