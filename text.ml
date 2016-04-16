open Tsdl
open Result
open Tsdl_ttf
open Batteries

type font =
    { filename : string
    ; size : int
    ; color : Sdl.color
    ; source : Ttf.font
    }

type t =
    { font : font
    ; content : string
    ; x : int
    ; y : int
    }

let create filename size color =
    Ttf.open_font filename size |>
    Option.map begin fun source ->
        { filename = filename
        ; size = size
        ; color = color
        ; source = source
        }
    end

let write font message x y =
    { font = font
    ; content = message
    ; x = x
    ; y = y
    }

let destroy font =
    Ttf.close_font font.source

let render renderer t =
    Ttf.render_text_solid t.font.source t.content t.font.color
    |> Option.map (fun surface ->
        let ( w, h ) = Sdl.get_surface_size surface in
        let placement = Sdl.Rect.create t.x t.y w h in
        let result =
            Sdl.create_texture_from_surface renderer surface
            |> Results.and_then (fun texture ->
                let result = Sdl.render_copy ~dst:placement renderer texture in
                Sdl.destroy_texture texture;
                result
            )
        in
        Sdl.free_surface surface;
        result
    )
    |> Option.default (Error (`Msg "font render failed"))

let renderer = Renderer.create render
