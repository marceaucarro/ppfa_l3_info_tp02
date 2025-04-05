let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s= Hashtbl.replace key_table s ()
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action

let handle_input () =
  let () = begin
  match Gfx.poll_event () with
    KeyDown s -> set_key s
  | KeyUp s -> unset_key s
  | Quit -> exit 0
  | _ -> ()
  end in
  Hashtbl.iter (fun key action ->
      if has_key key then action ()) action_table

let () =
  register "q" (
    fun () ->
      let p1 = Player.(player1()) in
      let v = p1#velocity#get in
      if v.x > Cst.player_v_left.x then
        Player.(move_player p1 (Vector.add v (Vector.mult 0.1 Cst.player_v_left)))
      else
        Player.(move_player p1 (Vector.{x = Cst.player_v_left.x; y = v.y}))
  );
  register "d" (
    fun () ->
      let p1 = Player.(player1()) in
      let v = p1#velocity#get in
      if v.x < Cst.player_v_right.x then
        Player.(move_player p1 (Vector.add v (Vector.mult 0.1 Cst.player_v_right)))
      else
        Player.(move_player p1 (Vector.{x = Cst.player_v_right.x; y = v.y}))
  );
  register " " (
    fun () ->
      let p1 = Player.(player1()) in
      if not (p1#is_airborne#get) then begin
        p1#is_airborne#set true;
        let v = p1#velocity#get in
        Player.(move_player p1 (Vector.{x = v.x; y = Cst.player_v_jump.y}))
      end
  )
  (*register "s" (fun () ->
      let global = Global.get () in
      global.waiting <- 1;
    )
  *)