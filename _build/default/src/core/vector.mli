type t = { x : float; y : float; }
(** The type of 2D Vectors *)

val add : t -> t -> t
(** Addition of vectors *)

val sub : t -> t -> t
(** Subtraction of vectors *)

val mult : float -> t -> t
(** Multiplication of a floating point number by a vector *)

val dot : t -> t -> float
(** Dot product (scalar product) *)

val norm : t -> float
(** Norm of a vector *)

val normalize : t -> t
(** Normlized vector *)

val pp : Format.formatter -> t -> unit
(** Pretty printer for a vector *)

val zero : t
(** The null vector *)

val is_zero : t -> bool
(** Test for the null vector *)