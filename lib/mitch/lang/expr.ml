open Mitch_utils

type kind =
  | Native of string
  | Function of kind * kind

type tInt = T_INT
type tUnit = T_UNIT
type ('a, 'b) tFun = T_FUN
type ('a, 'b) tSum = T_SUM
type ('a, 'b) tProd = T_PROD

type _ t =
  | Unit : tUnit t
  | Int : int -> tInt t
  | Abs : string * 'a t -> ('b, 'a) tFun t
  | App : ('a, 'b) tFun t * 'a t -> 'b t
  | Var : string -> 'a t
  | Inl : 'a t -> ('a, 'b) tSum t
  | Inr : 'b t -> ('a, 'b) tSum t
  | Case : ('a, 'b) tSum t * ('a, 'c) tFun t * ('b, 'c) tFun t -> 'c t
  | Pair : 'a t * 'b t -> ('a, 'b) tProd t
  | Fst : ('a, 'b) tProd t -> 'a t
  | Snd : ('a, 'b) tProd t -> 'b t
  | Let : string * 'a t * 'b t -> 'b t
  | Rec : string * ('a, 'b) tFun t -> ('a, 'b) tFun t

(* Renderer *)

let rec render : type a. Format.formatter -> a t -> unit =
 fun ppf ->
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
  | Rec (n, c) -> fprintf ppf "rec(%s,%a)" n render c

let to_string : type a. a t -> string = fun o -> Render.to_string render o
