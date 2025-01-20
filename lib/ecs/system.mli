(** The input signature for the [Make] functor. *)
module type T =
sig
  type t = private #Entity.t
  (** The type of entities that can be registered, which must
      be a subtype of [Entity.t].
  *)

  val init : float -> unit
  (** An initialization function that can be called from the main loop. It
      receives the current time as argument and can initialize private data
      structures. *)

  val update : float -> t Seq.t -> unit
  (** An update function that can be called from the main loop. It receives
      as argument the current time and the sequence of entities registered
      against the system.
  *)
end

(** The output signature of the [Make] functor. *)
module type S =
sig
  type t
  (** The type of entities that can be registered. *)

  val init : float -> unit
  (** The initialization function. *)

  val update : float -> unit
  (** The update function. *)

  val register : t -> unit
  (** Registers an entity so that it can be processed by the system.
      @raise Failure if the entity is already registered.
  *)

  val unregister : t -> unit
  (** Unregisters an entity. *)

  val reset : unit -> unit
  (** Remove all entities from the system. *)

end

module Make (X : T) : S with type t = X.t

val init_all : float -> unit
(** A convenience function that calls the [init] function of
    all modules that have been created by the [Make] functor.*)

val update_all : float -> unit
(** A convenience function that calls the [update] function of
    all modules that have been created by the [Make] functor.*)
