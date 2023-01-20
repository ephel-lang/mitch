open Mitch_utils

type kind =
  | Native of string
  | Function of kind * kind

type t =
  | Unit
  | Int of int
  | Abs of string * t
  | App of t * t
  | Var of string
  | Inl of t
  | Inr of t
  | Case of t * t * t
  | Pair of t * t
  | Fst of t
  | Snd of t
  | Let of string * t * t

(* Renderer *)

let rec render ppf =
  let open Format in
  function
  | Abs (n, c) -> fprintf ppf "fun %s -> %a" n render c
  | App (l, r) -> fprintf ppf "%a (%a)" render l render r
  | Var n -> fprintf ppf "%s" n
  | Unit -> fprintf ppf "unit"
  | Int i -> fprintf ppf "%d" i
  | Inl c -> fprintf ppf "(inl %a)" render c
  | Inr c -> fprintf ppf "(inr %a)" render c
  | Case (c, l, r) -> fprintf ppf "case %a (%a) (%a)" render c render l render r
  | Pair (l, r) -> fprintf ppf "(%a,%a)" render l render r
  | Fst e -> fprintf ppf "fst(%a)" render e
  | Snd e -> fprintf ppf "snd(%a)" render e
  | Let (n, e, f) -> fprintf ppf "let %s = %a in %a" n render e render f

let to_string o = Render.to_string render o
