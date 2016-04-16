open Tsdl

let pi = 4.0 *. atan 1.0
let pi2 = pi *. 2.0

type t =
    { x : float
    ; y : float
    ; size : int
    ; speed : float
    ; a : float
    ; v : float
    ; t : float
    }

type action
    = Nothing
    | Flush
    | Left
    | Right
    | Up
    | Down
    | Click of (int * int)

let render renderer t =
    let d = t.size / 2 in
    let x = int_of_float t.x in
    let y = int_of_float t.y in
    let rect = Sdl.Rect.create (x - d) (y - d) t.size t.size in
    Sdl.render_fill_rect renderer (Some rect)

let renderer = Renderer.create render

(*
let update action t =
    let dx = (cos t.t) *. t.v in
    let dy = (sin t.t) *. t.v in
    let gy = dy +. 0.5 in
    { t with
      x = t.x +. dx
    ; y = t.y +. dy
    ; t = atan2 gy dx
    }

let update_within (w, h) action t =
    let nt = update t in
    let next =
        { nt with
          x = min (max 0.0 nt.x) w
        ; y = min (max 0.0 nt.y) h
        }
    in
    if next = nt
    then next
    else { next with t = mod_float (next.t +. pi) pi2 }
*)

let ga = 0.2
let gt = 1.0

let grounded (w, h) t =
    let v0 = t.v *. gt in
    let v1 = v0 +. (0.5 *. ga *. (gt ** 2.0)) in
    let t' = { t with v = v1; y = t.y +. v1 } in
    if t'.y >= h
    then { t' with y = h; v = 0.0 }
    else t'

let update (w, h) action t =
    let mass = float_of_int t.size in
    let motion = t.speed /. mass in
    match action with
    | Nothing -> t
    | Flush -> grounded (w, h) t
    | Left ->
        { t with x = t.x -. motion }
    | Right ->
        { t with x = t.x +. motion }
    | Up ->
        { t with v = -.motion }
    | Down ->
        { t with y = t.y +. t.speed }
    | Click (mouse_x, mouse_y) ->
        { t with y = t.y -. (t.speed *. 5.0) }

let create x y =
    let size = 2 + (Random.int 10) in
    { x = x
    ; y = y
    ; size = size
    ; speed = 10.0
    ; a = 0.0
    ; v = Random.float 1.0
    ; t = Random.float pi2
    }
