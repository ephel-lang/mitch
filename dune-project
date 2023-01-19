(lang dune 3.4)
 (name mitch)
 (version 0.1)
 (maintainers "d.plaindoux@free.fr")
 (generate_opam_files true)
 (package
  (name mitch)
  (synopsis "POC compiler to Michelson")
  (description "POC compiler to Michelson")
  (depends
   (alcotest :with-test)
   (preface (>= 1.0.0))))