open Mitch.Lang.Expr
open Mitch.Vm.Objcode
open Mitch.System

open Preface.Result.Monad (struct
  type t = string
end)

let compile s =
  return s
  >>= Transpiler.run
  <&> Expander.run
  >>= Optimiser.run
  <&> Simplifier.run
  <&> Normaliser.run

let compile_01 () =
  let result =
    compile
      (Rec
         ( "f"
         , Abs
             ( "x"
             , Case
                 (Var "x", Abs ("y", Var "y"), Abs ("y", App (Var "f", Var "y")))
             ) ) )
  and expected =
    [
      LAMBDA_REC
        ( "f"
        , "x"
        , [
            DUP (0, "x")
          ; IF_LEFT ([ DROP (1, "x"); DROP (1, "f") ], [ DROP (1, "x"); EXEC ])
          ] )
    ]
  in
  Alcotest.(check (result string string))
    "compile rec(f).(fun x -> case x (fun y -> y) (fun y -> f y))"
    (return expected <&> to_string)
    (result <&> to_string)

let cases =
  let open Alcotest in
  ("Lambda Compilation", [ test_case "compile O1" `Quick compile_01 ])
