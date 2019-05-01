module Sdl = Tsdl.Sdl

let resource ~release ~f t =
  let result = f t in
  release t;
  result

module type SIG = sig
  type 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val return : 'a -> 'a t
end

module Make (M : SIG) = struct
  include M
  let join mm = bind mm (fun x -> x)
  let map f m = bind m (fun x -> return (f x))
  let bind2 a b f = bind a (fun x -> bind b (f x))
  let ( >>= ) = bind
  let ( >>| ) m f = map f m
  let ( >> ) m f = bind m (fun _ -> f ()) let lift2 f m1 m2 = m1 >>= fun x -> map (f x) m2
  let ignore m = map (fun _ -> ()) m
end

module Release = struct 
  include Make (struct
      type 'a t = 'a * (unit -> unit)
      let bind (v, r) f =
        let v', r' = f v in
        (v', fun () -> r' (); r ())
      let return x = (x, fun () -> ())
    end)
  let release (v, r) = r (); v
  let pair (m, r) = (m, fun () -> r m)
  let (>>+) m f = pair m >>= f
end


module Resource = struct
  include Make (struct
      type 'a t = 'a Sdl.result Release.t
      let bind (m:'a t) (f: 'a -> 'b t) =
        Release.bind m begin function 
          | Result.Ok v -> f v
          | Result.Error _ as e -> Release.return e
        end
      let return x = Release.return (Rresult.R.return x)
    end)

  let pair (m,release) = match m with
    | Result.Ok v -> (m, fun () -> release v)
    | Result.Error _ as e -> Release.return e
  let (>>+) m f = pair m >>= f
  let (>>-) m f = Release.return m >> f
  let perform t = Release.release t
end
