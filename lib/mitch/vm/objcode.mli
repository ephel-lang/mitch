type value =
  | INT of int
  | UNIT

type t =
  | PUSH of value
  | EXEC
  | LAMBDA of string * t list
  | DIG of int * string
  | DUP of int * string
  | DROP of int * string
  | SWAP
  | LEFT
  | RIGHT
  | IF_LEFT of t list * t list
  | PAIR
  | CAR
  | CDR
  | UNPAIR
  | LAMBDA_REC of string * string * t list
  | APPLY
