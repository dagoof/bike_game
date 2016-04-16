open Tsdl
open Tsdl_image

type t =
    { sprite : Sprite.t
    ; x : int
    ; y : int
    }

let create s x y =
    { sprite = s
    ; x = x
    ; y = y
    }

let render renderer t =
    let dst_rect =
        Sdl.Rect.create
        t.x
        t.y
        t.sprite.Sprite.w
        t.sprite.Sprite.h
    in
    Sdl.render_copy ~dst:dst_rect renderer t.sprite.Sprite.tex

let renderer = Renderer.create render
