
open Ecs

module Collision_system = System.Make(Collision)

module Draw_system = System.Make(Draw)

module Force_system = System.Make (Forces)

module Move_system = System.Make(Move)