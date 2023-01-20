open Mitch_vm
open Objvalue
open Preface.Result

module Monad = Monad (struct
  type t = string
end)

let rec get_index i n = function
  | Var m :: _ when n = m -> Ok i
  | _ :: s -> get_index (i + 1) n s
  | [] -> Error ("Variable not found: " ^ n)

let generate (o, s) =
  let open Monad in
  let open Objcode in
  let push_in r a = a :: r in
  let rec generate s r =
    match s with
    | [] -> Ok r
    | [ Var _ ] -> Ok r
    | Var f :: a :: s -> SWAP |> push_in r |> generate (a :: Var f :: s)
    | Dup n :: s ->
      get_index 0 n s <&> (fun i -> DUP (i, n)) <&> push_in r >>= generate s
    | Val a :: s -> PUSH a |> push_in r |> generate s
    | Code (n, a) :: s -> LAMBDA (n, a) |> push_in r |> generate s
    | Exec (a, c) :: s -> EXEC |> push_in r |> generate (c :: a :: s)
    | Car a :: s -> CAR |> push_in r |> generate (a :: s)
    | Cdr a :: s -> CDR |> push_in r |> generate (a :: s)
    | Pair (pl, pr) :: s -> PAIR |> push_in r |> generate (pl :: pr :: s)
    | Left a :: s -> LEFT |> push_in r |> generate (a :: s)
    | Right a :: s -> RIGHT |> push_in r |> generate (a :: s)
    | IfLeft (a, pl, pr) :: s ->
      IF_LEFT (pl, pr) |> push_in r |> generate (a :: s)
  in
  generate s o

let rec remove_at l i =
  if i = 0
  then (List.hd l, List.tl l)
  else
    let h, t = remove_at (List.tl l) (i - 1) in
    (h, List.hd l :: t)

let rec optimise_instruction s =
  let open Monad in
  let open Objcode in
  function
  | PUSH v -> Ok ([], Val v :: s)
  | EXEC -> (
    match s with
    | a :: Code (_, c) :: s -> optimise (a :: s) c
    | a :: c :: s -> Ok ([], Exec (c, a) :: s)
    | _ -> Ok ([ EXEC ], s) )
  | LAMBDA (n, a) ->
    let+ o = optimise [ Var n ] a >>= generate in
    ([], Code (n, o) :: s)
  | DIG (i, n) -> Ok ([ DIG (i, n) ], s)
  | DUP (i, n) ->
    Ok
      ( match List.nth_opt s i with
      | None -> ([ DUP (i, n) ], s)
      | Some (Var f) -> ([], Dup f :: s)
      | Some a -> ([], a :: s) )
  | DROP (i, n) ->
    Ok
      ( if List.length s <= i
      then ([ DROP (i, n) ], s)
      else
        (* Dropped effects should be prohibited *)
        match remove_at s i with
        | Var _, _ -> ([ DROP (i, n) ], s)
        | _, s -> ([], s) )
  | SWAP ->
    Ok (match s with a :: b :: s -> ([], b :: a :: s) | _ -> ([ SWAP ], s))
  | LEFT -> Ok (match s with a :: s -> ([], Left a :: s) | [] -> ([ LEFT ], s))
  | RIGHT ->
    Ok (match s with a :: s -> ([], Right a :: s) | [] -> ([ RIGHT ], s))
  | IF_LEFT (l, r) -> (
    match s with
    | Left v :: s -> optimise (v :: s) l
    | Right v :: s -> optimise (v :: s) r
    | _ ->
      (* Not optimal code right now! *)
      let* l = optimise [] l >>= generate in
      let+ r = optimise [] r >>= generate in
      if List.length s = 0
      then ([ IF_LEFT (l, r) ], s)
      else ([], IfLeft (List.hd s, l, r) :: List.tl s) )
  | CAR ->
    Ok
      ( match s with
      | Pair (a, _) :: s -> ([], a :: s)
      | a :: s -> ([], Car a :: s)
      | [] -> ([ CAR ], s) )
  | CDR ->
    Ok
      ( match s with
      | Pair (_, a) :: s -> ([], a :: s)
      | a :: s -> ([], Cdr a :: s)
      | [] -> ([ CDR ], s) )
  | PAIR ->
    Ok
      (match s with a :: b :: s -> ([], Pair (a, b) :: s) | _ -> ([ PAIR ], s))

and optimise s c =
  let open Monad in
  match c with
  | [] -> Ok ([], s)
  | a :: l ->
    let* o, s = optimise_instruction s a in
    (* review this part *)
    if o = []
    then optimise s l
    else optimise [] l >>= generate <&> fun l -> (o @ l, s)

let optimise o =
  let open Monad in
  optimise [] o >>= generate

let run o = optimise o
