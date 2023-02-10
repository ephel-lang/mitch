type native =
  | TInt
  | TUnit

type tInt = T_INT
type tUnit = T_UNIT
type ('a, 'b) tFun = T_FUN
type ('a, 'b) tSum = T_SUM
type ('a, 'b) tProd = T_PROD

type t =
  | Arrow : t * t -> t
  | Product : t * t -> t
  | Sum : t * t -> t
  | Native : string -> t
