Require Import ssreflect.

Require Import ZArith Array.PArray List String Floats.
Require Ascii.
Require Int63.
Import ListNotations.
Open Scope string_scope.

Require Import Malfunction.Malfunction.

(* type value = *)
(* | Block of int * value array *)
(* | Vec of vector_type * value array *)
(* | Func of (value -> value) *)
(* | Int of inttype * Z.t *)
(* | Float of float *)
(* | Thunk of value Lazy.t *)
#[bypass_check(positivity)]
Inductive value :=
| Block of int * array value      
| Vec of vector_type * array value
| Func of (value -> value)
| value_Int of inttype * Z
| Float of float
| Thunk of value 
.

Axiom assert : forall {X Y}, X -> Y.

Axiom fail : forall {X}, string -> X.

Definition add (x : string) (v : value) (locals : string -> value)  :=
  fun y =>
    if String.eqb y x then v else locals y.

Definition option_def {A} (a : A) (x : option A) : A :=
  match x with
  | None => a
  | Some a => a
  end.

Fixpoint Array_of_List' {A} count (l : list A) (a : array A) :=
  match l with
  | [] => a
  | x :: l => Array_of_List' (S count) l (PArray.set a (Int63.of_Z (Z.of_nat count)) x)
  end.

Definition Array_of_list {A} (def : A) (l : list A) :=
  Array_of_List' 0 l (PArray.make (Int63.of_Z (Z.of_nat (List.length l))) def).

Definition Array_init {A} (size : int) f :=
  let g := fun x => (f (Int63.of_Z (Z.of_nat x))) in
  @Array_of_list A (g 0) (map g (seq 0 (Z.to_nat (Int63.to_Z size)))).

Definition inttype_eqb (t1 t2 : inttype) :=
  match t1, t2 with
  | Int, Int
  | Int32, Int32
  | Int64, Int64
  | Bigint, Bigint => true
  | _, _ => false
  end.

Definition vector_type_eqb (t1 t2 : vector_type) :=
  match t1, t2 with
  | Array, Array
  | Bytevec, Bytevec => true
  | _, _ => false
  end.

Definition bitwidth := fun t =>
  match t with
  | Int => 63
  | Int32 => 32
  | Int64 => 64
  | BigInt => fail "no bitwidth for bigint"
  end%Z.

Definition truncate ty n :=
  value_Int (ty, match ty with
                 | Bigint => n
                 | ty =>
                     let width := bitwidth ty in
                     let range := Z.shiftl (Z.of_nat 1) width in
                     let masked := Z.land n (Z.sub range (Z.of_nat 1)) in
                     let min_int := Z.shiftr range 1 in
                     if Z.ltb masked min_int then masked else
                       Z.sub masked range
                 end).

