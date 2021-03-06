From elpi Require Import elpi
  derive.eq derive.projK derive.isK 
  derive.param1 derive.param1P derive.map
  derive.induction derive.isK derive.projK
  derive.castP.

From Coq Require Import Bool List ssreflect.

Elpi derive.param1 prod.
Elpi derive.param1 list.
Elpi derive.param1P prod_param1.
Elpi derive.param1P list_param1.
Elpi derive.map prod_param1.
Elpi derive.map list_param1.

Inductive nat1 := 
 | O1 
 | S1 (_ : nat1 * (bool * list nat1)).

Elpi derive.induction nat1.
Elpi derive.induction nat.
Elpi derive.induction bool.
Elpi derive.induction list.
Elpi derive.induction prod.

Elpi derive.eq list. 
Elpi derive.eq prod.
Elpi derive.eq bool.
Elpi derive.eq nat.
Elpi derive.eq nat1.

Elpi derive.isK bool.
Elpi derive.isK nat.
Elpi derive.isK list.
Elpi derive.isK nat1.

Definition axiom T eqb x :=
  forall (y : T), reflect (x = y) (eqb x y).

Lemma reflect_eqf_base A B (f : A -> B) b x y : 
   reflect (x = y) b ->
             (forall x y, f x = f y -> x = y)
      ->
      reflect (f x = f y) b.
Proof.
case=> e; first by case: _ / e; constructor.
by move=> inj; constructor=> /inj.
Qed.

Lemma reflect_eqf_step2 A B C (f : forall a : A, B a -> C) b1 b2 x y z (w : B y) : 
   forall e : reflect (x = y) b1,
     (match e with
      | ReflectT _ e =>
            reflect (f x z = f x (cast2 A B _ _ e w)) b2
      | ReflectF _ abs =>
             forall x y z w, f x z = f y w -> x = y
     end) ->
      reflect (f x z = f y w) (b1 && b2).
Proof.
case=> e; first by case: _ / e w.
by move=> inj; constructor=> /inj.
Qed.

Lemma reflect_eqf_step3 A B C D
 (f : forall a : A, forall b : B a, C a b -> D) b1 b2 
x y z (w : B y) r (s : C y w) : 
   forall e : reflect (x = y) b1,
     (match e with
      | ReflectT _ e =>
            reflect (f x z r = 
                     f x (cast2 A B _ _ e w) (cast3 A B C _ _ e _ s)) b2
      | ReflectF _ abs =>
             forall x y z w r s, f x z r = f y w s -> x = y
     end) ->
      reflect (f x z r = f y w s) (b1 && b2).
Proof.
case=> e; first by case: _ / e w s.
by move=> inj; constructor=> /inj.
Qed.


Axiom daemon : False.

Elpi Command derive.eqOK.
Elpi Accumulate Db derive.isK.db.
Elpi Accumulate File "ltac/discriminate.elpi".
Elpi Accumulate Db derive.param1.db.
Elpi Accumulate Db derive.param1P.db.
Elpi Accumulate Db derive.induction.db.
Elpi Accumulate Db derive.castP.db.
Elpi Accumulate File "derive/eqOK.elpi".
Elpi Accumulate "
  main [str I, str F] :- !,
    coq-locate I (indt GR),
    coq-locate F (const Cmp),
    derive-eqOK GR Cmp.
  main _ :- usage.

  usage :- coq-error ""Usage: derive.eqOK <inductive type name> <comparison function>"".
".
Elpi Typecheck.

Elpi derive.eqOK bool bool_eq.
Check bool_eqOK : forall x, axiom bool bool_eq x.

Elpi derive.eqOK nat nat_eq.
Check nat_eqOK : forall x, axiom nat nat_eq x.

(*
Print cast2.
Elpi derive.eqOK list list_eq.
Print list_eqOK.

Lemma nat_eqOK x : axiom nat nat_eq x.
Proof.
move: x; apply: nat_induction => [|x]. case.
  by constructor.
  by move=> x; constructor.
move=> IH; case.
  by constructor.
move=> y.
apply: reflect_eqf_base.
  by move=> a b H; injection H.
apply: IH.
Qed.


Inductive foo :=
  K (b : bool) (q : bool) (n : nat).
Elpi derive.eq foo.
Elpi derive.induction foo.

Lemma foo_eqOK x : axiom foo foo_eq x.
move: x; apply: foo_induction=> b q n; case=> b1 q1 n1.
unshelve apply: reflect_eqf_step3.
  by apply: bool_eqOK.
case: bool_eqOK=> [e|].
  case: _ / e.
  unshelve apply: reflect_eqf_step2.
  by apply: bool_eqOK.
case: bool_eqOK=> [e|].
  case: _ / e.
  unshelve apply: reflect_eqf_base.
    admit.
  apply: nat_eqOK.
admit.
admit.



Lemma bool_eqOK x : axiom bool bool_eq x.
Proof.
elim: x => -[|]; by constructor.
Qed.

Lemma list_eqOK A f :
  forall x (HA : list_param1 A (axiom A f) x),
  axiom (list A) (list_eq A f) x.
Proof.
move=> l; elim => [|x Px xs Pxs IH] [|y ys].
- constructor 1; reflexivity.
- constructor 2 => ?; discriminate.
- constructor 2 => ?; discriminate.
- apply: reflect_eq_f2=> [????[]|????[]||] //.
Qed.

Lemma prod_eqOK A f B g :
  forall x (H : prod_param1 A (axiom A f) B (axiom B g) x),
  axiom (A * B) (prod_eq A f B g) x.
Proof.
move=> x [a Ha b Hb] [w z].
apply: reflect_eq_f2 => [????[]|????[]||] //. 
Qed.

Lemma nat1_eqOK x : axiom nat1 nat1_eq x.
Proof.
apply: (nat1_induction (axiom nat1 nat1_eq)) => [ | a IH] [ | b ].
- constructor 1 => //.
- constructor 2 => ?; discriminate.
- constructor 2 => ?; discriminate.
- apply: reflect_eq_f1.
  + by move=> ?? [E].
  + rewrite /=.
    apply: prod_eqOK.
    apply: prodR_map IH => // l Hl.
    apply: list_eqOK.  
    apply: listR_map Hl => //.
Qed.

*)
