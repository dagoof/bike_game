open Tsdl

type t =
    { rect : Sdl.rect
    }

let render t renderer =
    Sdl.render_fill_rect renderer (Some t.rect)


let create x y =
    { rect = Sdl.Rect.create x y 45 56 }
