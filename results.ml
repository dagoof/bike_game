open Result

exception Fucked of string

let and_then fn = function
    | Error e as err -> err
    | Ok v -> fn v

let map fn = function
    | Error e as err -> err
    | Ok v -> Ok (fn v)

let value = function
    | Error (`Msg e) -> raise (Fucked e)
    | Ok v -> v

let of_option = function
    | None -> raise (Fucked "cant do option")
    | Some v -> v

let on_error fn = function
    | Ok v as good -> good
    | Error e -> Ok (fn e)
