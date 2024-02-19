From Malfunction.Plugin Require Import Extract OCamlFFI.
From MetaCoq.Template Require Import All.

From Coq Require Import String.
From Coq Require Vector.

Set MetaCoq Extraction Build Directory "_build".

From Coq Require Import PrimInt63 Sint63.
Definition test_primint := 
  let _ := print_int Sint63.min_int in
  let _ := print_newline tt in
  let _ := print_int Sint63.max_int in
  tt.
Eval compute in test_primint.
MetaCoq Extraction -fmt -compile-with-coq -run test_primint "test_primint.mlf".

From Coq Require Import PrimFloat.
Definition test_floats := print_float (100.5)%float.
Eval compute in test_floats.
MetaCoq Extraction -fmt -compile-with-coq -run test_floats "test_floats.mlf".

Inductive three := ZERO | ONE | TWO | THREE.

Definition two := TWO.

From MetaCoq.Utils Require Import bytestring.

Definition test_bytestring (u : unit) := bytestring.String.compare "" "bug".

MetaCoq Extraction -compile-with-coq test_bytestring "test_bytestring.mlf".

MetaCoq Extraction two "two.mlf".

Axiom axiom : nat.

MetaCoq Extraction axiom "axiom.mlf".

From Malfunction Require Import Compile Pipeline.

From Coq Require Import List.
Import ListNotations.

Polymorphic Record myprod@{i j} (A : Type@{i}) (B : Type@{j}) := mypair { fst : A; snd : B }.

Notation "( x , y , .. , z )" := (mypair _ _ .. (mypair _ _ x y) .. z) : core_scope.
Definition many_list_functions : myprod _ _ := (@List.firstn nat, @List.filter nat, @List.skipn nat).

MetaCoq Extraction -fmt -typed many_list_functions "list.mlf".

Definition prf := match conj I I with conj x y => (x,0) end.

MetaCoq Extraction prf "proof.mlf".

MetaCoq Extraction blocks_until "mcase.mlf".

Definition test_add := plus 2 5.

MetaCoq Extraction test_add "add.mlf".

MetaCoq Extraction (match cons THREE nil with cons x _ => x | _ => ONE end).
MetaCoq Extraction -help.

Fixpoint ack (n m:nat) {struct n} : nat :=
  match n with
    | 0 => S m
    | S p => let fix ackn (m:nat) {struct m} :=
                 match m with
                   | 0 => ack p 1
                   | S q => ack p (ackn q)
                 end
             in ackn m
  end.

MetaCoq Extraction (ack 3 5).

MetaCoq Extraction (@exist nat (fun x => x = 0) 0 (@eq_refl _ 0)).

Definition vplus {n:nat} :
  Vector.t nat n -> Vector.t nat n -> Vector.t nat n := (Vector.map2 plus).
Definition v01 : Vector.t nat 2 :=
  (Vector.cons nat 0 1 (Vector.cons nat 1 0 (Vector.nil nat))).
Definition v23 : Vector.t nat 2 :=
  (Vector.cons nat 2 1 (Vector.cons nat 3 0 (Vector.nil nat))).
Definition vplus0123 := Vector.hd (vplus v01 v23).

MetaCoq Extraction vplus0123.

Inductive tree (A:Set) : Set :=
  node : A -> forest A -> tree A
with forest (A:Set) : Set :=
     | leaf : A -> forest A
     | fcons : tree A -> forest A -> forest A.
Arguments leaf {A}.
Arguments fcons {A}.
Arguments node {A}.

Fixpoint tree_size (t:tree bool) : nat :=
  match t with
    | node a f => S (forest_size f)
  end
with forest_size (f:forest bool) : nat :=
       match f with
         | leaf b => 1
         | fcons t f1 => (tree_size t + forest_size f1)
       end.

Definition arden: forest bool :=
  fcons (node true (fcons (node true (leaf false)) (leaf true)))
        (fcons (node true (fcons (node true (leaf false)) (leaf true)))
               (leaf false)).

MetaCoq Extraction (forest_size arden).

(** Typed extraction *)

Definition sub : { x : nat | x = 0 } := @exist _ _ 0 eq_refl.
MetaCoq Extraction sub.
MetaCoq Extraction -typed sub.
