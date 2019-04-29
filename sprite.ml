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
    Image.load_texture renderer path
    |> Results.and_then (fun texture ->
        Sdl.query_texture texture |> Results.map (create_sprite texture)
      )
