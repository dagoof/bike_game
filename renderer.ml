open Tsdl
open Result

type 'a t =
    { run : (Sdl.renderer -> 'a -> unit Sdl.result)
    ; ctx : 'a
    }

let create run ctx =
    { run = run
    ; ctx = ctx
    }

let render renderer t =
    t.run renderer t.ctx

let always x y = x

let and_then a b =
    { run = begin fun renderer (ac, bc) ->
        Results.and_then (always (render renderer bc)) (render renderer ac)
    end
    ; ctx = (a, b)
    }

let blank =
    { run = ( fun renderer t -> Ok () )
    ; ctx = ()
    }


let sequence items =
    { run = begin fun renderer items ->
        let folder acc item =
            Results.and_then (always (render renderer item)) acc
        in
        List.fold_left folder (Ok ()) items
    end
    ; ctx = items
    }
