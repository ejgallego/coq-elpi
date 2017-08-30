From elpi Require Import elpi.


Elpi Accumulate File "coq-lib.elpi".

(****** say *************************************)

Elpi Accumulate "
test-hello :-
  coq-say ""hello world"",
  coq-warn ""this is a warning"". 
".
Elpi Run "test-hello".

(****** locate **********************************)

(* nametab *)
Elpi Accumulate "
test-locate-nat :-
  coq-locate ""nat"" (indt GR),
  coq-locate ""Datatypes.nat"" (indt GR),
  coq-locate ""Init.Datatypes.nat"" (indt GR),
  coq-locate ""Coq.Init.Datatypes.nat"" (indt GR).
".
Elpi Run "test-locate-nat".

Elpi Accumulate "
test-locate-foobar :-
  coq-locate ""foobar"" _.
".
Fail Elpi Run "test-locate-foobar".

(* syndef *)
Elpi Accumulate "
test-syndef :-
  coq-locate ""plus"" (const GR),
  coq-locate ""Nat.add"" (const GR).
".
Elpi Run "test-syndef".

(****** env **********************************)

Elpi Accumulate "
test-env-const :-
  coq-locate ""plus"" (const GR),
  coq-env-const GR BO TY,
  coq-locate ""nat"" Nat,
  coq-locate ""S"" Succ,
  TY = (prod _ Nat _\ prod _ Nat _\ Nat),
  BO = (fix _ 0 TY add\
         lam _ Nat n\ lam _ Nat m\
         match n (lam _ Nat _\ Nat)
         [ m
         , lam _ Nat w\ app[Succ, app[add,w,m]]]).
".
Elpi Run "test-env-const".

Axiom empty_nat : nat.

Elpi Run "coq-locate ""empty_nat"" (const GR),
          coq-env-const GR axiom TY.
".

Require Vector.

Elpi Accumulate "
test-env-indt :-
  coq-locate ""Vector.t"" Vect, Vect = indt GR,
  coq-locate ""Vector.nil"" Vnil,
  coq-locate ""Vector.cons"" Vcons,
  coq-locate ""nat"" Nat,
  coq-locate ""O"" Zero,
  coq-locate ""S"" Succ,
  coq-env-indt GR tt 1 1 TY [Vnil,Vcons] [Tnil,Tcons],
  TY = (prod _ (sort _) _\ prod _ Nat _\ (sort _)),
  Tnil = (prod _ (sort _) a\ app [Vect,a,Zero]),
  Tcons = (prod _ (sort _) a\
           prod _ a v\
           prod _ Nat n\
           prod _ (app[Vect,a,n]) v\
            app[Vect,a,app[Succ,n]]).
".
Elpi Run "test-env-indt".


Elpi Accumulate "
test-env-indc :-
  coq-locate ""nat"" Nat,
  coq-locate ""S"" Succ,
  coq-locate ""Vector.t"" Vect,
  coq-locate ""Vector.cons"" (indc GR),
  coq-env-indc GR 1 1 
          (prod _ (sort _) a\
           prod _ a v\
           prod _ Nat n\
           prod _ (app[Vect,a,n]) v\
            app[Vect,a,app[Succ,n]]).
".
Elpi Run "test-env-indc".

Elpi Accumulate "
test-env-indc1 :-
  coq-locate ""Vector.nil"" (indc GR),
  coq-env-indc GR 1 0 _.
".
Elpi Run "test-env-indc1".

Section Test.

Variable A : nat.

Elpi Run "
  coq-locate ""Vector.nil"" (indc GR1),
  coq-locate ""nat"" (indt GR2),
  coq-locate ""A"" (const GR3),
  coq-env-typeof-gr GR1 _,
  coq-env-typeof-gr GR2 _,
  coq-env-typeof-gr GR3 _.
".

End Test.

Elpi Accumulate "
test-env-add-const :-
  coq-locate ""plus"" (const GR),
  coq-env-const GR BO TY,
  coq-string-of-gr GR S,
  Name is S ^ ""_equal"",
  coq-env-add-const Name BO TY (const NGR),
  coq-env-const NGR BO _,
  coq-string-of-gr NGR ""add_equal"".
".
Elpi Run "test-env-add-const".

Check add_equal.

Elpi Accumulate "
test-env-add-axiom :-
  coq-locate ""False"" F,
  coq-env-add-axiom ""myfalse"" F GR,
  coq-say GR.
".
Elpi Run "test-env-add-axiom".

Check myfalse.

(****** typecheck **********************************)

Elpi Accumulate "
test-typecheck-const :-
  coq-locate ""plus"" (const GR),
  coq-env-const GR BO TY,
  coq-typecheck BO TY.
".
Elpi Run "test-typecheck-const".

(****** elaborate **********************************)

Require Import List.

Elpi Accumulate "
test-elaborate-list :-
  coq-locate ""cons"" Cons,
  coq-locate ""nil"" Nil,
  coq-locate ""nat"" Nat,
  coq-locate ""O"" Zero,
  coq-locate ""list"" List,
  L  = app [ Cons, hole, Zero, app [ Nil, hole ]],
  LE = app [ Cons, Nat, Zero, app [ Nil, Nat ]],
  coq-elaborate L LE (app [ List, Nat ]).
".
Elpi Run "test-elaborate-list".

(****** TC **********************************)

Require Import Classes.RelationClasses.

Axiom T : Type.
Axiom R : T -> T -> Prop.
Axiom Rr : forall x : T, R x x.

Definition myi : Reflexive R.
Proof.
exact Rr.
Defined.

Check (_ : Reflexive R).

Elpi Run "coq-locate ""myi"" (const GR), coq-TC-declare-instance GR 10 tt.".

Check (_ : Reflexive R).

(****** CS **********************************)

Structure eq := mk_eq { carrier : Type; eq_op : carrier -> carrier -> bool }.

Axiom W : Type.
Axiom Z : W -> W -> bool.
Axiom t : W.

Definition myc : eq := mk_eq W Z.

Fail Check (eq_op _ t t).

Elpi Run "coq-locate ""myc"" (const GR), coq-CS-declare-instance GR.".

Check (eq_op _ t t).

(****** Coercions **********************************)

Axiom C1 : Type.
Axiom C2 : Type.
Axiom c12 : C1 -> C2.
Axiom c1t : C1 -> Type.
Axiom c1f : C1 -> nat -> nat.

Elpi Run "coq-locate ""c12"" (const GR1),
          coq-locate ""c1t"" (const GR2),
          coq-locate ""c1f"" (const GR3),
          coq-locate ""C1""  C1,
          coq-locate ""C2""  C2,
          coq-coercion-declare GR1 C1 C2 tt,
          coq-coercion-declare GR2 C1 (sort _) tt,
          coq-coercion-declare GR3 C1 (prod _ _ _) tt.
	  ".

Check (fun x : C1 => (x : C2)).
Check (fun x : C1 => fun y : x => true).
Check (fun x : C1 => x 3).

(***** Univs *******************************)

Elpi Run "coq-univ-print-constraints.".
Elpi Run "coq-univ-new [] X".
Elpi Run "coq-univ-leq X Y".
Elpi Run "coq-univ-eq X Y".
Elpi Run "coq-univ-max X Y Z".
Elpi Run "coq-univ-sup X Y".





