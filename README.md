# Mitch

Compilation of an extended lambda-calculus to minimal stack style 
virtual machine. Finally, for the compilation we target:
- [ ] Michelson,
- [ ] EVM,
- [ ] WASM and
- [ ] the JRE.

## Compilation stage

Things to be done in order to a have a complete POC:

- [X] Function application (not partial one)
- [X] Sum data covering Inl, Inr and Case
- [X] Product data covering Pair, First and Second
- [X] Code Optimisation
- [X] Recursive function
- [ ] Partial evaluation

## Compilation Stages 

```
pure source 
    >>= transpile
    <&> expand 
    >>= optimise 
    <&> simplify 
    <&> normalise 
```

### Transpilation

The transpilation takes a lambda-calculus with recursion, sum and 
product data and produces the corresponding Michelson code.

### Expansion

Expansion is a de-normalisation operation building a source code 
based on a tree from a one which is a DAG. 

For instance, a code like:

```
IF_LEFT A B ; C
```

becomes 

```
IF_LEFT { A ; C } { B ; C }
```

### Optimisation

This stage provides an optimised version of the initial Michelson 
source code. This optimisation is done thanks to a symbolic 
evaluation.

For instance, a code like:

```
LEFT; IF_LEFT B C
```

becomes

```
B
```

### Simplification

The simplification is the process which detects patterns and apply 
rewriting rules.

For instance, a code like:

```
SWAP; SWAP; C
```

becomes

```
C
```

### Normalisation

This last stages revert the expansion process turning a tree based 
source code to a DAG in order to reduce the size of the source code 
finally.

For instance, a code like:

```
IF_LEFT { A ; C } { B ; C }
```

becomes

```
IF_LEFT A B ; C
```


## Some examples ...

Note: types are not given in the Michelson sample (for the moment).

### Basic sum manipulation

```ocaml
(fun x -> case (inl x) (fun x -> x) (fun _ -> 3))
```

is transpiled to

```michelson
LAMBDA { DUP 0; LEFT; IF_LEFT { DUP 0; DROP 1 } { PUSH (INT 3); DROP 1 }; DROP 1 }
```

optimised to

````michelson
LAMBDA { DUP 0; DROP 1 }
````

and finally simplified to

```michelson
LAMBDA { }
```

### Basic product manipulation 

```ocaml
(fun p -> (snd p) (fst p))
```

is transpiled to

```michelson
LAMBDA { DUP 0; CDR; DUP 1; CAR; EXEC; DROP 1 }
```

and finally simplified to 

```michelson
LAMBDA { UNPAIR; EXEC }
```

### Recursive function

```ocaml
rec(f).(fun x -> f x)
```

is transpiled to

```
LAMBDA_REC { DUP 1; DUP 1; EXEC; DROP 1; DROP 1 }
```

then simplified to

```
LAMBDA_REC { EXEC }
```

Note: This is a tail recursive function - which never terminates of course!

## Tezos related projects

- [Michelson: the language of Smart Contracts in Tezos](https://tezos.gitlab.io/active/michelson.html)
- [DaiLambda, Inc. Michelson optimizer](https://www.dailambda.jp/optz/)

# License

MIT License

Copyright (c) 2023-2024 Didier Plaindoux

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
