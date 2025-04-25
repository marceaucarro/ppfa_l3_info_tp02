let key_table = Hashtbl.create 16
let has_key s = Hashtbl.mem key_table s
let set_key s v = Hashtbl.replace key_table s v
let unset_key s = Hashtbl.remove key_table s

let action_table = Hashtbl.create 16
let register key action = Hashtbl.replace action_table key action

let handle_input () =
  let () = begin
  match Gfx.poll_event () with
    KeyDown s -> set_key s (0, 0) ; Gfx.debug "%s\n%!" s
  | KeyUp s -> unset_key s; Gfx.debug "%s\n%!" s
  | MouseMove (x, y) -> set_key "mousemove" (x, y) ; Gfx.debug "mousemove at x:%d , y:%d\n%!" x y
  | MouseButton (button, pressed, x, y) ->
        if ( button = 0 ) then
          begin  
            if (pressed) then
              begin
                set_key "mousedown" (x, y) ; Gfx.debug "mousedown at x:%d , y:%d\n%!" x y
              end
            else
              begin
                unset_key "mousedown" ;
                set_key "mouseup" (x, y) ; Gfx.debug "mouseup at x:%d , y:%d\n%!" x y
              end
          end
  | Quit -> exit 0
  | _ -> ()
  end in
  Hashtbl.iter (fun key action ->
      if has_key key then action ()) action_table ;
  if (has_key "mouseup") then
    unset_key "mouseup"

let () =
  register "mousemove" ( fun () ->
    let xmouse, ymouse = Hashtbl.find key_table "mousemove" in
    let Global.{_buttons; _} = Global.get () in (*liste des boutons disponibles*)
    List.iter ( fun b ->
      let Vector.{x ; y } = b#position#get in
      let x1, y1 = ((int_of_float x), (int_of_float y)) in
      let Rect.{width ; height} = b#box#get in
      let x2 = width+x1 in
      let y2 = height+y1 in
      if ( ( x1 <= xmouse ) && ( xmouse <= x2 ) && (y1 <= ymouse) && (ymouse <= y2) ) then
        b#hovered_over#set true
      else
        b#hovered_over#set false
    ) _buttons ;
  ) ;
  register "mousedown" ( fun () ->
    let xmouse, ymouse = Hashtbl.find key_table "mousedown" in
    let Global.{_buttons; _} = Global.get () in (*liste des boutons disponibles*)
    List.iter ( fun b ->
      let Vector.{x ; y } = b#position#get in
      let x1, y1 = ((int_of_float x), (int_of_float y)) in
      let Rect.{width ; height} = b#box#get in
      let x2 = width+x1 in
      let y2 = height+y1 in
      if ( ( x1 <= xmouse ) && ( xmouse <= x2 ) && (y1 <= ymouse) && (ymouse <= y2) ) then
        b#clicked#set true
    ) _buttons ;
  ) ;
  register "mouseup" ( fun () ->
    let xmouse, ymouse = Hashtbl.find key_table "mouseup" in
    let Global.{_buttons; _} = Global.get () in (*liste des boutons disponibles*)
    List.iter ( fun b ->
      let Vector.{x ; y } = b#position#get in
      let x1, y1 = ((int_of_float x), (int_of_float y)) in
      let Rect.{width ; height} = b#box#get in
      let x2 = width+x1 in
      let y2 = height+y1 in
      if ( b#clicked#get ) then
        b#clicked#set false ;
      if ( ( x1 <= xmouse ) && ( xmouse <= x2 ) && (y1 <= ymouse) && (ymouse <= y2) ) then
          b#action#get ()
    ) _buttons ;
  ) ;
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
