val init : 'a -> < get : 'a; set : 'a -> unit >
(** Initializes an object reference. If [o] is [init v]
    then:
    - [o#get] returns the content of the reference
    - [o#set v] updates the content of the reference with [v].
*)