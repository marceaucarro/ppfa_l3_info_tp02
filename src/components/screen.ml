open Component_defs
open System_defs

let screen () =
  let e = new screen () in
  e#id_level#set 0 ;
  e#tag#set Screen ;
  e#position#set Vector.{ x = 0.0 ; y = 0.0 } ;
  e#velocity#set Vector.zero ;
  e#box#set Rect.{ width = Cst.window_width ; height = Cst.window_height } ;
  Move_system.(register (e :> t)) ;
  e

let screens () =
  screen ()
