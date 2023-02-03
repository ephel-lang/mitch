open Mitch_vm

let is_push =
  let open Objcode in
  function PUSH _ | LAMBDA _ -> true | _ -> false

let is_replace =
  let open Objcode in
  function CAR | CDR | LEFT | RIGHT -> true | _ -> false

let rec simplify_sequence =
  let open Objcode in
  function
  | DIG (0, _) :: l -> l
  | DIG (1, _) :: l -> SWAP :: l
  | SWAP :: DROP (i, n) :: l when i > 1 -> DROP (i, n) :: SWAP :: l
  | EXEC :: DROP (i, n) :: l when i > 0 -> DROP (i + 1, n) :: EXEC :: l
  | a :: DROP (i, n) :: l when is_push a && i > 0 -> DROP (i - 1, n) :: a :: l
  | a :: DROP (i, n) :: l when is_replace a && i > 0 -> DROP (i, n) :: a :: l
  | DUP (i, n) :: DROP (j, _) :: l when j = i + 1 -> DIG (i, n) :: l
  | DUP (i, m) :: DROP (j, n) :: l when j > i ->
    DROP (j - 1, n) :: DUP (i, m) :: l
  | DUP (i, m) :: DROP (j, n) :: l when j > 0 ->
    DROP (j - 1, n) :: DUP (i - 1, m) :: l
  | DIG (i, m) :: DROP (j, n) :: l when j > 0 ->
    if j > i
    then DROP (j - 1, n) :: DIG (i, m) :: l
    else DROP (j - 1, n) :: DIG (i - 1, m) :: l
  | DUP (0, _) :: CAR :: SWAP :: CDR :: l -> UNPAIR :: SWAP :: l
  | DUP (0, _) :: CDR :: SWAP :: CAR :: l -> UNPAIR :: l
  | DUP (0, n) :: CDR :: DUP (1, _) :: CAR :: PAIR :: l -> DUP (0, n) :: l
  | SWAP :: SWAP :: l -> l
  | a :: s -> simplify_instruction a :: simplify_sequence s
  | [] -> []

and simplify_instruction =
  let open Objcode in
  function
  | LAMBDA (n, l) -> LAMBDA (n, simplify_sequence l)
  | LAMBDA_REC (f, n, l) -> LAMBDA_REC (f, n, simplify_sequence l)
  | IF_LEFT (l, r) -> IF_LEFT (simplify_sequence l, simplify_sequence r)
  | o -> o

let rec simplify o =
  let o' = simplify_sequence o in
  if o' = o then o' else simplify o'

let run o = simplify o
