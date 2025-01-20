class t : ?name:string -> unit ->
  object
    method name : string
  end
(** An entity is just an OCaml object which contains at least
    an internal id and a name. The internal id is already
    present in all OCaml object and accessible through [Oo.id].
    To build such an entity, one can do
    [new Entity.t ()] in which case the name will be the default
    value ["__NO_NAME__"], otherwise one may call:
    [new Entity.t ~name:"Foo" ()]
*)

val pp : Format.formatter -> #t -> unit

val delete : #t -> unit
(** [delete e] deletes an entity.
    Deleting an entity unregisters it from the various sytems it
    is registered against, freeing the associated resources.
    @see {register}
*)

val register : t -> (unit -> unit) -> unit
(** [register id finalizer] is used internally by {System} to
    register finalizers for systems. This allows one to simply
    call delete on an entity, it will be automatically removed from the systems
    it's registered against.
*)


(** A module implementing a hash table whose keys are entity IDs.
    This module implements a subset of the {Hashtbl.S} signature.
    The implementation is faster for our use case and more compact in memory.
*)
module Table : sig
  type ('e, 'v) t constraint 'e = #t

  val create : int -> (#t, 'v) t
  val clear : ('e, 'v) t -> unit
  val reset : ('e, 'v) t -> unit
  val length : ('e, 'v) t -> int
  val add : (#t as 'e, 'v) t ->  'e -> 'v -> unit
  val replace : (#t as 'e, 'v) t ->  'e -> 'v -> unit
  val mem : (#t as 'e, 'v) t -> 'e -> bool
  val find : (#t as 'e, 'v) t -> 'e -> 'v
  val find_opt : (#t as 'e, 'v) t -> 'e -> 'v option
  val remove : (#t as 'e, 'v) t -> 'e -> unit
  val iter : ((#t as 'e) -> 'v -> unit) -> ('e, 'v) t -> unit
  val fold : ((#t as 'e) -> 'v -> 'a -> 'a) -> ('e, 'v) t -> 'a -> 'a
  val to_seq : (#t as 'e, 'v) t -> ('e * 'v) Seq.t
  val to_seq_keys :  (#t as 'e, 'v) t -> 'e Seq.t
  val to_seq_values :  (#t as 'e, 'v) t -> 'v Seq.t

end