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
