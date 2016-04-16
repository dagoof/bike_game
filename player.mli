open Tsdl

type t

val render : t -> Sdl.renderer -> unit Sdl.result

val create : int -> int -> t
