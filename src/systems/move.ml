open Component_defs


type t = movable


let init _ = ()


let dt = 1000. /. 60.


let update_move_player p =
  let v = p#velocity#get in
  let pos = p#position#get in
  let new_pos = Vector.add pos (Vector.mult dt v) in
  p#position#set new_pos


let update_move_screen s =
  let Global.{ _player ; _ } = Global.get () in
  s#position#set (Vector.sub (_player#position#get) (Vector.{ x = 370.0 ; y = 400.0}))


let update _dt el =
  let Global.{ current_level ; _ } = Global.get () in
  if ( current_level#get > 0 ) then
    begin
      Seq.iter ( fun (e : t) ->
        match (e#tag#get) with
        | Player(p) -> update_move_player p
        | Screen -> update_move_screen e
        | _ -> ()
      )
    end
  el
