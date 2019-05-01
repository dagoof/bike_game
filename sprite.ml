open Tsdl
open Result
open Tsdl_image
open Batteries

type t =
  { tex : Sdl.texture
  ; w : int
  ; h : int
  }

let create renderer path =
  let create_sprite texture (_, _, (width, height)) =
    { tex = texture
    ; w = width
    ; h = height
    }
  in
  Rresult.(
    Image.load_texture renderer path >>= fun texture ->
    Sdl.query_texture texture >>|
    create_sprite texture
  )
