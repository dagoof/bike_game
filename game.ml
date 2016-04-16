open Tsdl
open Tsdl_image
open Tsdl_ttf
open Result

let width = 144
let height = 256
let scale = 4

let unscale (mouse_x, mouse_y) =
    (mouse_x / scale, mouse_y / scale)

let screen = (float_of_int width, float_of_int height)
let font_size = 10
let white = Sdl.Color.create 0xFF 0xFF 0xFF 0xFF

exception Fucked of string

let value = function
    | Error (`Msg e) -> raise (Fucked e)
    | Ok v -> v

let of_option = function
    | None -> raise (Fucked "cant do option")
    | Some v -> v

type 'event_type action =
    | Game of Sdl.event * 'event_type
    | Ticks of int * Sdl.uint32

type sprites =
    { tree : Sprite_entity.t
    ; player : Sprite.t
    }

type state =
    { player : Entity.t
    ; target : Entity.t list
    ; ticks : int * Sdl.uint32
    ; font : Text.font
    ; sprites : sprites
    ; tree_lifted : bool
    }

let init renderer =
    let scale' = float_of_int scale in
    Sdl.render_set_scale renderer scale' scale' |> Results.value;

    let munro = Text.create "Munro.ttf" 10 white in
    let player_sprite = Sprite.create renderer "white-egg.png" in
    let tree_sprite = Sprite.create renderer "tree.png" in
    let tree_sprite_entity =
        tree_sprite
        |> Results.map (fun sprite -> Sprite_entity.create sprite 50 100)
    in
    let sprites =
        { tree = tree_sprite_entity |> Results.value
        ; player = player_sprite |> Results.value
        }
    in
    { player = { (Entity.create 50.0 128.0) with Entity.size = 4 }
    ; target = List.map
        (fun v -> Entity.create (Random.float 128.0) 128.0)
        [1;2;3;4;5;6;7]
    ; ticks = (0, 0l)
    ; font = munro |> Results.of_option
    ; sprites = sprites
    ; tree_lifted = false
    }

let key_scancode e =
    Sdl.Scancode.enum Sdl.Event.(get e keyboard_scancode)

let update_state s = function
    | Ticks (gen, time) ->
        { s with
          player = Entity.update screen Entity.Flush s.player
        ; target = List.map (Entity.update screen Entity.Flush) s.target
        ; ticks = (gen, time)
        }
    | Game (event, event_type) ->
        let action = match event_type with
        | `Key_down when key_scancode event = `Up -> Entity.Up
        | `Key_down when key_scancode event = `Down -> Entity.Down
        | `Key_down when key_scancode event = `Left -> Entity.Left
        | `Key_down when key_scancode event = `Right -> Entity.Right
        | `Mouse_button_down ->
            let (mask, mouse_pos) = Sdl.get_mouse_state () in
            Entity.Click (unscale mouse_pos)
        | _ -> Entity.Nothing
        in
        { s with
          player = Entity.update screen action s.player
        ; target = List.map (Entity.update screen action) s.target
        }

let update_sprite_entity s = function
    | Ticks (gen, time) -> s
    | Game (event, event_type) ->
        match event_type with
        | `Mouse_motion ->
            if not s.tree_lifted
            then s
            else
                let (mask, mouse_pos) = Sdl.get_mouse_state () in
                let (mouse_x, mouse_y) = unscale mouse_pos in
                let tree' = s.sprites.tree in
                let tree =
                    { tree' with
                      Sprite_entity.x = mouse_x - (tree'.Sprite_entity.sprite.Sprite.w / 2)
                    ; Sprite_entity.y = mouse_y - (tree'.Sprite_entity.sprite.Sprite.h / 2)
                    }
                in
                { s with
                  sprites = { s.sprites with tree = tree }
                }
        | `Mouse_button_down ->
            { s with tree_lifted = not s.tree_lifted }
        | _ -> s

let update s action =
    let state0 = update_state s action in
    update_sprite_entity state0 action


let draw r state =
    let message = Text.write state.font "welcome to game" 16 10 in
    let chorus = Text.write state.font "Campagnolo Chorus" 16 22 in
    let record = Text.write state.font "Campagnolo Super Record" 16 34 in
    let pos =
        let msg =
            Printf.sprintf
            "x:%.2f y:%.2f"
            state.player.Entity.x
            state.player.Entity.y
        in Text.write state.font msg 16 (height - 32)
    in
    let stats =
        let msg =
            Printf.sprintf
            "t:%.2f v:%.2f"
            state.player.Entity.t
            state.player.Entity.v
        in Text.write state.font msg 16 (height - 20)
    in
    Sdl.set_render_draw_color r 0x00 0x00 0x00 0x00 |> Results.value;
    Sdl.render_clear r |> value;
    Sdl.set_render_draw_color r 0xFF 0xFF 0xFF 0xFF |> Results.value;

    let egg  =
        Sprite_entity.create
            state.sprites.player
            (int_of_float state.player.Entity.x)
            (int_of_float state.player.Entity.y)
    in
    Sprite_entity.render r state.sprites.tree |> Results.value;
    Sprite_entity.render r egg |> Results.value;

    Renderer.and_then
        ( Renderer.and_then
            ( Entity.renderer state.player )
            ( Renderer.sequence ( List.map Entity.renderer state.target ))
        )
        ( Renderer.sequence
            ( List.map Text.renderer
                [ message
                ; chorus
                ; record
                ; pos
                ; stats
                ]
            )
        )
    |> Renderer.render r
    |> Results.map (fun () -> Sdl.render_present r)
    |> Results.on_error (fun (`Msg text) ->
        Sdl.log "render fuckewd up with error %s" text
    )


let run send =
    let finished = ref false in
    let event = Sdl.Event.create () in
    let t = ref 0 in
    while not !finished do
        t := 1 + !t;
        while Sdl.poll_event (Some event) do
            match Sdl.Event.(enum (get event typ)) with
            | `Quit -> finished := true
            | e -> send (Game (event, e))
        done;
        send (Ticks (!t, Sdl.get_ticks ()));
        Sdl.delay 17l
    done

let main () =
    Sdl.init Sdl.Init.video
    |> Results.and_then Ttf.init
    |> Results.and_then (fun () ->
        Sdl.create_window_and_renderer
            ~w:(width * scale)
            ~h:(height * scale)
            Sdl.Window.shown
    )
    |> Results.map (fun (window, renderer) ->
        let e, send = React.E.create () in
        let state   = React.S.fold update (init renderer) e in
        let view    = React.S.map (draw renderer) state in
        run send;
        React.E.stop e;
        React.S.stop state;
        React.S.stop view;

        Sdl.destroy_renderer renderer;
        Sdl.destroy_window window;
        Sdl.quit ()
    )
    |> value

let () =
    main ()
