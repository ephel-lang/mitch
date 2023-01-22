open Mitch_vm

let rec expand_sequence =
  let open Objcode in
  function
  | IF_LEFT (l, r) :: s when List.length s > 0 -> [ IF_LEFT (l @ s, r @ s) ]
  | a :: l -> expand_instruction a :: expand_sequence l
  | [] -> []

and expand_instruction =
  let open Objcode in
  function
  | LAMBDA (n, l) -> LAMBDA (n, expand_sequence l)
  | LAMBDA_REC (n, l) -> LAMBDA_REC (n, expand_sequence l)
  | IF_LEFT (l, r) -> IF_LEFT (expand_sequence l, expand_sequence r)
  | o -> o

let rec expand o =
  let o' = expand_sequence o in
  if o' = o then o' else expand o'

let run o = expand o
