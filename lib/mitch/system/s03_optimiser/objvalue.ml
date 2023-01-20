open Mitch_vm

type t =
  | Var of string
  | Dup of string
  | Val of Objcode.value
  | Code of string * Objcode.t list
  | Exec of t * t
  | Left of t
  | Right of t
  | Pair of t * t
  | Car of t
  | Cdr of t
  | IfLeft of t * Objcode.t list * Objcode.t list

let rec render_value ppf =
  let open Format in
  function
  | Var n -> fprintf ppf "%s" n
  | Dup n -> fprintf ppf "copy(%s)" n
  | Val v -> Objcode.render_value ppf v
  | Code (_, c) -> Objcode.render ppf c
  | Exec (a, b) -> fprintf ppf "Exec(%a,%a)" render_value a render_value b
  | Car a -> fprintf ppf "Car(%a)" render_value a
  | Cdr a -> fprintf ppf "Cdr(%a)" render_value a
  | Pair (a, b) -> fprintf ppf "Pair(%a,%a)" render_value a render_value b
  | Left a -> fprintf ppf "Left(%a)" render_value a
  | Right a -> fprintf ppf "Right(%a)" render_value a
  | IfLeft (a, l, r) ->
    fprintf ppf "IfLeft(%a,%a,%a)" render_value a Objcode.render l
      Objcode.render r

let rec render_values ppf =
  let open Format in
  function
  | [] -> () | a :: s -> fprintf ppf "%a; %a" render_value a render_values s