Definition as_ty ty := fun ty2 =>
  match ty2 with
  | value_Int (ty', n) => if inttype_eqb ty ty' then n else fail "integer type missmatch"
  | _ => fail "expected integer"
  end.

Definition as_float x := match x with
  | Float f => f
                         | _ => fail "expected float64"
                         end.

Definition comparison_eqb x1 x2 :=
  match x1, x2 with
  | Datatypes.Lt, Datatypes.Lt | Datatypes.Gt, Datatypes.Gt | Datatypes.Eq, Datatypes.Eq => true
  | _, _ => false
  end.

#[bypass_check(guard)]
Fixpoint interpret
         (locals : @Ident.Map.t value)
         (env : @Ident.Map.t value)
         (x : t) {struct x} : value :=
  match x with
  | Mvar v => Ident.Map.find v locals
  | Mlambda (xs, e) =>
    let (x, e) := match xs with
     | [ ] => assert false
     | [x] => (x, e)
     | x :: xs => (x, Mlambda (xs, e))
    end in
    Func (fun v => interpret (Ident.Map.add x v locals) env e)
  | Mapply (f, vs) =>
     List.fold_left (fun f v => match f with
     | Func f => f (interpret locals env v)
     | _ => fail "not a function" end) vs (interpret locals env f)
  | Mnum (numconst_Int n) => value_Int (Int, Int63.to_Z n)
  (* | Mnum (`Int32 n) -> Int (`Int32, Z.of_int32 n) *)
  (* | Mnum (`Int64 n) -> Int (`Int64, Z.of_int64 n) *)
  | Mnum (numconst_Bigint n) => value_Int (Bigint, n)
  | Mnum (numconst_Float64 f) => Float f

  | Mstring s =>
     Vec (Bytevec,
           Array_init (Int63.of_Z (Z.of_nat (String.length s))) (fun i => value_Int (Int, (Z.of_nat (Ascii.nat_of_ascii (option_def Ascii.Space (String.get (Z.to_nat (Int63.to_Z i)) s)))))))

  | Mglobal _v => fail "globals unsupported"

  | Mswitch (scr, cases) =>
      let scr := interpret locals env scr in
      let fix find_match x := match x with
        | (cases, e) :: rest =>
            if List.existsb (fun case => match case, scr with
            | Tag n, Block (n', _) => Int63.eqb n n'
            | Deftag, Block _ => true
            | Intrange (min, max), value_Int (Int, n) => Z.leb (Int63.to_Z min) n && Z.leb n (Int63.to_Z max)
            | _, _ => false end) cases then
              interpret locals env e
            else
              find_match rest
        | [] => fail "no case matches" end in
      find_match cases

  | Mnumop1 (op, embed_inttype ty, e) =>
      let n := as_ty ty (interpret locals env e) in
      truncate ty (match op with Neg => Z.mul (-1) n | Not => Z.lnot n end)

  | Mnumop2 (op, embed_inttype ty, e1, e2) =>
      let e1 := interpret locals env e1 in
      let e2 := interpret locals env e2 in
      match op with
      | embed_binary_arith_op op =>
          let f := match op with
                   | Add => Z.add | Sub => Z.sub
                   | Mul => Z.mul | Div => Z.div | Mod => Z.rem 
                   end in
          truncate ty (f (as_ty ty e1) (as_ty ty e2))
      | embed_binary_bitwise_op op =>
          let n := as_ty ty e1 in
          let c := as_ty Int e2 in
          (* TODO is this test necessary? *)
          truncate ty (match op with
          | And => Z.land (as_ty ty e1) (as_ty ty e2)
          | Or => Z.lor (as_ty ty e1) (as_ty ty e2)
          | Xor => Z.lxor (as_ty ty e1) (as_ty ty e2)
          | Lsl => Z.shiftl n c
          | Asr => Z.shiftr n c
          | Lsr => 
              let n := match ty with
                       | Bigint => n
                       | op =>
                           let w := bitwidth ty in
                           Z.land n (Z.sub (Z.shiftl (Z.of_nat 1) w) (Z.of_nat 1)) end in
              Z.shiftr n c end)
      | embed_binary_comparison op =>
          let cmp := Z.compare (as_ty ty e1) (as_ty ty e2) in
          let res := match op with
            | Lt => comparison_eqb cmp Datatypes.Lt
            | Gt => comparison_eqb cmp Datatypes.Gt
            | Lte => negb (comparison_eqb cmp Datatypes.Gt)
            | Gte => negb (comparison_eqb cmp Datatypes.Lt)
            | Eq => comparison_eqb cmp Datatypes.Eq
                     end in
          value_Int (Int, if res then 1%Z else 0%Z)
      end
  | Mnumop1 (Neg, Float64, e) =>
      Float (- as_float (interpret locals env e))
  | Mnumop1 (Not, Float64, _) 
  | Mnumop2 (embed_binary_bitwise_op _, Float64, _, _) =>
      fail "invalid bitwise float operation"
  | Mnumop2 (embed_binary_arith_op op, Float64, e1, e2) =>
      let e1 := as_float (interpret locals env e1) in
      let e2 := as_float (interpret locals env e2) in
      Float (match op with
             | Add => e1 + e2
             | Sub => e1 - e2
             | Mul => e1 * e2
             | Div => e1 / e2
             | Mod => fail "mod on floats not supported" end)
  | Mnumop2 (embed_binary_comparison op, Float64, e1, e2) =>
      let e1 := as_float (interpret locals env e1) in
      let e2 := as_float (interpret locals env e2) in
      let res := match op with
             | Lt => PrimFloat.ltb e1 e2
             | Gt => PrimFloat.ltb e2 e2
             | Lte => PrimFloat.leb e1 e2
             | Gte => PrimFloat.leb e2 e1
             | Eq => PrimFloat.eqb e1 e2
                 end in
      value_Int (Int, if res then 1%Z else 0%Z)

  | Mconvert (embed_inttype src, embed_inttype dst, e) =>
      truncate dst (as_ty src (interpret locals env e))
  | Mconvert (embed_inttype src, Float64, e) =>
      Float (PrimFloat.of_int63 (Int63.of_Z (as_ty src (interpret locals env e))))
  | Mconvert (Float64, Float64, e) =>
      Float (as_float (interpret locals env e))
  | Mvecnew (ty, len, def) =>
      match ty, interpret locals env len, interpret locals env def with
      | Array, value_Int (Int, len), v =>
          Vec (Array, PArray.make (Int63.of_Z len) v)
      | Bytevec, value_Int (Int, len), (value_Int (Int, k)) as v =>
          if Z.leb 0%Z k && Z.ltb k 256 then
            Vec (Bytevec, PArray.make (Int63.of_Z len) v)
          else
            fail "bad vector creation"
      | _, _, _ => fail "bad vector creation"
      end
  | Mvecget (ty, vec, idx) =>
      (match interpret locals env vec, interpret locals env idx with
       | Vec (ty', vals), value_Int (Int,i) =>
           if vector_type_eqb ty ty' then
             if Z.leb 0 i && Z.ltb i (Int63.to_Z (PArray.length vals)) then
               PArray.get vals (Int63.of_Z i)
             else
               fail "index out of bounds: %d"
           else
             fail "wrong vector type"
       | _, _ => fail "wrong vector type"
       end
      )
  | Mvecset (ty, vec, idx, e) => fail "not implemented"
      (* (match interpret locals env vec, *)
      (*        interpret locals env idx, *)
      (*        interpret locals env e with *)
      (*  | Vec (ty', vals), value_Int (Int, i), v => *)
      (*      if vector_type_eqb ty ty' then *)
      (*        let i := Int63.to_Z i in *)
      (*        if Int63.leb (Int63.of_int 0) i && Int63.leb i (PArray.length vals) then *)
      (*          match ty, v with *)
      (*          | Array, _ => tt *)
      (*          | Bytevec, Int (Int, i) *)
  (*      else fail "wrong vector type" *)
  | Mveclen (ty, vec) =>
      match interpret locals env vec with
      | Vec (ty', vals) =>
          if vector_type_eqb ty ty' then value_Int (Int, Int63.to_Z (PArray.length vals)) else fail "wrong vector type"
      | _ => fail "wrong vector type"
      end
  | Mblock (tag, vals) =>
      Block (tag, Array_of_list (Func (fun dummy => dummy)) (List.map (interpret locals env) vals))
  | Mfield (idx, b) =>
      match interpret locals env b with
      | Block (_, vals) => PArray.get vals idx
      | _ => fail "not a block"
      end
  | Mlazy e => Thunk (interpret locals env e)
  | Mforce e =>
      match interpret locals env e with
      | Thunk v => v
      | _ => fail "not a lazy value"
      end
  | _ => assert "todo"
end.
