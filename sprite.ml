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
    let fail_message = Printf.sprintf "failed to load image %s" path in
    let fail_result = Error (`Msg fail_message) in
    let create_sprite texture (_, _, (width, height)) =
        { tex = texture
        ; w = width
        ; h = height
        }
    in
    Image.load_texture renderer path
    |> Option.map (fun texture ->
        Results.map (create_sprite texture) (Sdl.query_texture texture))
    |> Option.default fail_result
